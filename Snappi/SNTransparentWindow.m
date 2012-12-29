//
//  SNTransparentWindow.m
//  Snappi
//
//  Created by Marshall Moutenot on 12/14/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import "SNTransparentWindow.h"

@implementation SNTransparentWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
  self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
  
  if (self)
  {
    [self setBackgroundColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.0]];
    [self setOpaque:NO];
    [self setLevel:NSMainMenuWindowLevel + 2];
  }
  
  return self;
}


@end
