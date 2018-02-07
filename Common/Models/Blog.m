//
//  Blog.m
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "Blog.h"
#import "User.h"

@implementation Blog

@synthesize blogid;
@synthesize imageURI;
@synthesize imageFile;
@synthesize thumbURI;
@synthesize thumbFile;
@synthesize body;
@synthesize trip;
@synthesize state;
@synthesize area;
@synthesize geolocation;
@synthesize original_timestamp;
@synthesize timestamp;
@synthesize datetime;
@synthesize rating;
@synthesize views;
@synthesize draft;
@synthesize entryDate;
@synthesize entryTitle;


#pragma mark Blog Creation Methods
- (id)initFromDictionary:(NSDictionary *)data {
	
	if (self = [super init]) {
		self.timestamp = [data[@"timestamp"] intValue];
		self.original_timestamp = [data[@"timestamp"] intValue];
		NSString *theImageURI = (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)data[@"image"], CFSTR("")));
		self.imageURI = theImageURI;
		
		NSString *theThumbURI = (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)data[@"thumbnail"], CFSTR("")));
		self.thumbURI = theThumbURI;
		self.blogid = data[@"id"];
		self.entryTitle = data[@"title"];
	}
	return self;
}

- (void)setFromDictionary:(NSDictionary *)data {
	self.blogid = data[@"id"];
	
	NSString *theImageURI = (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)data[@"image"], CFSTR("")));
	self.imageURI = theImageURI;
	
	NSString *theThumbURI = (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)data[@"thumbnail"], CFSTR("")));
	self.thumbURI = theThumbURI;
	
	self.body = data[@"body"];
	self.rating = [data[@"rating"] intValue];
	self.views = [data[@"views"] intValue];
	self.geolocation = @{@"latitude": @([data[@"location"][@"latitude"] doubleValue]), @"longitude": @([data[@"location"][@"longitude"] doubleValue])};
	self.entryDate = data[@"date"];
	self.entryTitle = data[@"title"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"blogDidLoad" object:nil];
}

#pragma mark Image Accessors
- (NSString *)getImageFilePath {
	
	NSString *filepath = [[NSString alloc] initWithFormat:@"Documents/Blog_%d.jpg",self.original_timestamp]; 
	NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filepath];
	return pngPath;
}

- (NSString *)getTempImageFilePath {
	
	NSString *filepath = [[NSString alloc] initWithFormat:@"Documents/Blog_%d_temp.jpg",self.original_timestamp]; 
	NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filepath];
	return pngPath;
}

- (NSString *)getThumbImageFilePath {
	
	NSString *filepath = [[NSString alloc] initWithFormat:@"Documents/Blog_Thumb_%d.png",self.original_timestamp]; 
	NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filepath];
	return pngPath;
}

- (NSString *)getTempThumbImageFilePath {
	
	NSString *filepath = [[NSString alloc] initWithFormat:@"Documents/Blog_Thumb_%d_temp.png",self.original_timestamp]; 
	NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filepath];
	return pngPath;
}

- (NSString *)getThumbImageFullRemotePath {
	return self.thumbURI;
}

#pragma mark NSCoding Delegate Methods

/**
	NSCoding delegate method. Wraps up the blog into the coder.
 */
- (void)encodeWithCoder: (NSCoder *)coder {
	
	[coder encodeObject: self.blogid forKey:@"blogid"];
	[coder encodeObject: self.imageURI forKey:@"imageURI"];
	[coder encodeObject: self.thumbURI forKey:@"thumbURI"];
	[coder encodeObject: self.body forKey:@"body"];
	[coder encodeObject: self.trip forKey:@"trip"];
	[coder encodeObject: self.state forKey:@"state"];
	[coder encodeObject: self.area forKey:@"area"];
	[coder encodeObject: self.geolocation forKey:@"geolocation"];
	[coder encodeObject: self.datetime forKey:@"datetime"];
	[coder encodeObject: self.entryDate forKey:@"entryDate"];
	[coder encodeObject: self.entryTitle forKey:@"entryTitle"];
	
	NSNumber *theTimestamp = @(self.timestamp);
	[coder encodeObject: theTimestamp forKey:@"timestamp"];
	
	NSNumber *theOriginalTimestamp = @(self.original_timestamp);
	[coder encodeObject: theOriginalTimestamp forKey:@"original_timestamp"];
	
	NSNumber *theRating = @(self.rating);
	[coder encodeObject: theRating forKey:@"rating"];
	
	NSNumber *theViews = @(self.views);
	[coder encodeObject: theViews forKey:@"views"];
	
} 

/**
	NSCoding delegate method. Creates, extracts a blog from the coder and returns it
	@returns The decoded blog object
 */
- (id)initWithCoder: (NSCoder *) coder {
    if (self = [self init] ) {
		self.blogid = [coder decodeObjectForKey:@"blogid"]; 
		self.imageURI = [coder decodeObjectForKey:@"imageURI"];
		self.thumbURI = [coder decodeObjectForKey:@"thumbURI"];
		self.body = [coder decodeObjectForKey:@"body"];
		self.trip = [coder decodeObjectForKey:@"trip"];
		self.state = [coder decodeObjectForKey:@"state"];
		self.area = [coder decodeObjectForKey:@"area"];
		self.geolocation = [coder decodeObjectForKey:@"geolocation"];
		self.datetime = [coder decodeObjectForKey:@"datetime"];
		self.entryDate = [coder decodeObjectForKey:@"entryDate"];
		self.entryTitle = [coder decodeObjectForKey:@"entryTitle"];
		
		self.original_timestamp = [[coder decodeObjectForKey:@"original_timestamp"] intValue];
		self.timestamp = [[coder decodeObjectForKey:@"timestamp"] intValue];
		self.rating = [[coder decodeObjectForKey:@"rating"] intValue];
		self.views = [[coder decodeObjectForKey:@"views"] intValue];
		self.draft = YES;
	}
    return self;
}

#pragma mark Deletion Methods

- (void)deleteBlog {
	if (self.draft == YES) {
		NSFileManager *fileManager = [NSFileManager defaultManager]; 
		User *user = [User sharedUser];
		NSString *folder = [NSString stringWithFormat:@"~/Library/Application Support/Offexploring/Blog_Draft/%@", user.username];
		folder = [folder stringByExpandingTildeInPath];
		
		NSArray *paths = [fileManager contentsOfDirectoryAtPath:folder error:nil];
		
		for (NSString *path in paths) {
			Blog *newBlog = [NSKeyedUnarchiver unarchiveObjectWithFile:[folder stringByAppendingPathComponent:path]];
			if (newBlog.original_timestamp == self.original_timestamp) {
				
				[fileManager removeItemAtPath:[newBlog getImageFilePath] error:nil];
				[fileManager removeItemAtPath:[newBlog getThumbImageFilePath] error:nil];
				[fileManager removeItemAtPath:[newBlog getTempImageFilePath] error:nil];
				[fileManager removeItemAtPath:[newBlog getTempThumbImageFilePath] error:nil];
				
				[fileManager removeItemAtPath:[folder stringByAppendingPathComponent:path] error:nil];
			}
		}
	}
}

@end
