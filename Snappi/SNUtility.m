//
//  SNUtility.m
//  Snappi
//
//  Created by Marshall Moutenot on 12/14/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import "SNUtility.h"

@implementation SNUtility


+ (NSImage *)captureImageForRect:(NSRect)rect {
  
  NSWindow *window;
  window = [[NSWindow alloc] initWithContentRect:rect styleMask:NSBorderlessWindowMask
                                         backing:NSBackingStoreNonretained defer:NO];
  
  [window setBackgroundColor:[NSColor clearColor]];
//  [window setLevel:NSScreenSaverWindowLevel + 1];
  [window setLevel:NSMainMenuWindowLevel + 1];
  [window setHasShadow:NO];
  [window setAlphaValue:0.0];
  [window orderFront:self];
  [window setContentView:[[NSView alloc] initWithFrame:rect]];
  [[window contentView] lockFocus];
  CGWindowID windowID = (CGWindowID)[window windowNumber];
  
  CGImageRef capturedImage = CGWindowListCreateImage(rect, kCGWindowListOptionOnScreenBelowWindow, windowID, kCGWindowImageDefault);
  
  [[window contentView] unlockFocus];
  [window orderOut:self];
  
  NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage: capturedImage];
  NSImage *image = [[NSImage alloc] init];
  [image addRepresentation: bitmapRep];
//  CGImageRelease(capturedImage);

  return image;
}

// returns full path of written file
+ (NSString *)writeImageAsJPGToFile:(NSImage *)image toPath:(NSString *)pathToDir {
  NSString *sguid = [[NSProcessInfo processInfo] globallyUniqueString];
  NSBitmapImageRep *imgRep = [[image representations] objectAtIndex:0];
  NSData *data = [imgRep representationUsingType: NSPNGFileType properties:nil];
  NSString *pathToImage = [NSString stringWithFormat:@"%@/%@.jpg", pathToDir, sguid];
  [data writeToFile:pathToImage atomically:YES];
  return pathToImage;
}

// returns a rectangle with positive heights and widths and origin in bottom left
+ (NSRect)normalizeRect:(NSRect) rect{
  if (rect.size.width < 0){
    rect.origin.x = rect.origin.x + rect.size.width;
    rect.size.width *= -1;
  }
  if (rect.size.height < 0){
    rect.origin.y = rect.origin.y + rect.size.height;
    rect.size.height *= -1;
  }
  return rect;
}

+ (NSRect)expandRect:(NSRect) rect byFactor:(NSInteger)i{
  rect = [SNUtility normalizeRect:rect];
  rect.origin.x-=i;
  rect.origin.y-=i;
  rect.size.width+=i;
  rect.size.height+=i;
  return rect;
}

@end
