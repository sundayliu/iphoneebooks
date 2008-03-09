/* EBookView, by Zachary Brewster-Geisz for Books.app

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; version 2
   of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
#import <CoreGraphics/CoreGraphics.h>
#import <GraphicsServices/GraphicsServices.h>

#import "EBookView.h"
#import "BooksDefaultsController.h"
#import "palm/palmconvert.h"
#import "ChapteredHTML.h"

@interface NSObject (HeartbeatDelegate)

	- (void)heartbeatCallback:(id)ignored;

	@end


	@implementation EBookView

	- (id)initWithFrame:(struct CGRect)rect
{
	CGRect lFrame = rect;
	if (rect.size.width < rect.size.height)
	{
		lFrame.size.width = rect.size.height;
	}
	[super initWithFrame:lFrame];
	[super setFrame:rect];	
	//  tapinfo = [[UIViewTapInfo alloc] initWithDelegate:self view:self];

	size = 16.0f;

	chapteredHTML = [[ChapteredHTML alloc] init];
	subchapter    = 0;
	defaults      = [BooksDefaultsController sharedBooksDefaultsController]; 
	[self setAdjustForContentSizeChange:YES];
	[self setEditable:NO];

	[self setTextSize:size];
	[self setTextFont:@"TimesNewRoman"];

	[self setAllowsRubberBanding:YES];
	[self setBottomBufferHeight:0.0f];

	[self scrollToMakeCaretVisible:NO];

	[self setScrollDecelerationFactor:0.996f];
	//  GSLog(@"scroll deceleration:%f\n", self->_scrollDecelerationFactor);
	[self setTapDelegate:self];
	[self setScrollerIndicatorsPinToContent:NO];
	lastVisibleRect = [self visibleRect];
	[self scrollSpeedDidChange:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(scrollSpeedDidChange:)
												 name:CHANGEDSCROLLSPEED
											   object:nil];

	return self;
}

- (void)heartbeatCallback:(id)unused
{
	if ((![self isScrolling]) && (![self isDecelerating]))
		lastVisibleRect = [self visibleRect];
	if (_heartbeatDelegate != nil) {
		if ([_heartbeatDelegate respondsToSelector:@selector(heartbeatCallback:)]) {
			 [_heartbeatDelegate heartbeatCallback:self];
		} else {
			[NSException raise:NSInternalInconsistencyException
						format:@"Delegate doesn't respond to selector"];
		}
	}
}

- (void)setHeartbeatDelegate:(id)delegate
{
	_heartbeatDelegate = delegate;
	[self startHeartbeat:@selector(heartbeatCallback:) inRunLoopMode:nil];
}

- (void)hideNavbars
{
	if (_heartbeatDelegate != nil) {
		if ([_heartbeatDelegate respondsToSelector:@selector(hideNavbars)]) {
			[_heartbeatDelegate hideNavbars];
		} else {
			[NSException raise:NSInternalInconsistencyException
						format:@"Delegate doesn't respond to selector"];
		}
	}
}
/*
   - (void)drawRect:(struct CGRect)rect
   {

   if (nil != path)
   {
   NSString *coverPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"cover.jpg"];
   UIImage *img = [UIImage imageAtPath:coverPath];
   if (nil != img)
   {
   [img compositeToPoint:CGPointMake(0,0) operation:1];
   }
   }

   [super drawRect:rect];
   }
   */
- (void)toggleNavbars
{
	if (_heartbeatDelegate != nil) {
		if ([_heartbeatDelegate respondsToSelector:@selector(toggleNavbars)]) {
			[_heartbeatDelegate toggleNavbars];
		} else {
			[NSException raise:NSInternalInconsistencyException
						format:@"Delegate doesn't respond to selector"];
		}
	}
}

/**
 * Return the current path.
 */
- (NSString *)currentPath; {
	return path;
}

/**
 * Increase on-screen text size.
 *
 * "A noble spirit embiggens the smallest man." -- Jebediah Springfield
 */
