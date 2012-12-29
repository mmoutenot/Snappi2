//
//  MyPoint.m
//  Snappi
//
//  Created by Marshall Moutenot on 12/14/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import "SNPoint.h"

@implementation SNPoint

- (id) initWithNSPoint:(NSPoint)pNSPoint;
{
  if ((self = [super init]) == nil) {
    return self;
  } // end if
  
  myNSPoint.x = pNSPoint.x;
  myNSPoint.y = pNSPoint.y;
  
  return self;
  
} // end initWithNSPoint

- (NSPoint) myNSPoint;
{
  return myNSPoint;
} // end myNSPoint

- (float)x;
{
  return myNSPoint.x;
} // end x

- (float)y;
{
  return myNSPoint.y;
} // end y

- (void) setToPoint:(NSPoint)point{
  myNSPoint.x = point.x;
  myNSPoint.y = point.y;
}

@end
