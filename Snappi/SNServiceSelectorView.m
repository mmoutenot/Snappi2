//
//  SNServiceSelectorView.m
//  Snappi
//
//  Created by Marshall Moutenot on 12/25/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import "SNServiceSelectorView.h"

@implementation SNServiceSelectorView

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  [super drawRect:dirtyRect];
  [[NSColor colorWithCalibratedWhite:0.8 alpha:0.8] set];
  NSRectFill([self frame]);
}

@end