- (void)embiggenText {
	if (size < 36.0f)
	{
		struct CGRect oldRect = [self visibleRect];
		struct CGRect totalRect = [[self _webView] frame];
		GSLog(@"size: %f y: %f\n", size, oldRect.origin.y);
		float middleRect = oldRect.origin.y + (oldRect.size.height / 2);
		float scrollFactor = middleRect / totalRect.size.height;
		size += 2.0f;
		[self setTextSize:size];
           
    [self recalculateStyle];
    [self webViewDidChange:self];
		[self setNeedsDisplay];
    
    totalRect = [[self _webView] frame];
		middleRect = scrollFactor * totalRect.size.height;
		oldRect.origin.y = middleRect - (oldRect.size.height / 2);
		GSLog(@"size: %f y: %f\n", size, oldRect.origin.y);
		[self scrollPointVisibleAtTopLeft:oldRect.origin animated:NO];
	}
}

/**
 * Shrink on-screen text size.
 *
 * "What the f--- does ensmallen mean?" -- Zach Brewster-Geisz
 */
- (void)ensmallenText {
	if (size > 10.0f)
	{
		struct CGRect oldRect = [self visibleRect];
		struct CGRect totalRect = [[self _webView] frame];
		GSLog(@"size: %f y: %f\n", size, oldRect.origin.y);
		float middleRect = oldRect.origin.y + (oldRect.size.height / 2);
		float scrollFactor = middleRect / totalRect.size.height;
		size -= 2.0f;
		[self setTextSize:size];

    [self recalculateStyle];
    [self webViewDidChange:self];
		[self setNeedsDisplay];
    
    totalRect = [[self _webView] frame];
		middleRect = scrollFactor * totalRect.size.height;
		oldRect.origin.y = middleRect - (oldRect.size.height / 2);
		GSLog(@"size: %f y: %f\n", size, oldRect.origin.y);
		[self scrollPointVisibleAtTopLeft:oldRect.origin animated:NO];
	}
}


// None of these tap methods work yet.  They may never work.
- (void)handleDoubleTapEvent:(struct __GSEvent *)event {
	[self embiggenText];
	//[super handleDoubleTapEvent:event];
}

- (void)handleSingleTapEvent:(struct __GSEvent *)event {
	[self ensmallenText];
	//[super handleDoubleTapEvent:event];
}
/*
   - (BOOL)bodyAlwaysFillsFrame
   {//experiment!
   return NO;
   }
   */

- (void)mouseUp:(struct __GSEvent *)event {
	/*************
	 * NOTE: THE GSEVENTGETLOCATIONINWINDOW INVOCATION
	 * WILL NOT COMPILE UNLESS YOU HAVE PATCHED GRAPHICSSERVICES.H TO ALLOW IT!
	 * A patch is included in the svn.
	 *****************/

	CGPoint clicked = GSEventGetLocationInWindow(event);
	struct CGRect newRect = [self visibleRect];
	struct CGRect contentRect = [defaults fullScreenApplicationContentRect];
	int lZoneHeight = [defaults enlargeNavZone] ? 75 : 48;
	GSLog(@"zone height %d", lZoneHeight);
	struct CGRect topTapRect = CGRectMake(0, 0, newRect.size.width, lZoneHeight);
	struct CGRect botTapRect = CGRectMake(0, contentRect.size.height - lZoneHeight, contentRect.size.width, lZoneHeight);
	if ([self isScrolling])
	{
		if (CGRectEqualToRect(lastVisibleRect, newRect))
		{
			if (CGRectContainsPoint(topTapRect, clicked))
			{
				if ([defaults inverseNavZone])
				{
					//scroll forward one screen...
					[self pageDownWithTopBar:![defaults navbar] bottomBar:NO];
				}
				else
				{
					//scroll back one screen...
					[self pageUpWithTopBar:NO bottomBar:![defaults toolbar]];
				}
			}
			else if (CGRectContainsPoint(botTapRect,clicked))
			{
				if ([defaults inverseNavZone])
				{
					//scroll back one screen...
					[self pageUpWithTopBar:NO bottomBar:![defaults toolbar]];
				}
				else
				{
					//scroll forward one screen...
					[self pageDownWithTopBar:![defaults navbar] bottomBar:NO];
				}
			}
			else 
			{  // If the old rect equals the new, then we must not be scrolling
				[self toggleNavbars];
			}
		}
		else
		{ //we are, in fact, scrolling
			[self hideNavbars];
		}
	}
	BOOL unused = [self releaseRubberBandIfNecessary];
	lastVisibleRect = [self visibleRect];
	[super mouseUp:event];
}

