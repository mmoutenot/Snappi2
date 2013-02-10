//
//  SNCaptureViewController.h
//  Snappi
//
//  Created by Marshall Moutenot on 12/19/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>
#import "SNTransparentWindow.h"
#import "SNCaptureView.h"

@interface SNCaptureWindowController : NSWindowController {
  id delegate;
}

@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) SNTransparentWindow *captureWindow;
@property (strong, nonatomic) SNCaptureView *captureView;

- (void)showCaptureView;
- (void)viewCaptureCancelled;
- (void)viewCaptureComplete:(NSImage *)captureImage;
- (void)keyDown:(NSEvent *)theEvent;
  
@end
