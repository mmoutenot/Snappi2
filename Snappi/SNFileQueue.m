//
//  SNFileQueue.m
//  Snappi
//
//  Created by Marshall Moutenot on 1/27/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import "SNFileQueue.h"

@implementation SNFileQueue

@synthesize fileQueue;

- (void)addFile:(SNFile *)file{
  [fileQueue addObject:file];
}

- (SNFile *)popFile{
  SNFile *file = [fileQueue objectAtIndex:([fileQueue count]-1)];
  [fileQueue removeLastObject];
  return file;
}

@end
