//
//  SNMenuController.m
//  Snappi
//
//  Created by Marshall Moutenot on 1/3/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import "SNAppDelegate.h"
#import "SNMenuController.h"
#import "SNUtility.h"
#import "SNEvernoteController.h"

@implementation SNMenuController

typedef enum {
  SM__INVALID_TAG     = -1,
  SM__CONNECT_TAG     =  0,
  SM__DESTINATION_TAG =  1,
  SM__OPTIONS_TAG     =  2,
  SM__EVERNOTE_TAG    =  3,
  SM__TWITTER_TAG     =  4,
  
  SM__EVERNOTE_CHANGE_NOTEBOOK_TAG = 5,
  SM__EVERNOTE_AUTH_TAG = 6
} SM__MenuItemTag;

- (id)init {
  self = [super init];
  if (self){
    _statusMenu = [[NSMenu alloc] init];
    
    NSMenuItem *takeScreenshotMenuItem = [[NSMenuItem alloc] initWithTitle:SM__TAKE_SCREENSHOT_TITLE action:@selector(showCaptureView) keyEquivalent:(@"S")];
    [_statusMenu addItem:takeScreenshotMenuItem];
    
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
    [_statusMenu addItem: connectMenuItem];
  }
  return self;
}

- (void) statusItemClicked:(NSMenuItem *) menuItem{
  // this opens the url in a browser, but I would prefer to recopy it into the clipboard...
  NSString *link = [menuItem toolTip];
  NSString *shortLink = [SNUtility shortenURL:link];
  [SNUtility addToClipboard:shortLink];
}

- (void) statsItemClicked:(NSMenuItem *) menuItem{
  NSString *statsLink = [NSString stringWithFormat:@"%@+", [menuItem toolTip]];
  NSURL *statsUrl = [[NSURL alloc] initWithString:statsLink];
  [[NSWorkspace sharedWorkspace] openURL:statsUrl];
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
  [self updateOptionMenuItem];
}

- (void) updateStatusMenuItemWithTag:(SM__MenuItemTag)connectionTag connectionName:(NSString *)connectionName {
  NSMenuItem *connectMenuItem = [_statusMenu itemWithTag:SM__CONNECT_TAG];
  NSMenu     *connectSubMenu  = connectMenuItem.submenu;
  for (NSMenuItem *item in [connectSubMenu itemArray]) {
    [item setState:NSOffState];
  }
  NSMenuItem *connectionMenuItem = [connectSubMenu itemWithTag:connectionTag];
  [connectionMenuItem setState:NSOnState];
  NSMenuItem *destinationMenuItem = [_statusMenu itemWithTag:SM__DESTINATION_TAG];
  destinationMenuItem.title = [NSString stringWithFormat:@"Destination: %@", connectionName];
}

- (void) updateOptionMenuItem {
  SNAppDelegate *appDelegate = (SNAppDelegate *)[[NSApplication sharedApplication] delegate];
  
  NSMenuItem *optionMenuItem = [_statusMenu itemWithTag:SM__OPTIONS_TAG];
  optionMenuItem.title = [NSString stringWithFormat:@"%@ Options", appDelegate.destination.name];
  optionMenuItem.submenu = [self generateOptionsSubMenuForConnectionName: appDelegate.destination.name];
}

- (NSMenu *) generateOptionsSubMenuForConnectionName:(NSString *)connectionName {
  NSMenu *m = [[NSMenu alloc] init];
  if ([connectionName isEqualToString:EV__NAME]){
    SNEvernoteController *ec = [SNEvernoteController sharedInstance];
    // change notebook
    NSMenuItem *changeNotebookMenuItem = [[NSMenuItem alloc] initWithTitle:@"Change Notebook" action:@selector(changeNotebookMenuCallback) keyEquivalent:@""];
    [changeNotebookMenuItem setTag:SM__EVERNOTE_CHANGE_NOTEBOOK_TAG];
    [m addItem:changeNotebookMenuItem];
    
    // logout
    SEL authMenuCallback;
    NSString *authTitle = @"Log In";
    if(ec.auth != nil){
      authMenuCallback = @selector(evernoteSignOutCallback);
      authTitle = @"Log Out";
    } else {
      authMenuCallback = @selector(evernoteShowLoginCallback);
      NSLog(@"toggling selector to log in");
    }
    NSMenuItem *authMenuItem = [[NSMenuItem alloc] initWithTitle:authTitle action:authMenuCallback keyEquivalent:@""];
    [authMenuItem setTag:SM__EVERNOTE_AUTH_TAG];
    [m addItem:authMenuItem];
  }
  return m;
}

- (void) addDestinationMenuItems {
  SNAppDelegate *appDelegate = (SNAppDelegate *)[[NSApplication sharedApplication] delegate];
  NSMenuItem *destinationMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Destination: %@", appDelegate.destination.name] action:nil keyEquivalent:@""];
  destinationMenuItem.tag = SM__DESTINATION_TAG;
  [_statusMenu addItem: destinationMenuItem];
  
  NSMenuItem *optionsMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ Options", appDelegate.destination.name] action:nil keyEquivalent:@""];
  optionsMenuItem.tag = SM__OPTIONS_TAG;
  [_statusMenu addItem: optionsMenuItem];
  
  NSMenu *optionsSubMenu = [self generateOptionsSubMenuForConnectionName:appDelegate.destination.name];
  optionsMenuItem.submenu = optionsSubMenu;
  
  NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Exit" action:@selector(terminate:) keyEquivalent:@"q"];
  [_statusMenu addItem: quitMenuItem];
  
  [_statusMenu addItem: [NSMenuItem separatorItem]];
}


@end
