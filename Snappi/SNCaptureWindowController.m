//
//  SNCaptureViewController.m
//  Snappi
//
//  Created by Marshall Moutenot on 12/19/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import "SNCaptureWindowController.h"
#import "SNCaptureView.h"

@implementation SNCaptureWindowController

@synthesize delegate;
@synthesize captureWindow, captureView;

- (id)init {
  self = [super init];
  if (self) {
    // get current screen
    NSPoint mouseLoc = [NSEvent mouseLocation];
    NSEnumerator *screenEnum = [[NSScreen screens] objectEnumerator];
    NSScreen *currentScreen;
    while ((currentScreen = [screenEnum nextObject]) && !NSMouseInRect(mouseLoc, [currentScreen frame], NO));
    
    captureWindow = [[SNTransparentWindow alloc] initWithContentRect:[currentScreen frame] styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:currentScreen];
    
    captureView = [[SNCaptureView alloc] initWithFrame:[captureWindow frame]];
    [captureView setDelegate:self];
    [captureWindow setContentView:captureView];
    [captureWindow setReleasedWhenClosed:NO];
    
  }
  return self;
}

- (void)keyDown:(NSEvent *)theEvent {
  if ([theEvent keyCode] == ESC_KEYCODE) {
    [self viewCaptureCancelled];
  }
}
- (void)cancelOperation:(id)sender {
  [self viewCaptureCancelled];
}


- (void)showCaptureView {
  [captureWindow makeKeyAndOrderFront:NSApp];
}

- (void)viewCaptureCancelled {
  [captureWindow close];
}

- (void)viewCaptureComplete:(NSImage *)captureImage {
  [captureWindow close];
  [delegate performSelector:@selector(captureComplete:) withObject:captureImage];
}

@end
