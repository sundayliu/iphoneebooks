#import <Foundation/Foundation.h>
#include <stdio.h>
#include "palmconvert.h"


int main(int argc, void **argv) {
  if(argc < 3) {
    fprintf(stderr, "Usage: %s <Palm.pdb> <destination.html>\n", argv[0]);
    exit(1);
  }
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  const char *sPalmFile = argv[1];
  const char *sDestFile = argv[2];
  
  NSString *retType = nil;
  NSString *sHTML = HTMLFromPDBFile([NSString stringWithCString:sPalmFile], &retType);
  
  FILE *fp = fopen(sDestFile, "w");
  fprintf(fp, "%s", [sHTML cString]);
  fclose(fp);
  
  [pool release];
  
  return 0;
}