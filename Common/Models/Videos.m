//
//  Videos.m
//  Off Exploring
//
//  Created by Ian Outterside on 06/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Videos.h"
#import "Video.h"
#import "Trip.h"

@implementation Videos

@synthesize videos;
@synthesize parentTrip;
@synthesize theTrip;


#pragma mark Albums Collection Management

- (void)setFromArray:(NSArray *)data {
	
	self.videos = [NSMutableArray array];
	
	for (NSDictionary *aVideo in data) {
		Video *video = [[Video alloc] initFromDictionary:aVideo];
		video.trip = parentTrip;
		[videos addObject:video];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"videoDataDidLoad" object:nil];
}

- (void)insertVideo:(Video *)video {
	
	int count = 0;
	for (Video *anVideo in self.videos) {
		if ([video.videoID isEqualToString:anVideo.videoID]) {
			(self.videos)[count] = video;
			return;
		}
		count++;
	}
	
	[self.videos addObject:video];
	theTrip.videoCount++;
}

- (void)deleteVideo:(Video *)video {
	
	int count = 0;
	for (Video *anVideo in self.videos) {
		if (video == anVideo) {
			[[NSFileManager defaultManager] removeItemAtPath:[video getThumbImageFilePath] error:nil];
			[self.videos removeObjectAtIndex:count];
			theTrip.videoCount--;
			return;
		}
		count++;
	}
	
}

@end