//
//  SNDroppableView.m
//  Snappi
//
//  Created by Marshall Moutenot on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNDroppableView.h"
#import "SNUploadClosure.h"
#import "SNAppDelegate.h"

@implementation SNDroppableView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    return self;
}

- (void)setMenu:(NSMenu *)menu {
    [menu setDelegate:self];
    [super setMenu:menu];
}

- (void)setImage:(NSImage *) img{
    image=img; 
}

- (void)setStatusItem:(NSStatusItem *) statusIt{
    statusItem = statusIt; 
}

- (void)setAltImage:(NSImage *) img{
    alternateImage=img; 
}

- (void)mouseDown:(NSEvent *)event {
    [statusItem popUpStatusItemMenu:[self menu]]; // or another method that returns a menu
}

- (void)menuWillOpen:(NSMenu *)menu {
    highlight = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    highlight = NO;
    [self setNeedsDisplay:YES];
}

- (void)swapImages{
    NSImage *temp = image;
    image = alternateImage;
    alternateImage = temp;
    float width = 18.0;
    float height = [[NSStatusBar systemStatusBar] thickness];
    NSRect viewFrame = NSMakeRect(0, 0, width, height);
    [self drawRect: viewFrame];
}

- (void)drawRect:(NSRect)rect {
    
    if (highlight) {
        [[NSColor selectedMenuItemColor] set];
        NSRectFill(rect);
    } 
    
//    NSString *inFilePath = [[NSBundle mainBundle] pathForResource: @"snappi_icon_18" ofType:@"png"];
    
//    NSImage *img = [[[NSImage alloc] initWithContentsOfFile:inFilePath] autorelease];
    if(image)
        [image drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

    // rest of drawing code goes here, including drawing img where appropriate
}

-(NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
    NSLog(@"Drag Enter");
    return NSDragOperationCopy;
}

-(NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender{
    return NSDragOperationCopy;
}

-(void)draggingExited:(id <NSDraggingInfo>)sender{
    NSLog(@"Drag Exit");
}

-(BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender{
     return YES;
}

-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender{
/*     NSPasteboard *pasteboard = [sender draggingPasteboard]; */
/*     if ([[pasteboard types] containsObject:NSFilenamesPboardType]) */
/*     { */
/*         NSData* data = [pasteboard dataForType:NSFilenamesPboardType]; */
/*         if (data) */
/*         { */
/*             NSString* errorDescription; */
/*             NSArray* filenames = [NSPropertyListSerialization */
/*                                   propertyListFromData:data */
/*                                   mutabilityOption:kCFPropertyListImmutable */
/*                                   format:nil */
/*                                   errorDescription:&errorDescription]; */
/*              */
/*             NSMutableArray *itemPaths = [[[NSMutableArray alloc] init] autorelease]; */
/*             NSMutableArray *itemExts  = [[[NSMutableArray alloc] init] autorelease]; */
/*              */
/*             for (NSString* filename in filenames) */
/*             {    */
/* //                NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", filename]]; */
/* //                NSString *path = [url path];  */
/*                 [itemPaths addObject: filename]; */
/*                 [itemExts  addObject:[filename pathExtension]]; */
/*             } */
/*             NSLog(@"%@",itemPaths); */
/*             NSArray *args = [NSArray arrayWithObjects:itemPaths, itemExts, [NSNumber numberWithBool:true], nil]; */
/* //            NSLog(@"About to take the screenshot"); */
/*             if (args && [args count] > 0) */
/*                 [AppController performSelector:@selector(takeScreenshotWrapper:) */
/*                                     withObject:args afterDelay:1]; */
/*              */
/* //            [AppController takeScreenshot:itemPaths :itemExts :true]; */
/*             return YES; */
/*         } */
/*     } */

//  NSMutableArray *paths = [NSMutableArray arrayWithCapacity:1];
//  NSMutableArray *exts  = [NSMutableArray arrayWithCapacity:1];
//  NSArray *pasteboardTypes = [NSArray arrayWithObjects:@"com.apple.pasteboard.promised-file-url", @"public.file-url", nil];
//  for(NSPasteboardItem *item in [[sender draggingPasteboard] pasteboardItems]) {
//    NSString *urlString = nil;
//    for(NSString *type in pasteboardTypes) {
//      if([[item types] containsObject:type]) {
//        urlString = [item stringForType:type];
//        break;
//      }
//    }
//    if(urlString) {
//      urlString = [NSString stringWithUTF8String:[urlString cStringUsingEncoding:[NSString defaultCStringEncoding]]];
//      NSString *path = [[NSURL URLWithString:urlString] path];
//      [paths addObject:path];
//      [exts addObject:[path pathExtension]];
//    }
//  }
//  NSArray *args = [NSArray arrayWithObjects:paths, exts, [NSNumber numberWithBool:true], nil];
//  NSLog(@"About to upload");
//  if (args && [args count] > 0)
//    [AppController performSelector:@selector(uploadWrapper:)
//                                       withObject:args afterDelay:1];
  
  SNUploadClosure *uploadCl = [[SNUploadClosure alloc] init];
  uploadCl.isScreenshot = NO;
  NSArray *pasteboardTypes = [NSArray arrayWithObjects:@"com.apple.pasteboard.promised-file-url", @"public.file-url", nil];
  for(NSPasteboardItem *item in [[sender draggingPasteboard] pasteboardItems]) {
    for(NSString *type in pasteboardTypes) {
      if([[item types] containsObject:type]) {
        NSString *urlString = [item stringForType:type];
        SNFile *file = [[SNFile alloc] initWithPath:urlString];
        [uploadCl.files addObject:file];
        
        break;
      }
    }
  }
  SNAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
  [appDelegate performSelector:@selector(uploadDispatcher:) withObject:uploadCl afterDelay:1];
  return YES;
}

// /Users/mmoutenot/Music/iTunes/iTunes Media/Music/Flying Lotus/The Do-Over Vol.1/01 Sangria Spin Cycles.mp3
// /Users/mmoutenot/Music/iTunes/iTunes Media/Music/Flying Lotus/The Do-Over Vol.1/01 Sangria Spin Cycles.mp3

@end
