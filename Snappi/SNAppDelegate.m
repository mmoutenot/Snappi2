//
//  SNAppDelegate.m
//  Snappi
//
//  Created by Marshall Moutenot on 12/14/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import <Carbon/Carbon.h>

#import <Crashlytics/Crashlytics.h>

#import "SNAppDelegate.h"
#import "SNTransparentWindow.h"
#import "SNEvernoteController.h"
#import "SNUtility.h"
#import "SNFile.h"

@implementation SNAppDelegate

EventHotKeyRef escHotKeyRef;
OSStatus screenshotHotKeyHandler(EventHandlerCallRef nextHandler,
                         EventRef rvent,
                         void *userData);

- (id)init {
  self = [super init];
  if (self) {
    // initialize empty array of connections
    _connections = [[NSMutableDictionary alloc] init];
    _changeEvernoteNotebookController = [[SNChangeEvernoteNotebookController alloc] initWithWindowNibName:@"ChangeEvernoteNotebook"];
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
  _temporaryPath =  [[NSFileManager defaultManager] stringWithFileSystemRepresentation:tempDirectoryNameCString length:strlen(result)];
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
  RegisterEventHotKey(1, cmdKey+shiftKey, myHotKeyID,
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
  SNAppDelegate *appDelegate = (SNAppDelegate *)[[NSApplication sharedApplication] delegate];
  
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
  [[Crashlytics sharedInstance] setDebugMode:YES];
  [Crashlytics startWithAPIKey:@"a8a7adb595706b0c075c05c2b74b04a08ceb951d"];
  
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
  if (!_statusMenuController){
    
    _statusMenuController = [[SNMenuController alloc] init];
    
    // try to authenticate with services
    [self populateConnectionsFromKeychain];
    [self setDestinationFromString: [[NSUserDefaults standardUserDefaults] objectForKey:@"destination"]];
    
    [_statusMenuController addDestinationMenuItems];
    

    // Create an NSStatusItem.
    float width = 18.0;
    float height = [[NSStatusBar systemStatusBar] thickness];
    NSRect viewFrame = NSMakeRect(0, 0, width, height);
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:width];
    _statusView = [[SNDroppableView alloc] initWithFrame:viewFrame];
    [_statusView setMenu:_statusMenuController.statusMenu];
    [_statusView setStatusItem:_statusItem];
    NSString *inFilePath = [[NSBundle mainBundle] pathForResource: @"snappi_icon_18" ofType:@"png"];
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:inFilePath];
    [_statusView setImage: img];
//    NSString *inFilePathB = [[NSBundle mainBundle] pathForResource: @"snappi_icon_g_18" ofType:@"png"];
//    NSImage *imgB = [[NSImage alloc] initWithContentsOfFile:inFilePathB];
//    [statusView setAltImage:imgB];
    [_statusItem setView:_statusView];
    
  }
  
}

- (void) setDestinationFromString: (NSString *)destinationString {
  if ([destinationString isEqualToString:EV__NAME])
    _destination = [_connections objectForKey:EV__NAME];
  else if ([destinationString isEqualToString:TW__NAME])
    _destination = [_connections objectForKey:TW__NAME];
}

- (void) populateConnectionsFromKeychain {
  // Evernote
  SNService *evernote = [[SNService alloc] init];
  SNEvernoteController *e = [SNEvernoteController sharedInstance];
  evernote.controller = e;
  [evernote setName:EV__NAME];
  _destination = evernote;
  [_connections setValue:evernote forKey:EV__NAME];
  
  // Twitter
  SNService *twitter = [[SNService alloc] init];
  NSSharingService *twitterController = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
  twitter.controller = twitterController;
  twitter.name = TW__NAME;
  [_connections setValue:twitter forKey:TW__NAME];
}

- (void)showCaptureView {
  if (!_captureWindowController){
    _captureWindowController = [[SNCaptureWindowController alloc] init];
    [_captureWindowController setDelegate:self];
  }
  [_captureWindowController showCaptureView];
}

- (BOOL)canAuthorizeConnectionWithName:(NSString *)connectionName {
  id conn = [_connections objectForKey:connectionName];
  if ([[[conn controller] auth] canAuthorize]) return YES;
  return NO;
}



