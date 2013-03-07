//
//  SNServiceSelectViewController.m
//  Snappi
//
//  Created by Marshall Moutenot on 2/22/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import "SNServiceSelectViewController.h"
#import "SNEvernoteController.h"
#import "SNAppDelegate.h"

@interface SNServiceSelectViewController ()

@end

@implementation SNServiceSelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)evernoteDispatchCallback:(id)sender{
  SNAppDelegate *ad = (SNAppDelegate *)[[NSApplication sharedApplication] delegate];
  [[SNEvernoteController sharedInstance] performSelectorInBackground:@selector(upload:) withObject:ad.currentUpload];
}

- (IBAction)twitterDispatchCallback:(id)sender{
  
}


@end
