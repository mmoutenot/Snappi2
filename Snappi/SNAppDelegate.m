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
#import "SNUtility.h"
#import "SNFile.h"
#import "SNUploadClosure.h"

@implementation SNAppDelegate

@synthesize temporaryPath;
@synthesize captureWindowController, serviceSelectorWindowController;
@synthesize statusMenu, statusItem, statusView;
@synthesize connections;
@synthesize menuController, notificationController;
@synthesize fileQueue;
@synthesize destination;

typedef enum {
  SM__INVALID_TAG     = -1,
  SM__CONNECT_TAG     =  0,
  SM__DESTINATION_TAG =  1,
  SM__EVERNOTE_TAG    =  2,
  SM__TWITTER_TAG     =  3
} SM__MenuItemTag;

EventHotKeyRef escHotKeyRef;
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
  [NSTemporaryDirectory() stringByAppendingPathComponent: @"snappitempdirectory.XXXXXX"];
  const char *tempDirectoryTemplateCString = [tempDirectoryTemplate fileSystemRepresentation];
  char *tempDirectoryNameCString = (char *)malloc(strlen(tempDirectoryTemplateCString) + 1);
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
  
  // register cancel screenshot
  myHotKeyID.signature='mhk2';
  myHotKeyID.id=2;
  RegisterEventHotKey(ESC_KEYCODE, 0, myHotKeyID,
                      GetApplicationEventTarget(), 0, &myHotKeyRef);
  escHotKeyRef = myHotKeyRef;
}

OSStatus screenshotHotKeyHandler(EventHandlerCallRef nextHandler, EventRef event, void *userData){
  EventHotKeyID hkCom;
  OSStatus result = noErr;
  SNAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
  
  GetEventParameter(event,kEventParamDirectObject,typeEventHotKeyID,NULL, sizeof(hkCom),NULL,&hkCom);

  // switch to route based on shortcut pressed. Currently only one
  switch (hkCom.id){
    default:
      result = noErr;
      break;
    case 1:
      [appDelegate showCaptureView];
      result = noErr;
      break;
    case 2:
      [appDelegate.captureWindowController viewCaptureCancelled];
      UnregisterEventHotKey(escHotKeyRef);
      result = noErr;
      break;
  }
  return result;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  
  [self registerScreenshotHotkey];
  [self createTemporaryDirectory];

}

NSString * const MDFirstRunKey               = @"MDFirstRun";
NSString * const MDShouldShowInspectorKey    = @"MDShouldShowInspector";
NSString * const MDBrowserShouldShowIconsKey = @"MDBrowserShouldShowIcons";

