//
//  SNEvernoteController.m
//  Snappi
//
//  Created by Marshall Moutenot on 12/21/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import "SNEvernoteController.h"
#import "SNUtility.h"
#import "SNFile.h"
#import "SNAppDelegate.h"

#import "THTTPClient.h"
#import "TBinaryProtocol.h"
#import "GTMOAuthWindowController.h"

@implementation SNEvernoteController

static SNEvernoteController *sharedEvernoteManager = nil;

NSString * const userStoreUri = @"https://www.evernote.com/edam/user";

/************************************************************
 *
 *  Accessing the static version of the instance
 *
 ************************************************************/

+ (SNEvernoteController *)sharedInstance {
  if (sharedEvernoteManager == nil) {
    sharedEvernoteManager = [[SNEvernoteController alloc] init];
  }
  return sharedEvernoteManager;
}

- (id) init {
  self = [super init];
  if (self) {
    self.delegate = (SNAppDelegate *)[[NSApplication sharedApplication] delegate];
    self.auth = [self getOrCreateAuth];
  }
  return self;
}

- (GTMOAuthAuthentication *)getOrCreateAuth {
  GTMOAuthAuthentication *a;
  a = [GTMOAuthWindowController authForGoogleFromKeychainForName:EV__KEYCHAIN_ITEM_NAME];
  if ([a canAuthorize]){
    [_delegate performSelector:@selector(connectToServiceSuccessWithName:) withObject:EV__NAME];
    NSLog(@"Authorized with Evernote");
  }
  else {
    [GTMOAuthWindowController authorizeFromKeychainForName:EV__KEYCHAIN_ITEM_NAME authentication:a];
    // handle loging in or not
    if ([a canAuthorize]) {
      //update the user iterface to reflect what is auth'd
      [_delegate performSelector:@selector(connectToServiceSuccessWithName:) withObject:EV__NAME];
      NSLog(@"Authorized with Evernote");
    } else {
      a = [self createAuth];
    }
  }
  return a;
}

- (GTMOAuthAuthentication *)createAuth {
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
  
  GTMOAuthAuthentication *retAuth = [[SNEvernoteController sharedInstance] createAuth];
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
                                     delegate:[SNEvernoteController sharedInstance]
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
      [[SNEvernoteController sharedInstance] setAuth:nil];
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
    if([scope isEqualToString:EV__SCOPE]){
      [[SNEvernoteController sharedInstance] setAuth:retAuth];
      return;
    }
  }
  //failed
}


- (void)signOut {
  if ([[_auth serviceProvider] isEqual:kGTMOAuthServiceProviderGoogle]){
    // remove the token from Google's servers
    [GTMOAuthWindowController revokeTokenForGoogleAuthentication:_auth];
  }
  // remove the stored Evernote authentication from the keychain, if any
  [GTMOAuthWindowController removeParamsFromKeychainForName:EV__KEYCHAIN_ITEM_NAME];

  // discard our retains authentication object
  _auth = nil;
  NSLog(@"Logged out from Evernote");
}

// NOTE GENERATION FUNCTIONS

- (void)upload:(SNUploadClosure *)uploadCl{
  NSString *notebookName = [[NSUserDefaults standardUserDefaults] objectForKey:@"notebookName"];
  NSMutableArray *resources = [[NSMutableArray alloc] init];
  NSString *ENML = @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?> <!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\"> <en-note>";
  EDAMNote *note = [EDAMNote alloc];
  [note setTitle:[SNUtility generateTitleContextForFiles:uploadCl.files]];
  for (int i = 0; i < [uploadCl.files count]; i++){
    SNFile *file = [uploadCl.files objectAtIndex:i];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:file.path isDirectory:NO];
    NSString *fileURLPath = [fileURL path];
//    NSData *fileData = [[NSData alloc] initWithContentsOfURL:file.path];;
//    NSData *fileData = [[NSData alloc] initWithContentsOfFile:file.path];
    NSData *fileData = [NSData dataWithContentsOfFile:fileURLPath];
    EDAMResource *resource = [[EDAMResource alloc] init];
    NSString * hash;
    if (fileData) {
      NSLog(@"We have a valid file");
      // 1) create the data EDAMData using the hash, the size and the data of the image
      EDAMData * edamFileData = [[EDAMData alloc] initWithBodyHash:[hash dataUsingEncoding: NSUTF8StringEncoding] size:(int)[fileData length] body:fileData];

      // 2) Create an EDAMResourceAttributes object with other important attributes of the file
      EDAMResourceAttributes * fileAttributes = [[EDAMResourceAttributes alloc] init];
      [fileAttributes setFileName:file.name];
      // 3) create an EDAMResource the hold the mime the data and the attributes
      NSString *mimeType = [SNUtility getMimeTypeForExtension:file.ext];
      [resource setMime:mimeType];
      [resource setData:edamFileData];
      [resource setAttributes:fileAttributes];
      [resources addObject:resource];
      ENML = [NSString stringWithFormat:@"%@<en-media alt=\"Snappi Share\" type=\"%@\" hash=\"%@\"/>", ENML, mimeType, file.hash];
    }
  }
  ENML = [NSString stringWithFormat:@"%@%@", ENML, @"</en-note>"];
  [note setTitle:[SNUtility generateTitleForFiles:uploadCl.files isScreenshot:uploadCl.isScreenshot]];
  [note setContent:ENML];
  [note setResources:resources];
  [note setNotebookGuid:[[SNEvernoteController sharedInstance] getOrCreateNotebook:notebookName]];
  
  EDAMNote *createdNote;
  @try {
    createdNote = [[SNEvernoteController sharedInstance] createNote:note];
    NSString *noteKey = [[SNEvernoteController sharedInstance] getShareKey:createdNote];
    NSString *shareLink = [NSString stringWithFormat:@"%@/%@",
                           [NSString stringWithFormat:@"%@/%@", [[SNEvernoteController sharedInstance] noteShareUri], createdNote.guid], noteKey];
    [SNUtility processLink:shareLink];
    [SNUtility addMenuItemForNote:createdNote withLink:shareLink];
  }
  @catch (EDAMUserException * e) {
    NSString * errorMessage =
    [NSString stringWithFormat:@"Error saving note: error code %i", [e errorCode]];
    NSLog(@"%@",errorMessage);
  }
  
}

