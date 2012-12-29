//
//  SNEvernoteController.h
//  Snappi
//
//  Created by Marshall Moutenot on 12/21/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuthAuthentication.h"

@interface SNEvernoteController : NSObject {
  GTMOAuthAuthentication *auth;
  id delegate;
}

@property (strong, nonatomic) GTMOAuthAuthentication *auth;
@property (strong, nonatomic) id delegate;

- (void)showLogin;

@end
