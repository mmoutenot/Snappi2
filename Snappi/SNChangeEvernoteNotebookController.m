//
//  SNChangeEvernoteNotebookController.m
//  Snappi
//
//  Created by Marshall Moutenot on 2/15/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import "SNChangeEvernoteNotebookController.h"
#import "SNAppDelegate.h"
#import "SNService.h"
#import "SNEvernoteController.h"

@interface SNChangeEvernoteNotebookController ()

@end

@implementation SNChangeEvernoteNotebookController

@synthesize evernoteNotebookName;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)showButtonHandler:(id)sender{
  [self showWindow:sender];
}

- (IBAction)closeButtonHandler:(id)sender{
  NSLog(@"Closing window");
  [self.window close];
}

- (IBAction)changeButtonHandler:(id)sender{
  SNAppDelegate *appDelegate = (SNAppDelegate *)[[NSApplication sharedApplication] delegate];
  SNService *evernote = [appDelegate.connections objectForKey:EV__NAME];
  SNEvernoteController *evernoteController = evernote.controller;
  [self.window close];
}

@end
