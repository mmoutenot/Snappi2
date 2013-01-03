//
//  SNNotificationController.m
//  Snappi
//
//  Created by Marshall Moutenot on 1/3/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import "SNNotificationController.h"

@implementation SNNotificationController

- (id) init {
  self = [super init];
  if (self) {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
  }
  return self;
}

- (void)showNotificationWithTitle:(NSString *) title informationText:(NSString *)infoText {
  NSUserNotification *notification = [[NSUserNotification alloc] init];
  notification.title = title;
  notification.informativeText = infoText;
  notification.soundName = NSUserNotificationDefaultSoundName;
  [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
  return YES;
}

@end