// These two are so the toolbar buttons work!
// BUT: The the amount of the scroll needs to be adjusted based on the
// the defaults for showing the NAVBAR and TOOLBAR.
// Right now it scrolls based on full screen and thus, to far. Zach?
// FIXED: I think.
 // TODO: Adjust the bottom and top buffers.  The scrolling works, but
 // the text can wind up behind the toolbars at the bottom & top
 // of the text.
- (void)pageDownWithTopBar:(BOOL)hasTopBar bottomBar:(BOOL)hasBotBar
{
	struct CGRect contentRect = [defaults fullScreenApplicationContentRect];
	float  scrollness = contentRect.size.height;
	scrollness -= (((hasTopBar) ? 48 : 0) + ((hasBotBar) ? 48 : 0));
	scrollness /= size;
	scrollness = floor(scrollness - 1.0f);
	scrollness *= size;
	// That little dance above was so we only scroll in
	// multiples of the text size.  And it doesn't even work!
	[self scrollByDelta:CGSizeMake(0, scrollness)	animated:YES];
	[self hideNavbars];
}

-(void)pageUpWithTopBar:(BOOL)hasTopBar bottomBar:(BOOL)hasBotBar
{
	struct CGRect contentRect = [defaults fullScreenApplicationContentRect];
	float  scrollness = contentRect.size.height;
	scrollness -= (((hasTopBar) ? 48 : 0) + ((hasBotBar) ? 48 : 0));
	scrollness /= size;
	scrollness = floor(scrollness - 1.0f);
	scrollness *= size;
	// That little dance above was so we only scroll in
	// multiples of the text size.  And it doesn't even work!
	[self scrollByDelta:CGSizeMake(0, -scrollness) animated:YES];
	[self hideNavbars];
}

- (int)textSize
// This method is needed because the toolchain doesn't
// currently handle floating-point return values in an
// ARM-friendly way.
{
	return (int)size;
}

- (void)setTextSize:(int)newSize
{
	size = (float)newSize;
	[super setTextSize:size];
}

- (void)scrollSpeedDidChange:(NSNotification *)aNotification
{
	switch ([defaults scrollSpeedIndex])
	{
		case 0:
	  [self setScrollToPointAnimationDuration:0.75];
	  break;
		case 1:
	  [self setScrollToPointAnimationDuration:0.25];
	  break;
		case 2:
	  [self setScrollToPointAnimationDuration:0.0];
	  break;
	}
}

#pragma mark File Reading Methods START

- (void)loadBookWithPath:(NSString *)thePath subchapter:(int)theSubchapter {
	BOOL junk;
	return [self loadBookWithPath:thePath numCharacters:-1 didLoadAll:&junk subchapter:theSubchapter];
}

- (void)loadBookWithPath:(NSString *)thePath numCharacters:(int)numChars subchapter:(int)theSubchapter {
	BOOL junk;
	return [self loadBookWithPath:thePath numCharacters:numChars didLoadAll:&junk subchapter:theSubchapter];
}

//USE WITH CAUTION!!!!
- (void)setCurrentPathWithoutLoading:(NSString *)thePath {
  [thePath retain];
  [path release];
	path = thePath;
}

/**
 * Master method to load book - all others delegate here.
 *
 * @param thePath full file/path of book to load
 * @param numChars number of characters if known, -1 if not
 * @param didLoadAll pointer to bool which will return YES if the entire file was loaded into memory
 * @param theSubchapter subchapter number for chaptered HTML
 */
