//
//  Albums.m
//  Off Exploring
//
//  Created by Off Exploring on 20/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "Albums.h"
#import "Album.h"
#import "Trip.h"

@implementation Albums

@synthesize albums;
@synthesize parentTrip;
@synthesize theTrip;


#pragma mark Albums Collection Management

- (void)setFromArray:(NSArray *)data {
	
	self.albums = [NSMutableArray array];
	
	NSDictionary *aAlbum;
	
	for (aAlbum in data) {
	
		Album *album = [[Album alloc] initFromDictionary:aAlbum];
		album.trip = parentTrip;
		[albums addObject:album];
		
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"albumsDataDidLoad" object:nil];
}

- (void)insertAlbum:(Album *)album {
	
	int count = 0;
	for (Album *anAlbum in self.albums) {
		if ([album.albumID isEqualToString:anAlbum.albumID]) {
			(self.albums)[count] = album;
			return;
		}
		count++;
	}
	
	[self.albums addObject:album];
	theTrip.albumCount++;
}

- (void)deleteAlbum:(Album *)album {
	
	int count = 0;
	for (Album *anAlbum in self.albums) {
		if (album == anAlbum) {
			[[NSFileManager defaultManager] removeItemAtPath:[album getThumbImageFilePath] error:nil];
			[self.albums removeObjectAtIndex:count];
			theTrip.albumCount--;
			return;
		}
		count++;
	}
	
}

@end
