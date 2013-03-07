//
//  SNNotificationController.m
//  Snappi
//
//  Created by Marshall Moutenot on 1/3/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import "SNNotificationController.h"
#import "SNServiceSelectViewController.h"

#import "SNAppDelegate.h"

@implementation SNNotificationController

@synthesize evernoteView, attachedWindow;

static SNNotificationController* sharedNotificationController = nil;

+ (SNNotificationController *)sharedNotificationController{
  @synchronized([SNNotificationController class]) {
    if (!sharedNotificationController) {
      sharedNotificationController = [[self alloc] init];
      [[NSBundle mainBundle] loadNibNamed:@"EvernoteView" owner:NSApp topLevelObjects:nil];
    }
    return sharedNotificationController;
  }
  return nil;
}

- (id) init {
  self = [super init];
  if (self) {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [GrowlApplicationBridge setGrowlDelegate:self];
  }
  return self;
}

- (void)showNotificationWithTitle:(NSString *) title informationText:(NSString *)infoText {
  NSUserNotification *notification = [[NSUserNotification alloc] init];
  notification.title = title;
  notification.informativeText = infoText;
  notification.soundName = nil;
//  [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
  [GrowlApplicationBridge notifyWithTitle:title description:infoText notificationName:@"notification" iconData:nil priority:0 isSticky:NO clickContext:nil];
  NSLog(@"Notification Fired");
//  NSRect frame = NSMakeRect(0, 0, 250, 250);
//  NSView *testView = [[NSView alloc] initWithFrame:frame];
  SNServiceSelectViewController* sC = [[SNServiceSelectViewController alloc] initWithNibName:@"SNServiceSelectViewController" bundle:nil];
  
  [self showAttachedWindowAtStatusViewWithView:[sC view]];
}

- (void)showNotificationWithServiceSelect {
  
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
  return YES;
}

- (void)showAttachedWindowAtStatusViewWithView:(NSView *)view
{
  SNAppDelegate *appDelegate = (SNAppDelegate *)[[NSApplication sharedApplication] delegate];
  
  NSRect frame = [[appDelegate.statusView window] frame];
  NSPoint pt = NSMakePoint(NSMidX(frame), NSMinY(frame));
  
  // Attach/detach window.
  if (attachedWindow) [self hideAttachedWindow];
  if (!attachedWindow) {
//    NSWindow *containerWindow = [[NSWindow alloc] initWithContentRect:attachedWindow.frame styleMask:NSBorderlessWindowMask backing:NSWindowBackingLocationDefault defer:NO screen:nil];
//    [containerWindow makeKeyAndOrderFront:nil];
    NSPoint initialPt = NSMakePoint(pt.x, pt.y-frame.size.height);
    attachedWindow = [[SNAttachedWindow alloc] initWithView:view
                                            attachedToPoint:initialPt
                                                   inWindow:nil
                                                     onSide:MAPositionBottom
                                                 atDistance:5.0];
//    [attachedWindow fadeInAndMakeKeyAndOrderFront:YES];
//    [containerWindow addChildWindow:attachedWindow ordered:NSWindowAbove];
//    [attachedWindow setAlphaValue:0.0];
//    [NSAnimationContext beginGrouping];
//    [[NSAnimationContext currentContext] setDuration:0.5];
    [attachedWindow makeKeyAndOrderFront:nil];
//    [attachedWindow setLevel:NSFloatingWindowLevel];
//    [[attachedWindow animator] setAlphaValue:1.0];
//    [NSAnimationContext endGrouping];
    [attachedWindow setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
//    [[attachedWindow animator] setAlphaValue:1.f];
//    NSRect new = NSMakeRect(0, 0, 500, 500);
//    [attachedWindow setFrame:new display:YES animate:YES];
  }
}

- (void)hideAttachedWindow{
  if(attachedWindow){
    [attachedWindow orderOut:self];
    attachedWindow = nil;
  }
}

@end
