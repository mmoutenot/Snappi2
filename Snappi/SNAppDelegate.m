//
//  SNAppDelegate.m
//  Snappi
//
//  Created by Marshall Moutenot on 12/14/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import <Carbon/Carbon.h>

#import "SNAppDelegate.h"
#import "SNTransparentWindow.h"
#import "SNEvernoteController.h"
#import "SNService.h"
#import "SNUtility.h"
#import "SNFile.h"

@implementation SNAppDelegate

@synthesize temporaryPath;
@synthesize captureWindowController, serviceSelectorWindowController;
@synthesize statusMenu, statusItem, statusView;
@synthesize connections;
@synthesize menuController, notificationController;

typedef enum {
  SM__INVALID_TAG = -1,
  SM__CONNECT_TAG =  0,
  SM__EVERNOTE_TAG
} SM__MenuItemTag;


OSStatus screenshotHotKeyHandler(EventHandlerCallRef nextHandler,
                         EventRef rvent,
                         void *userData);

- (id)init {
  self = [super init];
  if (self) {
    // initialize empty array of connections
    connections = [[NSMutableDictionary alloc] init];
    menuController = [[SNMenuController alloc] init];
    notificationController = [[SNNotificationController alloc] init];
  }
  return self;
}

- (void)createTemporaryDirectory {
  // gets the temporary directory for storing md5 hashes and screenshots
  NSString *tempDirectoryTemplate =
  [NSTemporaryDirectory() stringByAppendingPathComponent:
   @"snappitempdirectory.XXXXXX"];
  const char *tempDirectoryTemplateCString =
  [tempDirectoryTemplate fileSystemRepresentation];
  char *tempDirectoryNameCString =
  (char *)malloc(strlen(tempDirectoryTemplateCString) + 1);
  strcpy(tempDirectoryNameCString, tempDirectoryTemplateCString);
  
  char *result = mkdtemp(tempDirectoryNameCString);
  if (!result) {
    NSLog(@"Couldn't create the temp dir. Things may not work...");
  }
  temporaryPath =  [[NSFileManager defaultManager] stringWithFileSystemRepresentation:tempDirectoryNameCString length:strlen(result)];
  free(tempDirectoryNameCString);
}

- (void)registerScreenshotHotkey {
  // register screenshot hotkey
  EventHotKeyRef myHotKeyRef;
  EventHotKeyID myHotKeyID;
  EventTypeSpec eventType;
  eventType.eventClass=kEventClassKeyboard;
  eventType.eventKind=kEventHotKeyPressed;
  InstallApplicationEventHandler(&screenshotHotKeyHandler,1,&eventType,NULL,NULL);
  myHotKeyID.signature='mhk1';
  myHotKeyID.id=1;
  RegisterEventHotKey(1, controlKey+cmdKey, myHotKeyID,
                      GetApplicationEventTarget(), 0, &myHotKeyRef);
}

OSStatus screenshotHotKeyHandler(EventHandlerCallRef nextHandler, EventRef event, void *userData){
  OSStatus result = noErr;
  
  SNAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
 [appDelegate showCaptureView];
  
  return result;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  
  [self registerScreenshotHotkey];
  [self createTemporaryDirectory];

}

-(void)awakeFromNib{
  // if the statusBar object hasn't been initialized, we popuate objects
  if (!statusMenu){
    
    statusMenu = [[NSMenu alloc] init];
    
    NSMenuItem *connectMenuItem = [[NSMenuItem alloc] initWithTitle:SM__CONNECT_TITLE action:nil keyEquivalent:@""];
    [connectMenuItem setTag:SM__CONNECT_TAG];
    
    NSMenu *connectSubMenu = [[NSMenu alloc] init];
    
    NSMenuItem *connectEvernoteMenuItem = [[NSMenuItem alloc] initWithTitle:EV__NAME action:@selector(connectToEvernote) keyEquivalent:@"" ];
    [connectEvernoteMenuItem setTag:SM__EVERNOTE_TAG];
    
    [connectSubMenu addItem:connectEvernoteMenuItem];
    connectMenuItem.submenu = connectSubMenu;
    [statusMenu addItem: connectMenuItem];
    
    NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Exit" action:@selector(terminate:) keyEquivalent:@"q"];
    [statusMenu addItem: quitMenuItem];
    
    [statusMenu addItem: [NSMenuItem separatorItem]];

    // Create an NSStatusItem.
    float width = 18.0;
    float height = [[NSStatusBar systemStatusBar] thickness];
    NSRect viewFrame = NSMakeRect(0, 0, width, height);
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:width];
    statusView = [[SNDroppableView alloc] initWithFrame:viewFrame];
    [statusView setMenu:statusMenu];
    [statusView setStatusItem:statusItem];
    NSString *inFilePath = [[NSBundle mainBundle] pathForResource: @"snappi_icon_18" ofType:@"png"];
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:inFilePath];
    [statusView setImage: img];
