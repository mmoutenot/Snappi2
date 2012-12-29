//
//  SNEvernoteController.m
//  Snappi
//
//  Created by Marshall Moutenot on 12/21/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import "SNEvernoteController.h"

#import "THTTPClient.h"
#import "TBinaryProtocol.h"
#import "EDAMUserStore.h"
#import "EDAMNoteStore.h"
#import "EDAMErrors.h"
#import "GTMOAuthWindowController.h"

@implementation SNEvernoteController

@synthesize auth, delegate;

- (GTMOAuthAuthentication *)generateAuth {

  GTMOAuthAuthentication *retAuth;
  retAuth = [[GTMOAuthAuthentication alloc]
                      initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                  consumerKey:EV__CONSUMER_KEY
                                   privateKey:EV__CONSUMER_SECRET];

  // setting the service name lets us inspect the auth object later to know
  // what service it is for
  [retAuth setServiceProvider:EV__NAME];
  return retAuth;
}

- (void)showLogin{
  
  NSURL *requestURL   = [NSURL URLWithString:EV__REQUEST_URL];
  NSURL *accessURL    = [NSURL URLWithString:EV__ACCESS_URL];
  NSURL *authorizeURL = [NSURL URLWithString:EV__AUTHORIZE_URL];
  
  GTMOAuthAuthentication *retAuth = [self generateAuth];
  // does not need to be set
  [retAuth setCallback:@"http://www.example.com/OAuthCallback"];
  
  GTMOAuthWindowController *windowController;
  windowController = [[GTMOAuthWindowController alloc]
                                                initWithScope:EV__SCOPE
                                                     language:nil
                                              requestTokenURL:requestURL
                                            authorizeTokenURL:authorizeURL
                                               accessTokenURL:accessURL
                                               authentication:retAuth
                                               appServiceName:EV__KEYCHAIN_ITEM_NAME
                                               resourceBundle:nil];
  [windowController signInSheetModalForWindow:nil
                                     delegate:self
                             finishedSelector:@selector(windowController:finishedWithAuth:error:)];
}

- (void)windowController:(GTMOAuthWindowController *)windowController
        finishedWithAuth:(GTMOAuthAuthentication *)retAuth
                   error:(NSError *)error {
  NSString *scope = [retAuth scope];
  if (error != nil) {
    // Authentication failed (perhaps the user denied access, or closed the window before granting access)
    NSLog(@"Authentication error: %@", error);
    NSData *responseData = [[error userInfo] objectForKey:@"data"];
    if ([responseData length] > 0) {
      // show the body of the server's authentication failure response
      NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
      NSLog(@"%@", str);
    }
    if([scope isEqualToString:EV__SCOPE])
      [self setAuth:nil];
  } else {
    
    // Authentication succeeded
    //
    // At this point, we either use the authentication object to explicitly
    // authorize requests, like
    //
    //   [auth authorizeRequest:myNSURLMutableRequest]
    //
    // or store the authentication object into a Google API service object like
    //
    //   [[self contactService] setAuthorizer:auth];
    
    // save the authentication object to correct object, depending on scope
    if([scope isEqualToString:EV__SCOPE])
      [self setAuth:retAuth];
  }
  //update the user iterface to reflect what is auth'd
  [delegate performSelector:@selector(connectToServiceSuccessWithName:) withObject:EV__NAME];
}

@end
