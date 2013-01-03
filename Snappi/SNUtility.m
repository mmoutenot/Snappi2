//
//  SNUtility.m
//  Snappi
//
//  Created by Marshall Moutenot on 12/14/12.
//  Copyright (c) 2012 Marshall Moutenot. All rights reserved.
//

#import "SNUtility.h"
#import "SNFile.h"
#import "SNAppDelegate.h"

@implementation SNUtility


+ (NSImage *)captureImageForRect:(NSRect)rect {
  
  NSWindow *window;
  window = [[NSWindow alloc] initWithContentRect:rect styleMask:NSBorderlessWindowMask
                                         backing:NSBackingStoreNonretained defer:NO];
  
  [window setBackgroundColor:[NSColor clearColor]];
  //  [window setLevel:NSScreenSaverWindowLevel + 1];
  [window setLevel:NSMainMenuWindowLevel + 1];
  [window setHasShadow:NO];
  [window setAlphaValue:0.0];
  [window orderFront:self];
  [window setContentView:[[NSView alloc] initWithFrame:rect]];
  [[window contentView] lockFocus];
  CGWindowID windowID = (CGWindowID)[window windowNumber];
  
  CGImageRef capturedImage = CGWindowListCreateImage(rect, kCGWindowListOptionOnScreenBelowWindow, windowID, kCGWindowImageDefault);
  
  [[window contentView] unlockFocus];
  [window orderOut:self];
  
  NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage: capturedImage];
  NSImage *image = [[NSImage alloc] init];
  [image addRepresentation: bitmapRep];
  //  CGImageRelease(capturedImage);
  
  return image;
}

// returns full path of written file
+ (NSString *)writeImageAsJPGToFile:(NSImage *)image toPath:(NSString *)pathToDir {
  NSString *sguid = [[NSProcessInfo processInfo] globallyUniqueString];
  NSBitmapImageRep *imgRep = [[image representations] objectAtIndex:0];
  NSData *data = [imgRep representationUsingType: NSPNGFileType properties:nil];
  NSString *pathToImage = [NSString stringWithFormat:@"%@/%@.jpg", pathToDir, sguid];
  [data writeToFile:pathToImage atomically:YES];
  return pathToImage;
}

// returns a rectangle with positive heights and widths and origin in bottom left
+ (NSRect)normalizeRect:(NSRect) rect{
  if (rect.size.width < 0){
    rect.origin.x = rect.origin.x + rect.size.width;
    rect.size.width *= -1;
  }
  if (rect.size.height < 0){
    rect.origin.y = rect.origin.y + rect.size.height;
    rect.size.height *= -1;
  }
  return rect;
}

+ (NSRect)expandRect:(NSRect) rect byFactor:(NSInteger)i{
  rect = [SNUtility normalizeRect:rect];
  rect.origin.x-=i;
  rect.origin.y-=i;
  rect.size.width+=i;
  rect.size.height+=i;
  return rect;
}

+ (void)writeImage:(NSImage *) image toPath:(NSString *)path {
  NSBitmapImageRep *imgRep = [[image representations] objectAtIndex: 0];
  NSData *data = [imgRep representationUsingType: NSPNGFileType properties: nil];
  [data writeToFile:path atomically: NO];
}

+ (NSString*)UUIDString {
  CFUUIDRef theUUID = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, theUUID);
  CFRelease(theUUID);
  return (__bridge NSString *)string;
}

+ (NSString *) generateTitleForFiles:(NSArray *)files isScreenshot:(BOOL)isScreenshot {
  // set note title
  CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
  SInt8 hour = currentDate.hour;
  NSString *ampm = @"am";
  if(hour > 12){
    ampm = @"pm";
    hour = hour-12;
  }
  NSString *datestring = [NSString stringWithFormat:@"%02d:%02d %@", hour, currentDate.minute, ampm];
  NSString *titleContext = [self generateTitleContextForFiles:files];
  if(isScreenshot){
    titleContext = @"Screenshot";
  }
  return [NSString stringWithFormat:@"%@ via Snappi @ %@", titleContext, datestring];
}

