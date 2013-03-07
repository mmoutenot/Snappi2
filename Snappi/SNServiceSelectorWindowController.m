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

#define __BASE_WIDTH     260
#define __BASE_HEIGHT    200
#define __SERVICE_WIDTH  200
#define __SERVICE_HEIGHT 180
#define __ADD_SERVICE_BADGE_NAME @"add_service_badge.png"

- (id)initWithWindowNibName:(NSString *)windowNibName
{
  self = [super initWithWindowNibName:windowNibName];
  if (self) {
  }
  return self;
}

//- (void)initializeServiceSelectWindowWithRect:(NSRect)contentRect{
//  NSPoint mouseLoc = [NSEvent mouseLocation];
//  NSEnumerator *screenEnum = [[NSScreen screens] objectEnumerator];
//  NSScreen *currentScreen;
//  while ((currentScreen = [screenEnum nextObject]) && !NSMouseInRect(mouseLoc, [currentScreen frame], NO));
//  
//  serviceSelectWindow = [[SNTransparentWindow alloc] initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:currentScreen];
//  serviceSelectView = [[SNServiceSelectorView alloc] initWithFrame: contentRect];
//  [serviceSelectWindow setContentView:serviceSelectView];
//  [serviceSelectWindow setReleasedWhenClosed:NO];
//  
//}

- (void)showServiceSelectWithServices:(NSDictionary *)services {

  [serviceSelectWindow makeKeyAndOrderFront:NSApp];
  if ([services count] > 0) {
    NSPoint oldOrigin = serviceSelectWindow.frame.origin;
    NSPoint newOrigin = NSMakePoint(oldOrigin.x - ([services count] * __SERVICE_WIDTH)/2, oldOrigin.y);
    NSRect newContentRect = NSMakeRect(newOrigin.x, newOrigin.y, __BASE_WIDTH  + ([services count] * __SERVICE_WIDTH),
                                       __BASE_HEIGHT);
    [serviceSelectWindow setFrame:newContentRect display:YES animate:YES];
//    [self.window.contentView setFrame:newContentRect display:YES animate:YES];
//    for (SNService *service in [services allValues]) {
//      NSImageView *serviceImageView = [[NSImageView alloc] init];
//      serviceImageView.image = service.badge;
//      [serviceSelectView addSubview:serviceImageView];
//    }
  }
//  else {
//    NSString *addServiceImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:__ADD_SERVICE_BADGE_NAME];
//    NSImage *addServiceImage      = [[NSImage alloc] initWithContentsOfFile:addServiceImagePath];
//    NSRect  frame                 = NSMakeRect(.0f, .0f, addServiceImage.size.width, addServiceImage.size.height);
//    NSImageView *serviceImageView = [[NSImageView alloc] initWithFrame:frame];
//    serviceImageView.image        = addServiceImage;
//    
//    NSLog(@"%f %f %f %f", serviceImageView.frame.origin.x, serviceImageView.frame.origin.y, serviceImageView.frame.size.width, serviceImageView.frame.size.height);
//    
//    [serviceSelectView addSubview:serviceImageView];
//  }
}




@end