- (void)loadBookWithPath:(NSString *)thePath numCharacters:(int)numChars 
              didLoadAll:(BOOL *)didLoadAll subchapter:(int)theSubchapter {
  
	NSString *theHTML = nil;
	//GSLog(@"path: %@", thePath);
  
  [thePath retain];
  [path release];
	path = thePath;
  
  NSString *pathExt = [[thePath pathExtension] lowercaseString];
  
  BOOL bIsHtml;
  
  if ([pathExt isEqualToString:@"txt"]) {
    bIsHtml = NO;
		theHTML = [self readTextFile:thePath];
	} else if ([pathExt isEqualToString:@"html"] || [pathExt isEqualToString:@"htm"]) {
    bIsHtml = YES;
		theHTML = [self HTMLFileWithoutImages:thePath];
	}	else if ([pathExt isEqualToString:@"pdb"]) { 
		// This could be PalmDOC, Plucker, iSilo, Mobidoc, or something completely different
		NSString *retType = nil;
		NSMutableString *ret;
    
		ret = ReadPDBFile(thePath, &retType);
    
		if([@"txt" isEqualToString:retType]) {
      bIsHtml = NO;
      theHTML = ret;
		} else {
      bIsHtml = YES;
			theHTML = ret;
		}
	}
  
	if ((-1 == numChars) || (numChars >= [theHTML length])) {
		*didLoadAll = YES;
  
    if(bIsHtml) {
      if ([defaults subchapteringEnabled] == NO) {
        [self setHTML:theHTML];
        subchapter = 0;
      } else {
        [chapteredHTML setHTML:theHTML];
        
        if (theSubchapter < [chapteredHTML chapterCount])
          subchapter = theSubchapter;
        else
          subchapter = 0;
        
        [self setHTML:[chapteredHTML getChapterHTML:subchapter]];
      }
    } else {
      [self setText:theHTML];
    }
	} else {
    if(bIsHtml) {
      NSString *tempyString = [NSString stringWithFormat:@"%@</body></html>",
                               [theHTML HTMLsubstringToIndex:numChars didLoadAll:didLoadAll]];
      [self setHTML:tempyString];
    } else {
      [self setText:theHTML];
    }
	}
  
	/* This code doesn't work.  Sorry, charlie.
   if (1) //replace with a defaults check
   { 
   NSMutableString *ebookPath = [NSString  stringWithString:[BooksDefaultsController defaultEBookPath]];
   NSString *styleSheetPath = [ebookPath stringByAppendingString:@"/style.css"];
   if ([[NSFileManager defaultManager] fileExistsAtPath:styleSheetPath])
   {
   [[self _webView] setUserStyleSheetLocation:[NSURL fileURLWithPath:ebookPath]];
   }
   //[ebookPath release];
   }
   */
}


/**
 * Read a text file, attempting to determine its encoding using defaults, automatically,
 * or with a list of common encodings, convert to HTML and return.
 */
- (NSString *)readTextFile:(NSString *)file {  
	NSStringEncoding defaultEncoding = [defaults defaultTextEncoding];
  NSStringEncoding encList[] = {
    defaultEncoding, NSUTF8StringEncoding, NSISOLatin1StringEncoding, 
    NSWindowsCP1252StringEncoding, NSMacOSRomanStringEncoding,
    NSASCIIStringEncoding
  };
  int nEncCount = 6;
  int i;
  
  NSMutableString *originalText;
  for(i=0; i<nEncCount; i++) {
    NSStringEncoding curEnc = encList[i];
    
    if(curEnc == AUTOMATIC_ENCODING) {
      GSLog(@"Trying automatic encoding");
      originalText = [[NSMutableString alloc] initWithContentsOfFile:file usedEncoding:&defaultEncoding error:NULL];
    } else {
      GSLog(@"Trying encoding: %d", curEnc);
      originalText = [[NSMutableString alloc] initWithContentsOfFile:file encoding:curEnc error:NULL];
    }
    
    if(originalText != nil) {
      GSLog(@"Successfully opened with encoding: %d", curEnc);
      break;
    }
  }
  
  if(originalText == nil) {
    originalText = [[NSMutableString alloc] initWithString:
                    @"Could not determine text encoding.  Try changing the text encoding settings in Preferences.\n\n"];
  }
  
	return [originalText autorelease];  
}