//    NSString *inFilePathB = [[NSBundle mainBundle] pathForResource: @"snappi_icon_g_18" ofType:@"png"];
//    NSImage *imgB = [[NSImage alloc] initWithContentsOfFile:inFilePathB];
//    [statusView setAltImage:imgB];
    [statusItem setView:statusView];
  }
}

- (void)showCaptureView {
  if (!captureWindowController){
    captureWindowController = [[SNCaptureWindowController alloc] init];
    [captureWindowController setDelegate:self];
  }
  [captureWindowController showCaptureView];
}

- (BOOL)canAuthorizeConnectionWithName:(NSString *)connectionName {
  id conn = [connections objectForKey:connectionName];
  if ([[[conn controller] auth] canAuthorize]) return YES;
  return NO;
}

- (SM__MenuItemTag)getTagForConnectionName:(NSString *)connectionName {
  if ([connectionName isEqualToString:SM__CONNECT_TITLE]) return SM__CONNECT_TAG;
  if ([connectionName isEqualToString:EV__NAME])          return SM__EVERNOTE_TAG;
  return SM__INVALID_TAG;
}

- (void)updateStatusMenuWithConnectionName:(NSString *)connectionName {
  SM__MenuItemTag tag = [self getTagForConnectionName:connectionName];
  [self updateStatusMenuItemWithTag:tag connectionName:connectionName];
}

- (void)updateStatusMenuItemWithTag:(SM__MenuItemTag)connectionTag connectionName:(NSString *)connectionName {
  if([self canAuthorizeConnectionWithName:connectionName]) {
    NSMenuItem *connectMenuItem = [statusMenu itemWithTag:SM__CONNECT_TAG];
    NSMenu     *connectSubMenu  = connectMenuItem.submenu;
    NSMenuItem *connectionMenuItem = [connectSubMenu itemWithTag:connectionTag];
    [connectionMenuItem setState:NSOnState];
  }
}

- (void)connectToServiceSuccessWithName:(NSString *)connectionName {
  [self updateStatusMenuWithConnectionName:connectionName];
  // TODO:notify user that connection successful
}

- (void)captureComplete:(NSImage *)captureImage{
//  if (!serviceSelectorWindowController){
//    serviceSelectorWindowController = [[SNServiceSelectorWindowController alloc] init];
//  }
//  [serviceSelectorWindowController showServiceSelectWithServices:connections];
//  serviceSelectorWindowController = [[SNServiceSelectorWindowController alloc] initWithWindowNibName:@"ServiceSelect"];
//  [serviceSelectorWindowController showServiceSelectWithServices:connections];
  
  NSString *uuid = [SNUtility UUIDString];
  NSString *path = [NSString stringWithFormat:@"%@/%@.png", temporaryPath, uuid];
  [SNUtility writeImage:captureImage toPath:path];
  SNService *evernote = [connections objectForKey:EV__NAME];
  SNEvernoteController *evernoteController = evernote.controller;
  
  SNFile *file = [[SNFile alloc] initWithPath:path];
  NSArray *files = [[NSArray alloc] initWithObjects:file, nil];
  [evernoteController upload:files isScreenshot:YES];
}

// connection functions

- (void)connectToEvernote {
  // create a service object with appropriate controller and badge
  SNService *evernote = [[SNService alloc] init];
  SNEvernoteController *evernoteController = [[SNEvernoteController alloc] init];
  [evernoteController setDelegate:self];
  NSString *evernoteBadgePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:EV__BADGE_NAME];
  NSImage *evernoteBadge = [[NSImage alloc] initWithContentsOfFile:evernoteBadgePath];
  evernote.controller = evernoteController;
  evernote.badge = evernoteBadge;
  [connections setObject:evernote forKey:EV__NAME];
  
  [evernoteController showLogin];
}

@end