- (void) connect {
  if (_noteStore == nil) {
    // In the case we are not connected we don't have an authToken
    // Instantiate the Thrift objects
    NSURL * NSURLuserStoreUri = [[NSURL alloc] initWithString: userStoreUri];
    
    THTTPClient         *userStoreHttpClient = [[THTTPClient alloc] initWithURL: NSURLuserStoreUri];
    TBinaryProtocol     *userStoreProtocol   = [[TBinaryProtocol alloc] initWithTransport:userStoreHttpClient];
    EDAMUserStoreClient *userStore           = [[EDAMUserStoreClient alloc] initWithProtocol:userStoreProtocol];
    
    // Check that we can talk to the server
    BOOL versionOk = [userStore checkVersion:@"Cocoa EDAMTest" :
                      [EDAMUserStoreConstants EDAM_VERSION_MAJOR] :
                      [EDAMUserStoreConstants EDAM_VERSION_MINOR]];
    
    if (!versionOk) {
      return;
    }
    
    _noteStoreUri = [[NSURL alloc] initWithString:[userStore getNoteStoreUrl:[SNEvernoteController sharedInstance].auth.token]];
    
    [SNEvernoteController sharedInstance].noteShareUri =
        [[NSString alloc] initWithString: [[_noteStoreUri absoluteString] stringByReplacingOccurrencesOfString:@"notestore" withString:@"sh"]];
    
    
    // Initializing the NoteStore client
    THTTPClient *noteStoreHttpClient = [[THTTPClient alloc] initWithURL:_noteStoreUri];
    TBinaryProtocol *noteStoreProtocol = [[TBinaryProtocol alloc] initWithTransport:noteStoreHttpClient];
    _noteStore = [[EDAMNoteStoreClient alloc] initWithProtocol:noteStoreProtocol];
  }
}

- (NSArray *) listNotebooks {
  // Checking the connection
  [[SNEvernoteController sharedInstance] connect];

  // Calling a function in the API
  NSArray *notebooks =
    [[NSArray alloc] initWithArray:[[[SNEvernoteController sharedInstance] noteStore]
                      listNotebooks:[SNEvernoteController sharedInstance].auth.token]];
  return notebooks;
}

- (EDAMNote*) createNote: (EDAMNote *) note {
  [self connect];
  return [_noteStore createNote:[SNEvernoteController sharedInstance].auth.token :note];
}

- (NSString*) getShareKey:(EDAMNote *)note{
 [self connect];
  return [_noteStore shareNote:[SNEvernoteController sharedInstance].auth.token :note.guid];
}

- (EDAMNotebook*) createNotebook: (EDAMNotebook *) notebook {
 // Checking the connection
 [[SNEvernoteController sharedInstance] connect];
 return[_noteStore createNotebook:[SNEvernoteController sharedInstance].auth.token :notebook];
}

- (NSString *) getOrCreateNotebook:(NSString *) notebookName{
  EDAMNotebook *notebook = [EDAMNotebook alloc];
  notebook.name = notebookName;
  NSString *nguid = [NSString alloc];
  @try {
    EDAMNotebook *test = [[SNEvernoteController sharedInstance] createNotebook:notebook];
    nguid = [test guid];
  }
  @catch ( NSException *e ) {
    @try {
      NSArray *notebooks = [[SNEvernoteController sharedInstance] listNotebooks];
      for (id book in notebooks){
        NSLog(@"%@  =  %@", [book name], notebook.name);
        if ([[book name]isEqualToString: notebook.name]) {
          nguid = [book guid];
        }
      }
    }
    @catch (NSException *e) {
      nguid = @"";
      [[SNNotificationController sharedNotificationController] showNotificationWithTitle:@"Evernote Error" informationText:@"Please try logging out and back in under \"Evernote Options\" in the menu"];
      [self signOut];
      [self showLogin];
    }
    NSLog(@"GUID: %@",nguid);
  }
  return nguid;
}


@end
