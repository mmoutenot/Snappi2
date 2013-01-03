//
//  SNNotificationController.h
//  Snappi
//
//  Created by Marshall Moutenot on 1/3/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNotificationController : NSObject <NSUserNotificationCenterDelegate>

- (void)showNotificationWithTitle:(NSString *) title informationText:(NSString *)infoText;

@end

