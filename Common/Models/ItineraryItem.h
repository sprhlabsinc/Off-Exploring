//
//  ItineraryItem.h
//  Off Exploring
//
//  Created by Off Exploring on 14/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief An object representing a single ItineraryItem as part of a Users planned Off Exploring journey.
 
 This object represents one ItineraryItem, wrapping up key information about it. The object is part of
 a plannned Journey array of objects belonging to a User
 */
@interface ItineraryItem : NSObject {

	/**
		The database id for the item on Off Exploring
	 */
	int itemid;
	/**
		The timestamp of when the item will be visited
	 */
	NSTimeInterval timestamp;
	/**
		The state where the item is
	 */
	NSString *state;
	/**
		The arew where the item is
	 */
	NSString *area;
	/**
		The latitude of the item
	 */
	double latitude;
    /**
    	The longitude of the item
     */
    double longitude;
	
}

/**
	Creates and returns an ItineraryItem from a dictionary of data
	@param dict The data
	@returns The ItineraryItem
 */
- (id)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, assign) int itemid;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *area;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@end