+ (NSString *) generateTitleContextForFiles:(NSArray*) files {
  if ([files count] == 1){
    SNFile *file = [files objectAtIndex:0];
    return file.name;
  }
  else if ([files count] > 1){
    NSMutableSet *extensionSet = [[NSMutableSet alloc] init];
    for (SNFile *file in files) {
      [extensionSet addObject:file.ext];
    }
    NSArray *uniqueExtensions = [[NSArray alloc] initWithArray:[extensionSet allObjects]];
    if ([uniqueExtensions count] == 1){
      NSString *ext = [uniqueExtensions objectAtIndex:0];
      if([ext isEqualToString:@"mp3"]  || [ext isEqualToString:@"wav"]
         || [ext isEqualToString:@"mpeg"] || [ext isEqualToString:@"amr"]
         || [ext isEqualToString:@"flac"]){
        return @"Songs";
      }
      if([ext isEqualToString:@"doc"] || [ext isEqualToString:@"docx"]
         || [ext isEqualToString:@"pdf"] || [ext isEqualToString:@"rtf"]
         || [ext isEqualToString:@"txt"]){
        return @"Documents";
      }
      if([ext isEqualToString:@"avi"] || [ext isEqualToString:@"mp4"]
         || [ext isEqualToString:@"flv"] || [ext isEqualToString:@"mkv"]){
        return @"Videos";
      }
      if([ext isEqualToString:@"cpp" ] || [ext isEqualToString:@"h"]
         || [ext isEqualToString:@"m"]    || [ext isEqualToString:@"js"]
         || [ext isEqualToString:@"jsm"]  || [ext isEqualToString:@"c"]
         || [ext isEqualToString:@"java"] || [ext isEqualToString:@"scm"]){
        return @"Code";
      }
      if([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"png"]
         || [ext isEqualToString:@"gif"] || [ext isEqualToString:@"jpeg"]
         || [ext isEqualToString:@"psd"]) {
        return @"Images";
      }
    }
  }
  return @"Files";
}

+ (NSString *)getMimeTypeForExtension:(NSString *)ext {
  if([ext isEqualToString:@"gif"])  return @"image/gif";
  if([ext isEqualToString:@"jpeg"]) return @"image/jpeg";
  if([ext isEqualToString:@"jpg"])  return @"image/jpeg";
  if([ext isEqualToString:@"png"])  return @"image/png";
  if([ext isEqualToString:@"wav"])  return @"audio/wav";
  if([ext isEqualToString:@"mpeg"]) return @"audio/mpeg";
  if([ext isEqualToString:@"mp3"])  return @"audio/mpeg";
  if([ext isEqualToString:@"amr"])  return @"audio/amr";
  if([ext isEqualToString:@"pdf"])  return @"application/pdf";
  return @"application/zip";
}

+ (void)processLink:(NSString *)link {
  //  if ([putLinkInClipboard boolValue]){
  //    if ([shortenLink boolValue])
  NSString *shareLink = [SNUtility shortenURL:link];
  [SNUtility addToClipboard:shareLink];
  
  //  }
  //}
}

+ (void) addMenuItemForNote:(EDAMNote *) note withLink:(NSString *)shareLink {
  SNAppDelegate *appDelegate = (SNAppDelegate *)[[NSApplication sharedApplication] delegate];
  // Add an item to the status bar menu
  NSMenuItem *mainItem = [[NSMenuItem alloc] init];
  [mainItem setTitle:note.title];
  NSMenu *subMenu = [[NSMenu alloc] init];
  NSMenuItem *item1 = [[NSMenuItem alloc] initWithTitle:@"Copy Shortlink" action:@selector(statusItemClicked:) keyEquivalent:@""];
  [item1 setToolTip: [[NSString alloc] initWithString: shareLink]];
  [item1 setTarget: appDelegate.menuController];
  NSMenuItem *item2 = [[NSMenuItem alloc] initWithTitle:@"View Stats" action:@selector(statsItemClicked:) keyEquivalent:@""];
  [item2 setToolTip: [[NSString alloc] initWithString: shareLink]];
  [item2 setTarget: appDelegate.menuController];
  [subMenu addItem:item1];
  [subMenu addItem:item2];
  
  [mainItem setSubmenu:subMenu];
  [appDelegate.statusMenu addItem:mainItem];
}

+ (NSString *) shortenURL:(NSString *) url {
  CFStringRef legalStr = CFSTR("!@#$%^&()<>?{},;'[]");
  NSString *escUrl = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, NULL, legalStr, kCFStringEncodingUTF8);
  NSString *apiEndpoint = [NSString stringWithFormat:@"http://snppi.com/yourls-api.php?signature=d5ed24bef1&action=shorturl&url=%@&format=simple",escUrl];
  NSError* error;
  NSString* shortURL = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiEndpoint] encoding:NSASCIIStringEncoding error:&error];
  if (shortURL)
    return shortURL;
  else
    return [error localizedDescription];
}

+ (void) addToClipboard:(NSString *)shareLink{
  SNAppDelegate *appDelegate = (SNAppDelegate *)[[NSApplication sharedApplication] delegate];
  NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
  [pasteboard clearContents];
  [pasteboard setString:shareLink forType:NSPasteboardTypeString];
  [appDelegate.notificationController showNotificationWithTitle:@"Snappi Link Copied" informationText:shareLink];
}


@end