- (NSString *)HTMLFileWithoutImages:(NSString *)thePath
{
	// The name of this method is in fact misleading--in Books.app < 1.2,
	// it did in fact strip images.  Not anymore, though.
  
	NSStringEncoding encoding = [defaults defaultTextEncoding];
	NSMutableString *originalText;
	NSString *outputHTML;
	GSLog(@"Checking encoding...");
	if (AUTOMATIC_ENCODING == encoding)
	{
		originalText = [[NSMutableString alloc]
                    initWithContentsOfFile:thePath
                    usedEncoding:&encoding
                    error:NULL];
		GSLog(@"Encoding: %d",encoding);
		if (nil == originalText)
		{
			GSLog(@"Trying UTF-8 encoding...");
			originalText = [[NSMutableString alloc]
                      initWithContentsOfFile:thePath
                      encoding: NSUTF8StringEncoding
                      error:NULL];
		}
		if (nil == originalText)
		{
			GSLog(@"Trying ISO Latin-1 encoding...");
			originalText = [[NSMutableString alloc]
                      initWithContentsOfFile:thePath
                      encoding: NSISOLatin1StringEncoding
                      error:NULL];
		}
		if (nil == originalText)
		{
			GSLog(@"Trying Mac OS Roman encoding...");
			originalText = [[NSMutableString alloc]
                      initWithContentsOfFile:thePath
                      encoding: NSMacOSRomanStringEncoding
                      error:NULL];
		}
		if (nil == originalText)
		{
			GSLog(@"Trying ASCII encoding...");
			originalText = [[NSMutableString alloc] 
                      initWithContentsOfFile:thePath
                      encoding: NSASCIIStringEncoding
                      error:NULL];
		}
		if (nil == originalText)
		{
			originalText = [[NSMutableString alloc] initWithString:@"<html><body><p>Could not determine text encoding.  Try changing the default encoding in Preferences.</p></body></html>\n"];
		}
	}
	else // if encoding is specified
	{
		originalText = [[NSMutableString alloc]
                    initWithContentsOfFile:thePath
                    encoding: encoding
                    error:NULL];
		if (nil == originalText)
		{
			originalText = [[NSMutableString alloc] initWithString:@"<html><body><p>Incorrect text encoding.  Try changing the default encoding in Preferences.</p></body></html>\n"];
		}
	} //else
  
	NSRange fullRange = NSMakeRange(0, [originalText length]);
  
	unsigned int i;
	int extraHeight = 0;
	//Make all image src URLs into absolute file URLs.
	outputHTML = [HTMLFixer fixedHTMLStringForString:originalText filePath:thePath textSize:(int)size];
  
	//  struct CGSize asize = [outputHTML sizeWithStyle:nil forWidth:320.0];
	//  GSLog(@"Size for text: width: %f height: %f", asize.width, asize.height);
	return outputHTML;
}

