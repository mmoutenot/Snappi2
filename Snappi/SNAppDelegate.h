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
#import "SNUploadClosure.h"
#import "SNChangeEvernoteNotebookController.h"
#import "SNMenuController.h"

@interface SNAppDelegate : NSObject <NSApplicationDelegate, NSSharingServiceDelegate>

@property (strong, nonatomic) NSString *temporaryPath;

@property (strong, nonatomic) SNCaptureWindowController         *captureWindowController;
@property (strong, nonatomic) SNServiceSelectorWindowController *serviceSelectorWindowController;

@property (strong, nonatomic) SNMenuController    *statusMenuController;
@property (strong, nonatomic) NSStatusItem        *statusItem;
@property (strong, nonatomic) SNDroppableView     *statusView;
@property (strong, nonatomic) NSMutableDictionary *connections;

@property (strong, nonatomic) SNFileQueue *fileQueue;

@property (strong, nonatomic) SNService *destination;

@property (strong, nonatomic) SNUploadClosure *currentUpload;

- (void)connectToServiceSuccessWithName:(NSString *)connectionName;
- (void)connectToServiceFailureWithName:(NSString *)connectionName;
- (void)showCaptureView;
- (void)captureComplete:(NSImage *)captureImage;
- (void)uploadDispatcher:(SNUploadClosure *)uploadCl;
- (void)registerScreenshotHotkey;
- (void)showChangeEvernoteNotebookWindowController;
  
// evernote option functions and outlets
@property (strong, nonatomic) SNChangeEvernoteNotebookController *changeEvernoteNotebookController;

  
  
@end
