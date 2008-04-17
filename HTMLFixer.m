// HTMLFixer.m, for Books.app by Zachary Brewster-Geisz


#include "HTMLFixer.h"

@implementation HTMLFixer

+(BOOL)fileHasBeenFixedAtPath:(NSString *)path
// Returns YES if the file has already been processed by HTMLFixer.
// Returns NO if it hasn't, or there was an error reading the file.
{
    NSFileHandle *theFile = [NSFileHandle fileHandleForReadingAtPath:path];
	if (nil != theFile)
        {
            NSData *beginningData = [[theFile readDataOfLength:24] retain];
            NSString *beginningString = [[NSString alloc] initWithData:beginningData
                                                encoding:NSUTF8StringEncoding];
            if (nil != beginningString)
                {
                    BOOL ret = [[beginningString substringWithRange:NSMakeRange(0, 12)]
                                  isEqualToString:@"<!--BooksApp"];
                    [beginningString release];
                    return ret;
                }
        }
    return NO;
}

+(BOOL)writeFixedFileAtPath:(NSString *)thePath
// Fixes the given HTML file and rewrites it.  Returns YES if successful, NO otherwise.
// You should always call +fileHasBeenFixed first to see if this method is needed.
//FIXME: use the user-defined text encoding, if applicable.
{
    NSMutableString *theHTML = [[NSMutableString alloc] initWithContentsOfFile:thePath
                                            encoding:NSUTF8StringEncoding
                                            error:NULL];
    BOOL ret;
/*  if (nil == theHTML)
    {
      NSLog(@"Trying UTF-8 encoding...");
      theHTML = [[NSMutableString alloc]
               initWithContentsOfFile:thePath
               encoding: NSUTF8StringEncoding
               error:NULL];
    }
*/    if (nil == theHTML)
    {
      NSLog(@"Trying ISO Latin-1 encoding...");
      theHTML = [[NSMutableString alloc]
               initWithContentsOfFile:thePath
               encoding: NSISOLatin1StringEncoding
               error:NULL];
    }
    if (nil == theHTML)
    {
      NSLog(@"Trying Mac OS Roman encoding...");
      theHTML = [[NSMutableString alloc]
               initWithContentsOfFile:thePath
               encoding: NSMacOSRomanStringEncoding
               error:NULL];
    }
    if (nil == theHTML)
    {
      NSLog(@"Trying ASCII encoding...");
      theHTML = [[NSMutableString alloc] 
               initWithContentsOfFile:thePath
               encoding: NSASCIIStringEncoding
               error:NULL];
    }
    if (nil == theHTML)  // Give up.  The webView will still display it.
        return NO;
    unsigned int c = 0;
    unsigned int len = [theHTML length];
    while (c < len)
        {
            if ([theHTML characterAtIndex:c] == (unichar)'<')
                {
                    NSString *imgString = [[theHTML substringWithRange:NSMakeRange(c+1, 3)]
                        lowercaseString];
                    if ([imgString isEqualToString:@"img"])
                        {
                            unsigned int d = c++;
                            while ((c < len) && ([theHTML characterAtIndex:c] != (unichar)'>'))
                                c++;
                            NSRange aRange = NSMakeRange(d, (c - d));
                            NSString *imageTagString = [theHTML substringWithRange: aRange];
                            [theHTML replaceCharactersInRange:aRange
                                 withString:[HTMLFixer fixedImageTagForString:imageTagString
                                                        basePath:[thePath stringByDeletingLastPathComponent]]];
                            len = [theHTML length];
                        }
                }
            ++c;
        }
        
    NSString *temp = [NSString stringWithFormat:@"<!--BooksApp modified %@ -->\n",
                        [NSCalendarDate calendarDate]];
    [theHTML insertString:temp atIndex:0];
    ret = [theHTML writeToFile:thePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    [theHTML release];
    return ret;
}

+(NSString *)fixedImageTagForString:(NSString *)aStr basePath:(NSString *)path
// Returns an image tag for which the image has been shrunk to 300 pixels wide.
// Does nothing if the image is already under 300 px wide.
// Assumes a local URL as the "src" element.
{
    NSMutableString *str = [NSMutableString stringWithString:aStr];
    unsigned int len = [str length];
    NSRange range;
    NSString *tempString;
    unsigned int c = 0;
    unsigned int d = 0;
    unsigned int width = 300;
    unsigned int height = 0;
    NSString *srcString = nil;
    
    // First step, find the "src" string.
    while (c + 5 < len)
        {
            range = NSMakeRange(c++, 5);
            tempString = [[str substringWithRange:range] lowercaseString];
            if ([tempString isEqualToString:@"src=\""])
                {
                    c += 4;
                    d = c;
                    while ((c < len) && ([str characterAtIndex:c] != (unichar)'"'))
                        ++c;
                    NSRange anotherRange = NSMakeRange(d, (c-d));
                    srcString = [str substringWithRange:anotherRange];
                    //With any luck, this will be the file name.
                    break;
                }
        }
    if (srcString == nil)
        return [aStr copy];
    NSString *imgPath = [[path stringByAppendingPathComponent:srcString] stringByStandardizingPath];
    UIImage *img = [UIImage imageAtPath:imgPath];
    if (nil != img)
        {
            CGImageRef imgRef = [img imageRef];
            width = CGImageGetWidth(imgRef);
            if (width <= 300)
                return [aStr copy];
            height = CGImageGetHeight(imgRef);
            float aspectRatio = (float)height / (float)width;
            width = 300;
            height = (unsigned int)(300.0 * aspectRatio);
        }
    // Now, find if there's a "height" tag.
    c = 0;
    while (c + 8 < len)
        {
            range = NSMakeRange(c++, 8);
            tempString = [[str substringWithRange:range] lowercaseString];
            if ([tempString isEqualToString:@"height=\""])
                {
                    c +=7;
                    d = c;
                    while ((c < len) && ([str characterAtIndex:c] != (unichar)'"'))
                        c++;
                    NSRange anotherRange = NSMakeRange(d, (c - d));
                    NSString *heightNumString = [NSString stringWithFormat:@"%d", (int)height];
                    [str replaceCharactersInRange:anotherRange withString:heightNumString];
                    len = [str length];
                    break;
                }
        }
    // If there's no height tag, we don't need to worry about inserting one.
    // Now, to find the width tag.
    c = 0;
    BOOL foundWidth = NO;
    while (c + 7 < len)
        {
            range = NSMakeRange(c++, 7);
            tempString = [[str substringWithRange:range] lowercaseString];
            if ([tempString isEqualToString:@"width=\""])
	      {   //FIXME: This fails if there's whitespace between width and a quote mark
                    foundWidth = YES;
                    c +=6;
                    d = c;
                    while ((c < len) && ([str characterAtIndex:c] != (unichar)'"'))
                        c++;
                    NSRange anotherRange = NSMakeRange(d, (c - d));
                    NSString *widthNumString = [NSString stringWithFormat:@"%d", (int)width];
                    [str replaceCharactersInRange:anotherRange withString:widthNumString];
                    len = [str length];
                    break;
                }
        }
    if (!foundWidth)
    // There was no width tag, so let's just insert one.
        {
            NSString *widthString = [NSString stringWithFormat:@" width=\"%d\" ", (int)width];
            [str insertString:widthString atIndex:4];
        }
    return [NSString stringWithString:str];
}

@end