- (NSString*)HTMLFromTextString:(NSMutableString *)originalText 
{
	NSString *header = @"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 3.2//EN\">\n<html>\n\n<head>\n<title></title>\n</head>\n\n<body>\n<p>\n";
	NSString *outputHTML;
	NSRange fullRange = NSMakeRange(0, [originalText length]);

	unsigned int i,j;
	j=0;
	i = [originalText replaceOccurrencesOfString:@"&" withString:@"&amp;"
		options:NSLiteralSearch range:fullRange];
	//GSLog(@"replaced %d &s\n", i);
	j += i;
	fullRange = NSMakeRange(0, [originalText length]);
	i = [originalText replaceOccurrencesOfString:@"<" withString:@"&lt;"
		options:NSLiteralSearch range:fullRange];
	//GSLog(@"replaced %d <s\n", i);
	j += i;
	fullRange = NSMakeRange(0, [originalText length]);
	i = [originalText replaceOccurrencesOfString:@">" withString:@"&gt;"
		options:NSLiteralSearch range:fullRange];
	//GSLog(@"replaced %d >s\n", i);
	j += i;
	fullRange = NSMakeRange(0, [originalText length]);

	// Argh, bloody MS line breaks!  Change them to UNIX, then...
	i = [originalText replaceOccurrencesOfString:@"\r\n" withString:@"\n"
										 options:NSLiteralSearch range:fullRange];
	//GSLog(@"replaced %d carriage return/newlines\n", i);
	j += i;
	fullRange = NSMakeRange(0, [originalText length]);

	if ([defaults smartConversion])
	{
		//Change double-newlines to </p><p>.
		i = [originalText replaceOccurrencesOfString:@"\n\n" withString:@"</p>\n<p>"
											 options:NSLiteralSearch range:fullRange];
		//GSLog(@"replaced %d double-newlines\n", i);
		j += i;
		fullRange = NSMakeRange(0, [originalText length]);

		// And just in case someone has a Classic MacOS textfile...
		i = [originalText replaceOccurrencesOfString:@"\r\r" withString:@"</p>\n<p>"
											 options:NSLiteralSearch range:fullRange];
		//GSLog(@"replaced %d double-carriage-returns\n", i);
		j += i;

		// Lots of text files start new paragraphs with newline-space-space or newline-tab
		i = [originalText replaceOccurrencesOfString:@"\n  " withString:@"</p>\n<p>"
											 options:NSLiteralSearch range:fullRange];
		//GSLog(@"replaced %d double-spaces\n", i);
		j += i;
		fullRange = NSMakeRange(0, [originalText length]);

		i = [originalText replaceOccurrencesOfString:@"\n\t" withString:@"</p>\n<p>"
											 options:NSLiteralSearch range:fullRange];
		//GSLog(@"replaced %d double-spaces\n", i);
		j += i;
	}
	else
	{
		fullRange = NSMakeRange(0, [originalText length]);
		i = [originalText replaceOccurrencesOfString:@"\n" withString:@"<br />\n"
											 options:NSLiteralSearch range:fullRange];
		fullRange = NSMakeRange(0, [originalText length]);

		// And just in case someone has a Classic MacOS textfile...
		i = [originalText replaceOccurrencesOfString:@"\r" withString:@"<br />\n"
											 options:NSLiteralSearch range:fullRange];
		//GSLog(@"replaced %d double-carriage-returns\n", i);
		j += i;

	}
	fullRange = NSMakeRange(0, [originalText length]);

	i = [originalText replaceOccurrencesOfString:@"  " withString:@"&nbsp; "
		options:NSLiteralSearch range:fullRange];
	//GSLog(@"replaced %d double-spaces\n", i);
	j += i;
	fullRange = NSMakeRange(0, [originalText length]);


	outputHTML = [NSString stringWithFormat:@"%@%@\n</p><br /><br />\n</body>\n</html>\n", header, originalText];

	return outputHTML;  
}

#pragma mark File Reading Methods END

