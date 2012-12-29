//
//  SNCaptureViewController.h
//  Snappi
//
//  Created by Marshall Moutenot on 12/14/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SNPoint.h"

@interface SNCaptureView : NSView {
  NSValue* rectVal;
}

@property (strong, nonatomic) id delegate;


-(void)mouseMoved:(NSEvent *)theEvent;

@end