//
//  Trips.h
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trip.h"

/**
 @brief A custom collection of Off Exploring Trip objects.
 
 Stores a collection of Off Exploring Trip objects that can be added to or removed from. Must 
 be set from an array of data objects
 */
@interface Trips : NSObject {
	
	/**
		The array of Trip objects
	 */
	NSMutableArray *tripsArray;
	
}

/**
	Builds the array of trips from the data array param
	Posts an NSNotification upon completion.
	@param data Data array of trips
 */
- (void)setFromArray:(NSArray *)data;

/**
	Adds or replaces a trip in the trips array
	@param trip The trip to add / replace
 */
- (void)insertTrip:(Trip *)trip;

/**
 Deletes a trip from the trips array, maintaining indexs
 @param trip The trip to delete
 */
- (void)deleteTrip:(Trip *)trip;

@property(nonatomic, strong) NSMutableArray *tripsArray;

@end
