//
//  SNAppDelegate.h
//  Snappi
//
//  Created by Marshall Moutenot on 12/14/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SNCaptureWindowController.h"
#import "SNServiceSelectorWindowController.h"
#import "SNDroppableView.h"
#import "SNMenuController.h"
#import "SNNotificationController.h"
#import "SNFileQueue.h"
#import "SNService.h"

@interface SNAppDelegate : NSObject <NSApplicationDelegate, NSSharingServiceDelegate>
{
  NSString *temporaryPath;
  
  SNCaptureWindowController *captureWindowController;
  
  NSMenu              *statusMenu;
  NSStatusItem        *statusItem;
  SNDroppableView     *statusView;
  NSMutableDictionary *connections;
  
  SNMenuController *menuController;
  SNNotificationController *notoficationController;
  
  SNFileQueue *fileQueue;
  
  SNService *destination;
}

@property (strong, nonatomic) NSString *temporaryPath;

@property (strong, nonatomic) SNCaptureWindowController         *captureWindowController;
@property (strong, nonatomic) SNServiceSelectorWindowController *serviceSelectorWindowController;

@property (strong, nonatomic) NSMenu              *statusMenu;
@property (strong, nonatomic) NSStatusItem        *statusItem;
@property (strong, nonatomic) SNDroppableView     *statusView;
@property (strong, nonatomic) NSMutableDictionary *connections;

@property (strong, nonatomic) SNMenuController         *menuController;
@property (strong, nonatomic) SNNotificationController *notificationController;

@property (strong, nonatomic) SNFileQueue *fileQueue;

@property (strong, nonatomic) SNService *destination;

- (void)connectToServiceSuccessWithName:(NSString *)connectionName;
- (void)connectToServiceFailureWithName:(NSString *)connectionName;
- (void)showCaptureView;
- (void)captureComplete:(NSImage *)captureImage;
- (void)registerScreenshotHotkey;
  
@end
