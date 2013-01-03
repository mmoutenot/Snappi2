//
//  SNFile.h
//  Snappi
//
//  Created by Marshall Moutenot on 1/1/13.
//  Copyright (c) 2013 Marshall Moutenot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNFile : NSObject {
  NSString *path;
  NSString *name;
  NSString *ext;
  NSString *hash;
  
  // Music Specific
  NSString *title;
  NSString *album;
  NSString *artist;
  NSString *albumArtPath;
  NSImage  *albumArt;
  
  // Markdown Specific
  NSString *markdownXHTML;
}

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *ext;
@property (strong, nonatomic) NSString *hash;

// Music Specific
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *album;
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) NSString *albumArtPath;
@property (strong, nonatomic) NSImage  *albumArt;

- (BOOL) isMusic;

// Markdown Specific
@property (strong, nonatomic) NSString *markdownXHTML;

- (BOOL) isMarkdown;

- (id) initWithPath:(NSString *)p;
  
@end
