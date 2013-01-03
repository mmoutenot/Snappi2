//
//  SNCaptureViewController.m
//  Snappi
//
//  Created by Marshall Moutenot on 12/14/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import "SNCaptureView.h"
#import "SNUtility.h"

@implementation SNCaptureView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    rectVal = [[NSValue alloc] init];
    NSRect rect = NSMakeRect(0, 0, 0, 0);
    rectVal = [NSValue valueWithRect:rect];
    
    // add mouse tracker so we can update drawing on each mouse movement
    NSTrackingArea *mouseTracker = [[NSTrackingArea alloc] initWithRect:frame options:(NSTrackingMouseMoved | NSTrackingActiveAlways) owner:self userInfo:nil];
    [self addTrackingArea:mouseTracker];
    
  }
  return self;
}

-(void)mouseMoved:(NSEvent *)theEvent{
  // redisplay needed for crosshairs
  [self setNeedsDisplay:YES];
}

-(void)mouseDown:(NSEvent *)pTheEvent {
  
  NSPoint mousePointInWindow = [pTheEvent locationInWindow];
  NSPoint mousePointInView   = [self convertPoint:mousePointInWindow fromView:nil];
  SNPoint *point             = [[SNPoint alloc]initWithNSPoint:mousePointInView];
  NSRect rect = NSMakeRect(point.x, point.y, 0, 0);
  rectVal = [NSValue valueWithRect:rect];
  
} 

-(void)mouseDragged:(NSEvent *)pTheEvent {
  
  NSPoint mousePointInWindow = [pTheEvent locationInWindow];
  NSPoint mousePointInView   = [self convertPoint:mousePointInWindow fromView:nil];
  SNPoint *point             = [[SNPoint alloc]initWithNSPoint:mousePointInView];
  
  NSRect rect = [rectVal rectValue];
  rect.size.width  = -1 * (rect.origin.x - point.x);
  rect.size.height = -1 * (rect.origin.y - point.y);
  rectVal = [NSValue valueWithRect:rect];
  
  [self setNeedsDisplay:YES];
  
} 

- (void)mouseUp:(NSEvent *)pTheEvent {
  
  NSPoint mousePointInWindow = [pTheEvent locationInWindow];
  NSPoint mousePointInView   = [self convertPoint:mousePointInWindow fromView:nil];
  SNPoint *point             = [[SNPoint alloc] initWithNSPoint:mousePointInView];
  
  NSScreen *mainScreen = [NSScreen mainScreen];
  NSRect rect = [rectVal rectValue];
  
  rect = [SNUtility normalizeRect:rect];
  
  rect.origin.y = mainScreen.frame.size.height - rect.origin.y;
  rect.size.height = - rect.size.height;
  NSRect resetRect = NSMakeRect(point.x, point.y, 0, 0);
  
  rectVal = [NSValue valueWithRect:resetRect];
  
  NSImage *captureImage = [SNUtility captureImageForRect:rect];
  
  [self captureComplete:captureImage];
}

- (void)keyDown:(NSEvent *)theEvent {
  if ([theEvent keyCode] == ESC_KEYCODE) {
    [delegate performSelector:@selector(viewCaptureCancelled)];
  }
}

- (void)cancelOperation:(id)sender
{
//  [delegate performSelector:@selector(viewCaptureCancelled)];
}


- (void)captureComplete:(NSImage *)captureImage {
  // redisplay the cursor
//  CGDisplayShowCursor(kCGDirectMainDisplay);
  
  // reset member data
  NSRect rect = NSMakeRect(0, 0, 0, 0);
  rectVal = [NSValue valueWithRect:rect];
  [self setNeedsDisplay:YES];
  
  [delegate performSelector:@selector(viewCaptureComplete:) withObject:captureImage];
}


- (void)drawRect:(NSRect)fullRect {
  NSGraphicsContext *graphicsContext = [NSGraphicsContext currentContext];
  CGContextRef      c                = (CGContextRef) [graphicsContext graphicsPort];
  CGContextClearRect(c, fullRect);
  
  // hide cursor
//  CGDisplayHideCursor(kCGDirectMainDisplay);
  
  // colour the background white
  [[NSColor colorWithCalibratedWhite:1.0 alpha:0.6] set];
  NSRectFill(fullRect);
  
  
  // draw dragged rectangle
  CGContextSetRGBStrokeColor(c, 24.0f/255, 224.0f/255, 168.0f/255, 1.0);
  CGContextSetLineWidth     (c, 2.0);
  CGContextSetRGBFillColor  (c, .0f, .0f, .0f, 0.0);
  NSRect rect = [rectVal rectValue];
  CGContextStrokeRect(c, rect);
  CGContextClearRect(c, rect);
  
  // draw crossHairs
  NSPoint mouse = [self convertPoint:[NSEvent mouseLocation] toView:self];
  // get current screen size for crosshair width/height
  NSEnumerator *screenEnum = [[NSScreen screens] objectEnumerator];
  NSScreen *currentScreen;
  while ((currentScreen = [screenEnum nextObject]) && !NSMouseInRect(mouse, [currentScreen frame], NO));
  
  CGFloat grey[4] = {0.2f, 0.2f, 0.2f, 0.8f};
  CGContextSetStrokeColor(c, grey);
  CGContextSetLineWidth (c, 1.0);
  CGContextBeginPath(c);
  CGContextMoveToPoint(c, 0, mouse.y);
  CGContextAddLineToPoint(c, currentScreen.frame.size.width, mouse.y);
  CGContextDrawPath(c, kCGPathStroke);
  CGContextBeginPath(c);
  CGContextMoveToPoint(c, mouse.x, 0);
  CGContextAddLineToPoint(c, mouse.x, currentScreen.frame.size.height);
  CGContextDrawPath(c, kCGPathStroke);
  
}

@end



