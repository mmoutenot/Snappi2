//
//  MyPoint.h
//  Snappi
//
//  Created by Marshall Moutenot on 12/14/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface SNPoint : NSObject{
  NSPoint myNSPoint;
}
- (id) initWithNSPoint:(NSPoint)pNSPoint;
- (NSPoint) myNSPoint;
- (float)x;
- (float)y;
- (void) setToPoint:(NSPoint)point;

@end

