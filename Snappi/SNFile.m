//
//  SNFile.m
//  Snappi
//
//  Created by Marshall Moutenot on 1/1/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import <QuickLook/QuickLook.h>
#import <CommonCrypto/CommonDigest.h>

#import "SNFile.h"
#import "MMMarkdown.h"
#import "SNAppDelegate.h"

@implementation SNFile

@synthesize path, name, ext, hash;

@synthesize title, artist, album, albumArtPath, albumArt;

@synthesize markdownXHTML;

- (id) initWithPath:(NSString *)p {
  self = [super init];
  if (self) {
    SNAppDelegate *appDelegate = (SNAppDelegate *)[[NSApplication sharedApplication] delegate];
    NSString *urlString = [NSString stringWithUTF8String:[p cStringUsingEncoding:[NSString defaultCStringEncoding]]];
    urlString = [[NSURL URLWithString:urlString] path];
    path = urlString;
    name = [[p lastPathComponent] stringByDeletingPathExtension];
    ext  = [[p lastPathComponent] pathExtension];
    hash = [self getMD5FromFile:path];
    
    if ([self isMusic]) {
      MDItemRef metadata = MDItemCreate(NULL, (__bridge CFStringRef)path);
      title   = (__bridge NSString *)MDItemCopyAttribute(metadata, kMDItemTitle);
      album   = (__bridge NSString *)MDItemCopyAttribute(metadata, kMDItemAlbum);
      NSArray * artists = (__bridge NSArray *)MDItemCopyAttribute(metadata, kMDItemAuthors);

      if(artists)
        artist = [artists objectAtIndex:0];
      
      // get alubm artwork
      NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                          forKey:(NSString *)kQLThumbnailOptionIconModeKey];
      
      CFURLRef sourceUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
      CGSize albumArtSize = CGSizeMake(500, 500);
      
      if ([ext isEqualToString:@"mp3"]){
        albumArtSize = CGSizeMake(150,150);
      }
      
      CGImageRef ref = QLThumbnailImageCreate(kCFAllocatorDefault, sourceUrl,
                                              albumArtSize, (__bridge CFDictionaryRef)options);
      if(ref){
        NSString *sanitizedTitle  = [NSString stringWithUTF8String:[title  cStringUsingEncoding:[NSString defaultCStringEncoding]]];
        NSString *sanitizedArtist = [NSString stringWithUTF8String:[artist cStringUsingEncoding:[NSString defaultCStringEncoding]]];
        NSString *sanitizedAlbum  = [NSString stringWithUTF8String:[album  cStringUsingEncoding:[NSString defaultCStringEncoding]]];
        albumArtPath = [[NSString stringWithFormat:@"%@/albumArt_%@_%@_%@.png", appDelegate.temporaryPath, sanitizedTitle, sanitizedArtist, sanitizedAlbum] stringByReplacingOccurrencesOfString:@" " withString:@""];
        CFURLRef destUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:albumArtPath];
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL(destUrl, kUTTypePNG, 1, NULL);
        CGImageDestinationAddImage(destination, ref, nil);
        
        if (!CGImageDestinationFinalize(destination))
          NSLog(@"Failed to write image to %@", path);
        if(destination)
          CFRelease(destination);

      }
    }
    else if ([self isMarkdown]) {
      NSString *rawMarkdown = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
      rawMarkdown = [NSString stringWithFormat:@"%@\n",rawMarkdown];
      NSError *error;
      markdownXHTML = [MMMarkdown HTMLStringWithMarkdown:rawMarkdown error:&error];
    }
  }
  return self;
}

- (NSString *)getMD5FromFile:(NSString *)pathToFile {
  unsigned char outputData[CC_MD5_DIGEST_LENGTH];
  
  NSData *inputData = [[NSData alloc] initWithContentsOfFile:pathToFile];
  CC_MD5([inputData bytes], (int)[inputData length], outputData);
  
  NSMutableString *h = [[NSMutableString alloc] init];
  
  for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
    [h appendFormat:@"%02x", outputData[i]];
  }
  return h;
}

- (BOOL) isMusic {
  if   ([ext isEqualToString:@"mp3"]  || [ext isEqualToString:@"wav"]
     || [ext isEqualToString:@"mpeg"] || [ext isEqualToString:@"amr"]
     || [ext isEqualToString:@"flac"]){
    return YES;
  }
  return NO;
}

- (BOOL) isMarkdown {
  if([ext isEqualToString:@"markdown"] || [ext isEqualToString:@"md"])
    return YES;
  return NO;
}

@end
