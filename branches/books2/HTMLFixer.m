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
{
    NSMutableString *theHTML = [[NSMutableString alloc] initWithContentsOfFile:thePath
                                            encoding:NSUTF8StringEncoding
                                            error:NULL];
    // FIXME:allow for other encodings
    BOOL ret;
    if (nil == theHTML)
        return NO;
    unsigned int c = 0;
    unsigned int len = [theHTML length];
    while (c < len)
        {
            if ([theHTML characterAtIndex:c] == (unichar)'<')
                {
                    NSString *imgString = [[theHTML substringWithRange:NSMakeRange(c+1, 3)]
                        lowercaseString];
                    if ([imgString isEqualToString:@"img")
                        {
                            c += 4;
                            [theHTML insertString:@" width=\"300\" " atIndex:c];
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


@end