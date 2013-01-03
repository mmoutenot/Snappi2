//
//  SNMenuController.m
//  Snappi
//
//  Created by Marshall Moutenot on 1/3/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import "SNMenuController.h"
#import "SNUtility.h"

@implementation SNMenuController

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

@end
