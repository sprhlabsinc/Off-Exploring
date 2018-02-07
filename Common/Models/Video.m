//
//  Video.m
//  Off Exploring
//
//  Created by Ian Outterside on 06/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Video.h"
#import "ImageLoader.h"

@implementation Video

@synthesize imageURI;
@synthesize title;
@synthesize video_description;
@synthesize trip;
@synthesize state;
@synthesize area;
@synthesize geolocation;
@synthesize videoID;
@synthesize processing;
@synthesize videoPath;
@synthesize localVideoPath;
@synthesize failedUpload;


#pragma mark Initialisation

- (id)initFromDictionary:(NSDictionary *)data {
    
	if (self = [super init]) {
        
        NSString *theImageURI = (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)data[@"thumbnail"], CFSTR("")));
		
		self.imageURI = theImageURI;
		
		self.title = data[@"title"];
		self.video_description = data[@"description"];
		
		if (data[@"state"] != [NSNull null]) {
			self.state = data[@"state"];
		}
		if (data[@"area"] != [NSNull null]) {
			self.area = data[@"area"];
		}
		self.geolocation = data[@"location"];
		self.videoID = data[@"id"];
        
        if ([data[@"processing"] isEqualToString:@"complete"]) {
            self.processing = NO;
            self.failedUpload = NO;
        }
        else if ([data[@"processing"] isEqualToString:@"failed"]) {
            self.processing = NO;
            self.failedUpload = YES;
        }
        else {
            self.processing = YES;
            self.failedUpload = NO;
        }
        
        self.videoPath = data[@"filename"];
	}
	return self;
}

#pragma mark Image Accessors

- (NSString *)getImageFilePath {
	
	NSString *filepath = [[NSString alloc] initWithFormat:@"Documents/Video_%@.png", self.videoID]; 
	NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filepath];
	return pngPath;
}

- (NSString *)getThumbImageFilePath {
	
    if (self.processing || self.failedUpload) {
        NSString *myFilePath = [[NSBundle mainBundle]
                                pathForResource:@"processing"
                                ofType:@"png"];
        return myFilePath;
    }
    else {
        NSString *filepath = [[NSString alloc] initWithFormat:@"Documents/Video_Thumb_%@.png", self.videoID]; 
        NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filepath];
        return pngPath;
    }
}

- (NSString *)getThumbImageFullRemotePath {
	return self.imageURI;
}

- (NSURL *)videoRemotePath {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", S3_IMAGE_ADDRESS, self.videoPath]];
}

@end
