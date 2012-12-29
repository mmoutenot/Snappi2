//
//  SNUtility.h
//  Snappi
//
//  Created by Marshall Moutenot on 12/14/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNUtility : NSObject

+ (NSImage *)captureImageForRect:(NSRect)rect;

+ (NSString *)writeImageAsJPGToFile:(NSImage *)image toPath:(NSString *)pathToDir;
  
+ (NSRect)normalizeRect:(NSRect)rect;

+ (NSRect)expandRect:(NSRect)rect byFactor:(NSInteger)i;

@end
