//
//  SNMenuController.h
//  Snappi
//
//  Created by Marshall Moutenot on 1/3/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNMenuController : NSObject

@property (strong, nonatomic) NSMenu *statusMenu;

- (void) statusItemClicked:(NSMenuItem *) menuItem;
- (void) statsItemClicked:(NSMenuItem *) menuItem;
- (void) addDestinationMenuItems;
- (void) updateOptionMenuItem;
- (void)updateStatusMenuWithConnectionName:(NSString *)connectionName;
  
@end
