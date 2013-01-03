//
//  SNServiceSelectorWindowController.h
//  Snappi
//
//  Created by Marshall Moutenot on 12/23/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SNTransparentWindow.h"
#import "SNServiceSelectorView.h"

@interface SNServiceSelectorWindowController : NSWindowController

@property (strong) IBOutlet NSWindow *serviceSelectWindow;
@property (weak) IBOutlet NSView *serviceSelectView;

- (void)showServiceSelectWithServices:(NSDictionary *)services;
  
@end