- (void)invertText:(BOOL)b
{
	if (b) {
		// makes the the view white text on black
		float backParts[4] = {0, 0, 0, 1};
		float textParts[4] = {1, 1, 1, 1};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		[self setBackgroundColor: CGColorCreate( colorSpace, backParts)];
		[self setTextColor: CGColorCreate( colorSpace, textParts)];
		[self setScrollerIndicatorStyle:2];
	} else {
		float backParts[4] = {1, 1, 1, 1};
		float textParts[4] = {0, 0, 0, 1};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		[self setBackgroundColor: CGColorCreate( colorSpace, backParts)];
		[self setTextColor: CGColorCreate( colorSpace, textParts)];
		[self setScrollerIndicatorStyle:0];
	}
	// This "setHTML" invocation is a kludge;
	// for some reason the display doesn't update correctly
	// without it, and we can't yet figure out how to fix it.
  /* FIXME: ZSB: See if invertText works without redrawing the HTML yet.
	struct CGRect oldRect = [self visibleRect];

	if ([defaults subchapteringEnabled] && (subchapter < [chapteredHTML chapterCount])) {
		[self setHTML:[chapteredHTML getChapterHTML:subchapter]];
	}	else {
    [self setHTML:fullHTML];
  }

	[self scrollPointVisibleAtTopLeft:oldRect.origin];
   */
  
	[self setNeedsDisplay];
}


- (void)dealloc
{
	//[tapinfo release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[path release];
	[chapteredHTML release];
//	[fullHTML release];
	[defaults release];
	[super dealloc];
}

- (int) getSubchapter
{
	return subchapter;
}

- (int) getMaxSubchapter
{
	int maxSubchapter = 1;

	if ([defaults subchapteringEnabled] == YES)
		maxSubchapter = [chapteredHTML chapterCount];

	return maxSubchapter;
}

- (void) setSubchapter: (int) chapter
{
	CGPoint origin = { 0, 0 };

	if ([defaults subchapteringEnabled] &&
			(subchapter < [chapteredHTML chapterCount]))
	{
		[self setHTML:[chapteredHTML getChapterHTML:subchapter]];
	}
  /*
	else
		[self setHTML:fullHTML];
*/
	[self scrollPointVisibleAtTopLeft:origin];
  [self recalculateStyle];
  [self updateWebViewObjects];
	[self setNeedsDisplay];
}

- (BOOL) gotoNextSubchapter
{
	CGPoint origin = { 0, 0 };

	if ([defaults subchapteringEnabled] == NO)
		return NO;

	if ((subchapter + 1) >= [chapteredHTML chapterCount])
		return NO;

	[defaults setLastScrollPoint: [self visibleRect].origin.y
				   forSubchapter: subchapter
						 forFile: path];

	[self setHTML:[chapteredHTML getChapterHTML:++subchapter]];

	origin.y = [defaults lastScrollPointForFile:path inSubchapter:subchapter];
	[self scrollPointVisibleAtTopLeft:origin];
	[self setNeedsDisplay];
	return YES;
}

- (BOOL) gotoPreviousSubchapter
{
	CGPoint origin = { 0, 0 };

	if ([defaults subchapteringEnabled] == NO)
		return NO;

	if (subchapter == 0)
		return NO;

	[defaults setLastScrollPoint: [self visibleRect].origin.y
				   forSubchapter: subchapter
						 forFile: path];

	[self setHTML:[chapteredHTML getChapterHTML:--subchapter]];

	origin.y = [defaults lastScrollPointForFile:path inSubchapter:subchapter];
	[self scrollPointVisibleAtTopLeft:origin];
	[self setNeedsDisplay];
	return YES;
}


-(void) redraw
{
  /*
	if ([defaults subchapteringEnabled] &&
			(subchapter < [chapteredHTML chapterCount]))
	{
		[self setHTML:[chapteredHTML getChapterHTML:subchapter]];
	}
	else
		[self setHTML:fullHTML];
   */
	CGRect lWebViewFrame = [[self _webView] frame];
	CGRect lFrame = [self frame];
	GSLog(@"lWebViewFrame :  x=%f, y=%f, w=%f, h=%f", lWebViewFrame.origin.x, lWebViewFrame.origin.y, lWebViewFrame.size.width, lWebViewFrame.size.height);
	GSLog(@"lFrame : x=%f, y=%f, w=%f, h=%f", lFrame.origin.x, lFrame.origin.y, lFrame.size.width, lFrame.size.height);
	[[self _webView]setFrame: [self frame]];
  [self recalculateStyle];
  [self updateWebViewObjects];
	[self setNeedsDisplay];
}

@end