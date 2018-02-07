//
//  Photo.m
//  Off Exploring
//
//  Created by Off Exploring on 20/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@synthesize photoid;
@synthesize caption;
@synthesize imageURI;
@synthesize thumbURI;
@synthesize description;
@synthesize trip;
@synthesize album;
@synthesize theImage;
@synthesize state;
@synthesize albumName;
@synthesize imageDownloading;


#pragma mark Initialisation

- (id)initWithDictionary:(NSDictionary *)data {

	if (self = [super init]) {
		
		self.photoid = data[@"id"];
		if (data[@"caption"] != [NSNull null]) {
			self.caption = data[@"caption"];
		}
		if (data[@"description"] != [NSNull null]) {
			self.description = data[@"description"];
		}
		
        NSString *imageURIString = (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)data[@"image"], CFSTR("")));
        self.imageURI = imageURIString;
        
        NSString *thumbURIString = (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)data[@"thumbnail"], CFSTR("")));
		self.thumbURI = thumbURIString;
		
		if (data[@"state"] != [NSNull null]) {
			self.state = data[@"state"];
		}
		
		if (data[@"albumname"] != [NSNull null]) {
			self.albumName = data[@"albumname"];
		}
		
		self.imageDownloading = NO;
	}
	return self;
	
}

#pragma mark Image Accesors

- (NSString *)getThumbImageFullRemotePath {
	return self.thumbURI;
}

- (NSString *)getImageFullRemotePath {
	return self.imageURI;
}

@end
