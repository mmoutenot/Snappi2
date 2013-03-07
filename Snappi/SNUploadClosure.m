//
//  SNUploadClosure.m
//  Snappi
//
//  Created by Marshall Moutenot on 1/25/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import "SNUploadClosure.h"

@implementation SNUploadClosure

@synthesize files;
@synthesize isScreenshot;

-(id) init{
  self = [super init];
  if (self){
    self.files = [[NSMutableArray alloc] initWithCapacity:3];
  }
  return self;
}

@end