-(void)awakeFromNib{
  // sets up defaults so that we know the first time the app is run
  NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
  [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:MDFirstRunKey];
  [defaultValues setObject:[NSNumber numberWithBool:NO ] forKey:MDShouldShowInspectorKey];
  [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:MDBrowserShouldShowIconsKey];

  // Load default defaults
  [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
  [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues];

  // if the statusBar object hasn't been initialized, we popuate objects
  if (!statusMenu){
    
    statusMenu = [[NSMenu alloc] init];
    
    NSMenuItem *connectMenuItem = [[NSMenuItem alloc] initWithTitle:SM__CONNECT_TITLE action:nil keyEquivalent:@""];
    [connectMenuItem setTag:SM__CONNECT_TAG];
    
    NSMenu *connectSubMenu = [[NSMenu alloc] init];
    
    NSMenuItem *connectEvernoteMenuItem = [[NSMenuItem alloc] initWithTitle:EV__NAME action:@selector(connectToEvernote) keyEquivalent:@"" ];
    [connectEvernoteMenuItem setTag:SM__EVERNOTE_TAG];
    [connectSubMenu addItem:connectEvernoteMenuItem];
    
    NSMenuItem *connectTwitterMenuItem = [[NSMenuItem alloc] initWithTitle:TW__NAME action:@selector(connectToTwitter) keyEquivalent:@"" ];
    [connectTwitterMenuItem setTag:SM__TWITTER_TAG];
    [connectSubMenu addItem:connectTwitterMenuItem];
    
    connectMenuItem.submenu = connectSubMenu;
    [statusMenu addItem: connectMenuItem];
    
    // try to authenticate with services
    [self populateConnectionsFromKeychain];
    [self setDestinationFromString: [[NSUserDefaults standardUserDefaults] valueForKey:@"destination"]];
    
    NSMenuItem *destinationMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Destination: %@", destination.name] action:nil keyEquivalent:@""];
    destinationMenuItem.tag = SM__DESTINATION_TAG;
    [statusMenu addItem: destinationMenuItem];
    
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

- (void) setDestinationFromString: (NSString *)destinationString {
  if ([destinationString isEqualToString:EV__NAME])
    destination = [connections objectForKey:EV__NAME];
  else if ([destinationString isEqualToString:TW__NAME])
    destination = [connections objectForKey:TW__NAME];
}

- (void) populateConnectionsFromKeychain {
  // Evernote
  SNService *evernote = [[SNService alloc] init];
  SNEvernoteController *e = [SNEvernoteController sharedInstance];
  evernote.controller = e;
  [evernote setName:EV__NAME];
  destination = evernote;
  [connections setValue:evernote forKey:EV__NAME];
  
  // Twitter
  SNService *twitter = [[SNService alloc] init];
  NSSharingService *twitterController = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
  twitter.controller = twitterController;
  twitter.name = TW__NAME;
  [connections setValue:twitter forKey:TW__NAME];
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
  if ([connectionName isEqualToString:TW__NAME])          return SM__TWITTER_TAG;
  return SM__INVALID_TAG;
}

- (void)updateStatusMenuWithConnectionName:(NSString *)connectionName {
  SM__MenuItemTag tag = [self getTagForConnectionName:connectionName];
  [self updateStatusMenuItemWithTag:tag connectionName:connectionName];
}

- (void)updateStatusMenuItemWithTag:(SM__MenuItemTag)connectionTag connectionName:(NSString *)connectionName {
  NSMenuItem *connectMenuItem = [statusMenu itemWithTag:SM__CONNECT_TAG];
  NSMenu     *connectSubMenu  = connectMenuItem.submenu;
  for (NSMenuItem *item in [connectSubMenu itemArray]) {
    [item setState:NSOffState];
  }
  NSMenuItem *connectionMenuItem = [connectSubMenu itemWithTag:connectionTag];
  [connectionMenuItem setState:NSOnState];
  NSMenuItem *destinationMenuItem = [statusMenu itemWithTag:SM__DESTINATION_TAG];
  destinationMenuItem.title = [NSString stringWithFormat:@"Destination:%@", connectionName];
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
  
  if ([destination.name isEqualToString:EV__NAME]){
    NSString *uuid = [SNUtility UUIDString];
    NSString *path = [NSString stringWithFormat:@"%@/%@.png", temporaryPath, uuid];
    [SNUtility writeImage:captureImage toPath:path];
    SNService *evernote = [connections objectForKey:EV__NAME];
    SNEvernoteController *evernoteController = evernote.controller;
    
    SNFile *file = [[SNFile alloc] initWithPath:path];
    SNUploadClosure *uploadCl = [[SNUploadClosure alloc] init];
    
    [uploadCl setFiles:[[NSMutableArray alloc] initWithObjects:file, nil]];
    [uploadCl setIsScreenshot:YES];

  //  [evernoteController uploadScreenshot:files];
    [evernoteController performSelectorInBackground:@selector(upload:) withObject:uploadCl];
  }
  else if ([destination.name isEqualToString:TW__NAME]){
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:@"Shared via Snappi"];
    NSArray * shareItems = [NSArray arrayWithObjects:text, captureImage, nil];
    NSSharingService *twitter = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    twitter.delegate = self;
    [twitter performWithItems:shareItems];
  }

}

// connection functions

- (void)connectToEvernote {
  // create a service object with appropriate controller and badge
  SNService *evernote;
  if (![connections objectForKey:EV__NAME]){
    evernote = [[SNService alloc] init];
    SNEvernoteController *evernoteController = [[SNEvernoteController alloc] init];
    NSString *evernoteBadgePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:EV__BADGE_NAME];
    NSImage *evernoteBadge = [[NSImage alloc] initWithContentsOfFile:evernoteBadgePath];
    evernote.controller = evernoteController;
    evernote.badge = evernoteBadge;
    evernote.name = EV__NAME;
    [connections setObject:evernote forKey:EV__NAME];
    [evernoteController showLogin];
  } else {
    evernote = [connections objectForKey:EV__NAME];
    [self connectToServiceSuccessWithName:EV__NAME];
  }
  destination = evernote;
}

- (void)connectToTwitter {
  SNService *twitter = [[SNService alloc] init];
  NSSharingService *twitterController = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
  twitter.controller = twitterController;
  twitter.name = TW__NAME;
  [connections setValue:twitter forKey:TW__NAME];
  destination = twitter;
  
  [self updateStatusMenuWithConnectionName:TW__NAME];
}

@end
