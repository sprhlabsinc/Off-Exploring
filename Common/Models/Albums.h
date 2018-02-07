//
//  Albums.h
//  Off Exploring
//
//  Created by Off Exploring on 20/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Album.h"

@class Trip;

/**
 @brief A collection object containing an array of albums, ordered by date. 
 
 This is a collection providing adding, deletion and reloading of an ordered array of Albums.
 Using insertAlbum: and deleteAlbum: keeps the array indexed and ordered correctly. It also handles
 duplicates appropriately.
 */
@interface Albums : NSObject {

	/**
		An array of albums ordered by date.
	 */
	NSMutableArray *albums;
	/**
		Key trip information to pass to Albums
	 */
	NSDictionary *parentTrip;
	/**
		A pointer to the trip this albums object belongs to.
	 */
	Trip *__weak theTrip;
}

#pragma mark Albums Collection Management

/**
	Adds album objects from a data array
	@param data The array of data
 */
- (void)setFromArray:(NSArray *)data;

/**
	Adds one album to the array of albums in the correct position
	@param album The album to insert
 */
- (void)insertAlbum:(Album *)album;

/**
	Deletes an album from the albums array, maintaining indexs
	@param album The album to delete
 */
- (void)deleteAlbum:(Album *)album;

@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, strong) NSDictionary *parentTrip;
@property (nonatomic, weak) Trip *theTrip;

@end
