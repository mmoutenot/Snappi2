//
//  SNChangeEvernoteNotebookController.h
//  Snappi
//
//  Created by Marshall Moutenot on 2/15/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SNChangeEvernoteNotebookController : NSWindowController

@property (weak) IBOutlet NSTextField *evernoteNotebookName;

- (IBAction)showButtonHandler:(id)sender;
- (IBAction)closeButtonHandler:(id)sender;
- (IBAction)changeButtonHandler:(id)sender;

@end