- (void)connectToServiceSuccessWithName:(NSString *)connectionName {
  [_statusMenuController updateStatusMenuWithConnectionName:connectionName];
  // TODO:notify user that connection successful
}


- (void)captureComplete:(NSImage *)captureImage{
  NSString *uuid = [SNUtility UUIDString];
  NSString *path = [NSString stringWithFormat:@"%@/%@.png", _temporaryPath, uuid];
  [SNUtility writeImage:captureImage toPath:path];
  
  SNFile *file = [[SNFile alloc] initWithPath:path];
  SNUploadClosure *uploadCl = [[SNUploadClosure alloc] init];
  
  [uploadCl.files addObject:file];
  [uploadCl setIsScreenshot:YES];
  
//  [self uploadDispatcher:uploadCl];
}

- (void)uploadDispatcher:(SNUploadClosure *)uploadCl{
  if ([_destination.name isEqualToString:EV__NAME]){
    [_destination.controller performSelectorInBackground:@selector(upload:) withObject:uploadCl];
  }
  else if ([_destination.name isEqualToString:TW__NAME]){
    // Twitter will currently only support images
    if (uploadCl.isScreenshot == YES && [uploadCl.files count] > 0){
      NSAttributedString *text = [[NSAttributedString alloc] initWithString:@"\n\n@Snappi"];
      SNFile  *captureFile = [uploadCl.files objectAtIndex:0];
      NSImage *captureImage = [[NSImage alloc] initWithContentsOfFile: captureFile.path];
      NSArray *shareItems = [NSArray arrayWithObjects:text, captureImage, nil];
      NSSharingService *twitter = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
      twitter.delegate = self;
      [twitter performWithItems:shareItems];
    }
  }
  
}

// connection functions

- (void)connectToEvernote {
  // create a service object with appropriate controller and badge
  SNService *evernote;
  if (![_connections objectForKey:EV__NAME]){
    evernote = [[SNService alloc] init];
    SNEvernoteController *evernoteController = [[SNEvernoteController alloc] init];
    NSString *evernoteBadgePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:EV__BADGE_NAME];
    NSImage *evernoteBadge = [[NSImage alloc] initWithContentsOfFile:evernoteBadgePath];
    evernote.controller = evernoteController;
    evernote.badge = evernoteBadge;
    evernote.name = EV__NAME;
    [_connections setObject:evernote forKey:EV__NAME];
    [evernoteController showLogin];
  } else {
    evernote = [_connections objectForKey:EV__NAME];
    [self connectToServiceSuccessWithName:EV__NAME];
  }
  _destination = evernote;
  [[NSUserDefaults standardUserDefaults] setObject:EV__NAME forKey:@"destination"];
  
  [_statusMenuController updateStatusMenuWithConnectionName:EV__NAME];
}

- (void)connectToTwitter {
  SNService *twitter = [[SNService alloc] init];
  NSSharingService *twitterController = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
  twitter.controller = twitterController;
  twitter.name = TW__NAME;
  [_connections setValue:twitter forKey:TW__NAME];
  _destination = twitter;
  [[NSUserDefaults standardUserDefaults] setObject:TW__NAME forKey:@"destination"];
  
  [_statusMenuController updateStatusMenuWithConnectionName:TW__NAME];
}

// Evernote option handlers
- (void)showChangeEvernoteNotebookWindowController{
  [_changeEvernoteNotebookController loadWindow];
  [_changeEvernoteNotebookController showWindow:self];
}

// Menu Callbacks
- (void) changeNotebookMenuCallback {
  SNAppDelegate *ad = (SNAppDelegate *)[[NSApplication sharedApplication] delegate];
  [ad showChangeEvernoteNotebookWindowController];
}

- (void) evernoteSignOutCallback {
  SNService *es = [_connections objectForKey:EV__NAME];
  SNEvernoteController *ec = [es controller];
  [ec signOut];
  [_statusMenuController updateStatusMenuWithConnectionName:EV__NAME];
}

- (void) evernoteShowLoginCallback {
  SNService *es = [_connections objectForKey:EV__NAME];
  SNEvernoteController *ec = [es controller];
  [ec showLogin];
}

@end
