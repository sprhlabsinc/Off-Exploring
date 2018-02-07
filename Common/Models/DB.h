//
//  DB.h
//  Off Exploring
//
//  Created by Off Exploring on 29/07/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#pragma mark -
#pragma mark DB Interface

/**
 @brief A utility class that provides database access from a Singleton object
 
 This class creates and returns an initialised Singleton object used to communicate
 with a sqlite3 database. It provides methods to reset the Hostels tables, the Rooms 
 table and the Itinerary table.
 */
@interface DB : NSObject {
	/**
		A sqlite3 database struct used to communicate with the database
	 */
	sqlite3 *database;
}

#pragma mark Singleton Access
/**
	Returns a Singleton DB object. Creates tables on database if needed
	@returns The DB object
 */
+ (DB *)sharedDB;

#pragma mark DB Reset Methods
/**
	Resets all the hostels DB tables (hostels, hostel_images, hostel_ratings etc)
	@returns A success state
 */
- (BOOL)emptyHostelsDB;
/**
	Resets the rooms table
	@returns A success state
 */
- (BOOL)emptyRoomsTable;
/**
	Resets the Itinerary table for a perticular user
	@param username The user having their hostel DB reset
	@returns A success state
 */
- (BOOL)emptyItineraryDBForUsername:(NSString *)username;

@property (nonatomic, assign) sqlite3 *database;

@end
