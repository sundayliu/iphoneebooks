// HTMLFixer.h, for Books.app by Zachary Brewster-Geisz

#import <Foundation/Foundation.h>
#import <stdio.h>


@interface HTMLFixer : NSObject

{
}

+(BOOL)fileHasBeenFixedAtPath:(NSString *)thePath;
+(BOOL)writeFixedFileAtPath:(NSString *)thePath;

@end