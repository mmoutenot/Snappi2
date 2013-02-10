//
//  SNUploadClosure.h
//  Snappi
//
//  Created by Marshall Moutenot on 1/25/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNUploadClosure : NSObject {
  NSMutableArray *files;
  BOOL isScreenshot;
}

@property (strong, nonatomic) NSMutableArray *files;
@property BOOL isScreenshot;

@end
