//
//  Room.h
//  Off Exploring
//
//  Created by Off Exploring on 06/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief An object representing a Room at a Hostel
 
 This object represents one Room, wrapping up key information about
 it.
 */
@interface Room : NSObject {

	/**
		The room database id on Off Exploring
	 */
	int roomid;
	/**
		The hostel database id on Off Exploring this room belongs to
	 */
	int hostelid;
	/**
		The number of beds available in this room
	 */
	int beds;
	/**
		The number of beds that must be booked together when booking this room
	 */
	int blockbeds;
	/**
		The price per person of booking a bed in this room
	 */
	double pricefrom;	
	/**
		The currency this price was recorded in
	 */
	NSString *currency;
	/**
		The name of the room (eg. private twin)
	 */
	NSString *roomName;
	/**
		The date the room is available from
	 */
	NSDate *startDate;
	/**
		The date the room is available to
	 */
	NSDate *endDate;
	/**
		The length of time this object is valid for
	 */
	NSDate *expiry;
		
}

/**
	Creates and returns the room from a dictionary of data
	@param dict The data
	@returns The initialised room
 */
- (id)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, assign, readonly) int roomid;
@property (nonatomic, assign, readonly) int hostelid;
@property (nonatomic, assign, readonly) int beds;
@property (nonatomic, assign, readonly) int blockbeds;
@property (nonatomic, assign, readonly) double pricefrom;
@property (nonatomic, strong, readonly) NSString *currency;
@property (nonatomic, strong, readonly) NSString *roomName;
@property (nonatomic, strong, readonly) NSDate *startDate;
@property (nonatomic, strong, readonly) NSDate *endDate;
@property (nonatomic, strong, readonly) NSDate *expiry;

@end
