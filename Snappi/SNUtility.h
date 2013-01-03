//
//  SNUtility.h
//  Snappi
//
//  Created by Marshall Moutenot on 12/14/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDAMNoteStore.h"

@interface SNUtility : NSObject

+ (NSImage *)captureImageForRect:(NSRect)rect;

+ (NSString *)writeImageAsJPGToFile:(NSImage *)image toPath:(NSString *)pathToDir;
  
+ (NSRect)normalizeRect:(NSRect)rect;

+ (NSRect)expandRect:(NSRect)rect byFactor:(NSInteger)i;

+ (NSString *)generateTitleForFiles:(NSArray *)files isScreenshot:(BOOL)isScreenshot;

+ (NSString *)generateTitleContextForFiles:(NSArray*) files;

+ (NSString *)getMimeTypeForExtension:(NSString *)ext;

+ (void)writeImage:(NSImage *)image toPath:(NSString *)path;

+ (NSString*)UUIDString;

+ (void)processLink:(NSString *)link;

+ (void) addMenuItemForNote:(EDAMNote *) note withLink:(NSString *)shareLink;

+ (NSString *) shortenURL:(NSString *) url;

+ (void) addToClipboard:(NSString *)shareLink;
  
@end
