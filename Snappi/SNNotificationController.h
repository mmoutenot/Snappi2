//
//  SNNotificationController.h
//  Snappi
//
//  Created by Marshall Moutenot on 1/3/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>

#import "SNAttachedWindow.h"

@interface SNNotificationController : NSObject <NSUserNotificationCenterDelegate, GrowlApplicationBridgeDelegate>{
  SNAttachedWindow *attachedWindow;
}

@property (strong, nonatomic) SNAttachedWindow *attachedWindow;

+ (SNNotificationController*)sharedNotificationController;
@property (weak) IBOutlet NSView *evernoteView;

- (void)showNotificationWithTitle:(NSString *) title informationText:(NSString *)infoText;
- (void)showAttachedWindowAtStatusViewWithView:(NSView *)view;

@end

