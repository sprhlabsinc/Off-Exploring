//
//  Hostels.h
//  Off Exploring
//
//  Created by Off Exploring on 20/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hostel.h"
#import "Room.h"
#import "OffexConnex.h"

/**
	Static values used on both Off Exploring and the iPhone app to identify the order fo returned hostels
 */
#define HOSTELS_ORDER_DEFAULT			-1
#define HOSTELS_ORDER_SHAREDPRICE		0
#define HOSTELS_ORDER_PRIVATEPRICE		1
#define HOSTELS_ORDER_DISTANCE			2
#define HOSTELS_ORDER_OVERALL           3
#define HOSTELS_ORDER_ATMOSPHERE		4
#define HOSTELS_ORDER_STAFF				5
#define HOSTELS_ORDER_LOCATION			6
#define HOSTELS_ORDER_CLEANLINESS		7
#define HOSTELS_ORDER_FACILITIES		8
#define HOSTELS_ORDER_SAFETY			9
#define HOSTELS_ORDER_FUN				10
#define HOSTELS_ORDER_VALUE				11

/**
	Static values used to identify types of searchs
 */
#define HOSTELS_LOOKUP_PLANNER			0
#define HOSTELS_LOOKUP_SEARCH			1
#define HOSTELS_LOOKUP_BLOG				2

@class Hostels;

#pragma mark -
#pragma mark HostelsLoaderDelegate Declaration

/**
	@brief Details a protocol that must be adheared to, in order to receive Hostels load events and return status.
 
	This protocol allows delegates to be informed if hostels or rooms have been loaded, or if there was an error
 */
@protocol HostelsLoaderDelegate <NSObject>

@required

#pragma mark Required Delegate Methods

/**
	Delegate method called when a connection could not be established to download hostels
	@param hostelLoader The Hostels object
 */
- (void)noConnectionforHostelLoader:(Hostels *)hostelLoader;

@optional

#pragma mark Optional Delegate Methods
/**
	Delegate method called when a successful download of hostels occurs
	@param hostelLoader The Hostels object
	@param city The city the request was made for
	@param country The country the request was made for
	@param range The distance from searched hostels can be returned for
	@param page The page number the request was made for (Off Exploring only returns 5 hostels per page)
 */
- (void)hostelLoader:(Hostels *)hostelLoader
didLoadHostelsforCity:(NSString *)city
			 country:(NSString *)country
			latitude:(double)latitude
		   longitude:(double)longitude
			   range:(double)range
				page:(int)page;

/**
	Delegate method called when an unsuccessful download of hostels occurs
	@param hostelLoader The Hostels object
	@param city The city the request was made for
	@param country The country the request was made for
	@param range The distance from searched hostels can be returned for
	@param page The page number the request was made for (Off Exploring only returns 5 hostels per page)
 */
- (void)hostelLoader:(Hostels *)hostelLoader 
failedToLoadHostelsforCity:(NSString *)city 
			 country:(NSString *)country 
			latitude:(double)latitude
		   longitude:(double)longitude
			   range:(double)range
				page:(int)page;

/**
	Delegate method called when a succesful download of available rooms occurs
	@param hostelLoader The Hostels object
	@param hostelid The hostel database id available rooms were requested for
	@param date The date available rooms were requested for
	@param days The number of days rooms were requested for
 */
- (void)hostelLoader:(Hostels *)hostelLoader
didLoadRoomsforHostelid:(NSUInteger)hostelid
				 date:(NSDate *)date
				 days:(NSUInteger)days;

/**
 Delegate method called when an unsuccesful download of available rooms occurs
 @param hostelLoader The Hostels object
 @param hostelid The hostel database id available rooms were requested for
 @param date The date available rooms were requested for
 @param days The number of days rooms were requested for
 */
- (void)hostelLoader:(Hostels *)hostelLoader 
failedToLoadRoomsforHostelid:(NSUInteger)hostelid 
				 date:(NSDate *)date 
				 days:(NSUInteger)days;

@end

#pragma mark -
#pragma mark Hostels Declaration

/**
 @brief Provides functionality to statically load Hostels and Rooms from a DB, and dynamically request hostels from Off Exploring
 
 This class handles all communication between Off Exploring hostels api, and the iPhone app. In addition, it parses and stores
 Hostel and Room information into a Hostels sqlite database. Static calls can be made to retrieve hostels directly from the database,
 whilst a dynamic one is used to request hostels and rooms from the server. Sets itself to be an OffexploringConnectionDelegate to 
 receive information from a remote source.
 */
@interface Hostels : NSObject <OffexploringConnectionDelegate> {
	
	/**
		A HostelsLoaderDelegate object to be passed return statuses of remote requests 
	 */
	id <HostelsLoaderDelegate> __weak delegate;
	
@private
	
	/**
		An operation que to avoid locking the app whilst parsing hostel data.
	 */
	NSOperationQueue *storeHostelQueue;
	
}

#pragma mark Hostel And Room Database Static Load Methods
/**
	Loads a single Hostel from the sqlite DB, as given by an order method
	@param orderID The method of ordering
	@returns The first Hostel from the DB
 */
+ (Hostel *)loadHostelFromDBorderdBy:(int)orderID;
/**
	Loads all Hostels from the sqlite DB, as given by an order method
	@param orderID The method of ordering
	@returns An array of Hostel objects from the DB
 */
+ (NSArray *)loadHostelsFromDBorderedBy:(int)orderID;
/**
	Loads all Rooms for a given Hostel
	@param hostelid The Hostel database id
	@returns An array of Room objects from the DB
 */
+ (NSArray *)loadRoomsFromDBForHostelid:(int)hostelid;

#pragma mark Hostel And Room Remote Dynamic Load Methods
/**
	Loads Hostels from Off Exploring matching the specified chriteria
	@param area The area being searched
	@param country The country being searched
	@param miles The range from searched hostels may be returned
	@param page The page number requested from Off Exploring (Hostels are paged in groups of 5)
	@param order The method of ordering the returned hostels
 */
- (void)loadHostelsForArea:(NSString *)area country:(NSString *)country within:(NSNumber *)miles page:(NSNumber *)page orderedBy:(NSNumber *)order;

/**
	Loads Hostels from Off Exploring matching the specified chriteria
	@param area The area being searched
	@param country The country being searched
	@param latitude The latitude to search at
	@param longitude The longitude to search at
	@param miles The range from searched hostels may be returned
	@param page The page number requested from Off Exploring (Hostels are paged in groups of 5)
	@param order The method of ordering the returned hostels
 */
- (void)loadHostelsForArea:(NSString *)area country:(NSString *)country latitide:(NSNumber *)latitude longitude:(NSNumber *)longitude within:(NSNumber *)miles page:(NSNumber *)page orderedBy:(NSNumber *)order;
/**
	Loads the available rooms for a given hostel on a given day for a given number of days
	@param hostel The hostel rooms are being requested for
	@param date The start date that the room must be available from
	@param days The number of nights intended upon being stayed
 */
- (void)loadRoomsForHostel:(Hostel *)hostel forDate:(NSDate *)date forDays:(NSUInteger)days;

@property (nonatomic, weak) id <HostelsLoaderDelegate> delegate;

@end
