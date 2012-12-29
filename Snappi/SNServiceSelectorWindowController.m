//
//  SNServiceSelectorWindowController.m
//  Snappi
//
//  Created by Marshall Moutenot on 12/23/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import "SNServiceSelectorWindowController.h"
#import "SNTransparentWindow.h"
#import "SNService.h"


@implementation SNServiceSelectorWindowController

@synthesize serviceSelectWindow, serviceSelectView;

#define __BASE_WIDTH     240
#define __BASE_HEIGHT    200
#define __SERVICE_WIDTH  200
#define __SERVICE_HEIGHT 180
#define __ADD_SERVICE_BADGE_NAME @"add_service_badge.png"

- (id)init
{
  self = [super init];
  if (self) {
    NSPoint mouseLoc = [NSEvent mouseLocation];
    NSEnumerator *screenEnum = [[NSScreen screens] objectEnumerator];
    NSScreen *currentScreen;
    while ((currentScreen = [screenEnum nextObject]) && !NSMouseInRect(mouseLoc, [currentScreen frame], NO));
    
    CGFloat xPos = NSWidth ([currentScreen frame])/2 - __BASE_WIDTH/2;
    CGFloat yPos = NSHeight([currentScreen frame])/2 - __BASE_HEIGHT/2;
    NSRect contentRect = NSMakeRect(xPos, yPos, __BASE_WIDTH, __BASE_HEIGHT);
    
    [self initializeServiceSelectWindowWithRect:contentRect];
  }
  return self;
}

- (void)initializeServiceSelectWindowWithRect:(NSRect)contentRect{
  NSPoint mouseLoc = [NSEvent mouseLocation];
  NSEnumerator *screenEnum = [[NSScreen screens] objectEnumerator];
  NSScreen *currentScreen;
  while ((currentScreen = [screenEnum nextObject]) && !NSMouseInRect(mouseLoc, [currentScreen frame], NO));
  
  serviceSelectWindow = [[SNTransparentWindow alloc] initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:currentScreen];
  serviceSelectView = [[SNServiceSelectorView alloc] initWithFrame: contentRect];
  [serviceSelectWindow setContentView:serviceSelectView];
  [serviceSelectWindow setReleasedWhenClosed:NO];
  
}

- (void)showServiceSelectWithServices:(NSDictionary *)services {
  if ([services count] > 0) {
    NSPoint oldOrigin = serviceSelectWindow.frame.origin;
    NSPoint newOrigin = NSMakePoint(oldOrigin.x - ([services count] * __SERVICE_WIDTH)/2, oldOrigin.y);
    NSRect newContentRect = NSMakeRect(newOrigin.x, newOrigin.y, __BASE_WIDTH  + (([services count]-1) * __SERVICE_WIDTH),
                                       __BASE_HEIGHT);
    [self initializeServiceSelectWindowWithRect:newContentRect];
    for (SNService *service in [services allValues]) {
      NSImageView *serviceImageView = [[NSImageView alloc] init];
      serviceImageView.image = service.badge;
      [serviceSelectView addSubview:serviceImageView];
    }
  }
  else {
    NSString *addServiceImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:__ADD_SERVICE_BADGE_NAME];
    NSImage *addServiceImage      = [[NSImage alloc] initWithContentsOfFile:addServiceImagePath];
    NSRect  frame                 = NSMakeRect(.0f, .0f, addServiceImage.size.width, addServiceImage.size.height);
    NSImageView *serviceImageView = [[NSImageView alloc] initWithFrame:frame];
    serviceImageView.image        = addServiceImage;
    
    NSLog(@"%f %f %f %f", serviceImageView.frame.origin.x, serviceImageView.frame.origin.y, serviceImageView.frame.size.width, serviceImageView.frame.size.height);
    
    [serviceSelectView addSubview:serviceImageView];
  }
  [serviceSelectWindow makeKeyAndOrderFront:NSApp];
}


@end
