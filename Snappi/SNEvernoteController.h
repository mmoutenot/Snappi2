//
//  SNEvernoteController.h
//  Snappi
//
//  Created by Marshall Moutenot on 12/21/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuthAuthentication.h"
#import "EDAMNoteStore.h"
#import "EDAMUserStore.h"
#import "EDAMErrors.h"
#import "SNUploadClosure.h"

@interface SNEvernoteController : NSObject {
  GTMOAuthAuthentication *auth;
  EDAMNoteStoreClient *noteStore;
  NSString *noteShareUri;
  NSURL *noteStoreUri;
  id delegate;
}

@property (strong, nonatomic) GTMOAuthAuthentication *auth;
@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) EDAMNoteStoreClient *noteStore;
@property (strong, nonatomic) NSURL *noteStoreUri;
@property (strong, nonatomic) NSString *noteShareUri;

+ (SNEvernoteController *)sharedInstance;

  
- (void)showLogin;
- (GTMOAuthAuthentication *)getOrCreateAuth;
- (void)upload:(SNUploadClosure *)uploadCl;
  
@end
