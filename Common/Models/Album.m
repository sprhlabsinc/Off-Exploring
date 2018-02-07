//
//  Album.m
//  Off Exploring
//
//  Created by Off Exploring on 20/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "Album.h"
#import "OffexConnex.h"
#import "Photo.h"

@implementation Album

@synthesize imageURI;
@synthesize name;
@synthesize slug;
@synthesize photoCount;
@synthesize trip;
@synthesize photos;
@synthesize state;
@synthesize area;
@synthesize geolocation;
@synthesize albumID;


#pragma mark Initialisation

- (id)initFromDictionary:(NSDictionary *)data {

	if (self = [super init]) {
        
        NSString *theImageURI = (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)data[@"image"], CFSTR("")));
		
		self.imageURI = theImageURI;
		
		self.name = data[@"name"];
		self.slug = data[@"slug"];
		self.photoCount = [data[@"photoCount"] intValue];
		
		if (data[@"state"] != [NSNull null]) {
			self.state = data[@"state"];
		}
		if (data[@"area"] != [NSNull null]) {
			self.area = data[@"area"];
		}
		self.geolocation = data[@"location"];
		self.albumID = data[@"id"];
	}
	return self;
}

#pragma mark Image Accessors

- (NSString *)getImageFilePath {
	
	NSString *filepath = [[NSString alloc] initWithFormat:@"Documents/Album_%@.png", self.albumID]; 
	NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filepath];
	return pngPath;
}

- (NSString *)getThumbImageFilePath {
	
	NSString *filepath = [[NSString alloc] initWithFormat:@"Documents/Album_Thumb_%@.png", self.albumID]; 
	NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filepath];
	return pngPath;
}

- (NSString *)getThumbImageFullRemotePath {
	return self.imageURI;
}

#pragma mark Photos Collection Management

- (void)setPhotosDataFromArray: (NSArray *)data {
	photos = [[NSMutableArray alloc] init];
	NSDictionary *aPhoto;
	for (aPhoto in data) {
		Photo *photo = [[Photo alloc] initWithDictionary:aPhoto];
		photo.album = @{@"albumname": self.name, @"urlSlug": self.slug};
		photo.trip = self.trip;
		[self.photos addObject:photo];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"photosDataDidLoad" object:nil];
}

- (void)addPhoto:(Photo *)photo {
	if (self.photos == nil) {
		photos = [[NSMutableArray alloc] init];
	}
	
	int count = 0;
	for (Photo *aPhoto in self.photos) {
		if ([photo.photoid isEqualToString:aPhoto.photoid]) {
			(self.photos)[count] = photo;
			return;
		}
		count++;
	}
	[self.photos addObject:photo];
	self.photoCount = self.photoCount +1;
	if (self.photoCount == 1) {
		self.imageURI = photo.thumbURI;
	}
}

- (void)deletePhoto:(Photo *)photo {
	int count = 0;
	for (Photo *aPhoto in self.photos) {
		if ([photo.photoid isEqualToString:aPhoto.photoid]) {
			[self.photos removeObjectAtIndex:count];
			self.photoCount = self.photoCount -1;
			return;
		}
		count++;
	}
}

@end
