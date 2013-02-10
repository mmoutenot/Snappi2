//
//  SNFileQueue.h
//  Snappi
//
//  Created by Marshall Moutenot on 1/27/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNFile.h"

@interface SNFileQueue : NSObject{
  NSMutableArray *fileQueue;
}

@property (strong, nonatomic) NSMutableArray *fileQueue;

- (void)addFile:(SNFile *)file;
- (SNFile *)popFile;
  
@end
