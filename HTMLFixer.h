// HTMLFixer.h, for Books.app by Zachary Brewster-Geisz

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface HTMLFixer : NSObject

{
}

+(BOOL)fileHasBeenFixedAtPath:(NSString *)path;
+(BOOL)writeFixedFileAtPath:(NSString *)thePath;
+(NSString *)fixedImageTagForString:(NSString *)aStr basePath:(NSString *)path;

@end