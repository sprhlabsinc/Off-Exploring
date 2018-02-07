//
//  Trip.m
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "Trip.h"
#import "OffexConnex.h"
#import "ImageLoader.h"

#pragma mark -
#pragma mark TripViewController Private Interface
/**
 @brief Private method to strip html content from a text string
 
 This interface provides private method used to edit a Blog body text piece, in order to strip out the
 HTML content and return the raw text string for display.
 */
@interface Trip()
#pragma mark Private Method Declarations
/**
 Strips HTML content from downloaded Blog data
 @param html The HTML to strip
 @returns The clean data
 */
- (NSString *)flattenHTML:(NSString *)html;
@end

@implementation Trip

@synthesize tripId;
@synthesize name;
@synthesize description;
@synthesize urlSlug;
@synthesize blogCoverImageURL;
@synthesize blogCoverImageFile;
@synthesize albumCoverImageURL;
@synthesize albumCoverImageFile;
@synthesize videoCoverImageURL;
@synthesize videoCoverImageFile;
@synthesize created;
@synthesize updated;
@synthesize blogCount;
@synthesize albumCount;
@synthesize videoCount;
@synthesize blogs;
@synthesize albums;
@synthesize videos;


#pragma mark Initialization
- (id)initFromDictionary:(NSDictionary *)data {

	if (self = [super init]) {
		self.name = data[@"name"];
		self.description = data[@"description"];
		self.description = [self flattenHTML:description];
		
		self.urlSlug = data[@"slug"];
		if (data[@"blogImage"] != [NSNull null]) {
			self.blogCoverImageURL = data[@"blogImage"];
		}
		if (data[@"albumImage"] != [NSNull null]) {
			self.albumCoverImageURL = data[@"albumImage"];
		}
		self.blogCount = [data[@"blogCount"] intValue];
		self.albumCount = [data[@"albumCount"] intValue];
		
		NSString *filepath = [[NSString alloc] initWithFormat:@"Documents/Trip_BlogImage_%@.png",self.urlSlug]; 
		NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filepath];
		self.blogCoverImageFile = [UIImage imageWithContentsOfFile:pngPath];
		
		if (self.blogCoverImageFile == nil && self.blogCoverImageURL != nil) {
		
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			NSURL *urlToAccess = [NSURL URLWithString: [S3_IMAGE_ADDRESS stringByAppendingString:self.blogCoverImageURL]];
			NSData *data = [NSData dataWithContentsOfURL:urlToAccess options:(NSUInteger)nil error:nil];
			UIImage *downloadImage = [UIImage imageWithData:data];
			
			if (downloadImage == nil) {
				urlToAccess = [NSURL URLWithString: [OFFEX_IMAGE_ADDRESS stringByAppendingString:self.blogCoverImageURL]];
				data = [NSData dataWithContentsOfURL:urlToAccess options:(NSUInteger)nil error:nil];
				downloadImage = [UIImage imageWithData:data];
			}
			
			if (downloadImage != nil) {
				[UIImagePNGRepresentation(downloadImage) writeToFile:pngPath atomically:YES];
				self.blogCoverImageFile = [UIImage imageWithContentsOfFile:pngPath];
			}
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		}
		
		filepath = [[NSString alloc] initWithFormat:@"Documents/Trip_AlbumImage_%@.png",self.urlSlug]; 
		pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filepath];
		self.albumCoverImageFile = [UIImage imageWithContentsOfFile:pngPath];
		if (self.albumCoverImageFile == nil  && self.albumCoverImageURL != nil) {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			
			NSURL *urlToAccess = [NSURL URLWithString: [S3_IMAGE_ADDRESS stringByAppendingString:self.albumCoverImageURL]];
			NSData *data = [NSData dataWithContentsOfURL:urlToAccess options:(NSUInteger)nil error:nil];
			UIImage *downloadImage = [UIImage imageWithData:data];
			
			if (downloadImage == nil) {
				urlToAccess = [NSURL URLWithString: [OFFEX_IMAGE_ADDRESS stringByAppendingString:self.albumCoverImageURL]];
				data = [NSData dataWithContentsOfURL:urlToAccess options:(NSUInteger)nil error:nil];
				downloadImage = [UIImage imageWithData:data];
			}
			if (downloadImage != nil) {
				UIImage *downloadImage = [UIImage imageWithData:data];
				[UIImagePNGRepresentation(downloadImage) writeToFile:pngPath atomically:YES];
				self.albumCoverImageFile = [UIImage imageWithContentsOfFile:pngPath];
			}
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		}
	}
	return self;
}

#pragma mark Pass Through Setters
- (void)setBlogsDataFromArray: (NSArray *)data {
	blogs = [[Blogs alloc] init];
	NSDictionary *parentTrip = @{@"name": self.name, @"urlSlug": self.urlSlug};
	blogs.parentTrip = parentTrip;
	blogs.theTrip = self;
	[blogs setFromArray:data];
}

- (void)setAlbumsDataFromArray: (NSArray *)data {
	albums = [[Albums alloc] init];
	NSDictionary *parentTrip = @{@"name": self.name, @"urlSlug": self.urlSlug};
	albums.parentTrip = parentTrip;
	albums.theTrip = self;
	[albums setFromArray:data];
}

- (void)setVideosDataFromArray:(NSArray *)data {
    videos = [[Videos alloc] init];
	NSDictionary *parentTrip = @{@"name": self.name, @"urlSlug": self.urlSlug};
	videos.parentTrip = parentTrip;
	videos.theTrip = self;
	[videos setFromArray:data];
}

- (NSString *)flattenHTML:(NSString *)html {
	
    NSScanner *theScanner;
    NSString *text = nil;
	
    theScanner = [NSScanner scannerWithString:html];
	
    while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
				[ NSString stringWithFormat:@"%@>", text]
											   withString:@""];
		
    } // while //
    return html;	
}

@end
