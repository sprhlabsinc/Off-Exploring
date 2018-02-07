//
//  Videos.h
//  Off Exploring
//
//  Created by Ian Outterside on 06/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Video.h"

@class Trip;

/**
 @brief A collection object containing an array of videos, ordered by date. 
 
 This is a collection providing adding, deletion and reloading of an ordered array of videos.
 Using insertVideo: and deleteVideo: keeps the array indexed and ordered correctly. It also handles
 duplicates appropriately.
 */
@interface Videos : NSObject {
    
	/**
     An array of videos ordered by date.
	 */
	NSMutableArray *videos;
	/**
     Key trip information to pass to Videos
	 */
	NSDictionary *parentTrip;
	/**
     A pointer to the trip this videos object belongs to.
	 */
	Trip *__weak theTrip;
}

#pragma mark Videos Collection Management

/**
 Adds video objects from a data array
 @param data The array of data
 */
- (void)setFromArray:(NSArray *)data;

/**
 Adds one video to the array of videos in the correct position
 @param video The video to insert
 */
- (void)insertVideo:(Video *)video;

/**
 Deletes an video from the videos array, maintaining indexs
 @param video The video to delete
 */
- (void)deleteVideo:(Video *)video;

@property (nonatomic, strong) NSMutableArray *videos;
@property (nonatomic, strong) NSDictionary *parentTrip;
@property (nonatomic, weak) Trip *theTrip;


@end
