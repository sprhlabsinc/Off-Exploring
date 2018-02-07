//
//  Hostel.h
//  Off Exploring
//
//  Created by Off Exploring on 06/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief An object representing a Hostel
 
 This object represents one Hostel, wrapping up key information about
 it and providing accessors to its other information (images, features, price).
 */
@interface Hostel : NSObject {

	/**
		The hostel id on Off Exploring
	 */
	int hostelid;
    /**
    	The hostel name
     */
    NSString *name;
    /**
    	The first line of the hostels address
     */
    NSString *street1;
    /**
    	The second line of the hostels address
     */
    NSString *street2;
	/**
		The third line of the hostels address
	 */
	NSString *street3;
    /**
    	The hostels city
     */
    NSString *city;
    /**
    	The hostels state
     */
    NSString *state;
    /**
    	The hostels country
     */
    NSString *country;
    /**
    	The hostels ZIP / Postal code
     */
    NSString *zip;
    /**
    	A short description of the hostel
     */
    NSString *shortdescription;
    /**
    	A long description of the hostel
     */
    NSString *longdescription;
	/**
		A URI to a map of the hostel (not used as of 23.09.2010
	 */
	NSString *map;
	/**
		Important information about booking for this hostel
	 */
	NSString *importantinfo;
    /**
    	String check in time
     */
    NSString *checkin;
    /**
    	String check out time
     */
    NSString *checkout;
	/**
		The latitude of the hostel
	 */
	double latitude;
    /**
    	The longitude of the hostel
     */
    double longitude;
    /**
    	The distance of the hostel from the searched location
     */
    double distance;
	/**
		The overall rating of the hostel
	 */
	double overall;
	/**
		The atmostphere rating of the hostel
	 */
	double atmosphere;
	/**
		The staff rating of the hostel
	 */
	double staff;
	/**
		The location rating of the hostel
	 */
	double location;
	/**
		The cleanliness rating of the hostel
	 */
	double cleanliness;
	/**
		The facilities rating of the hostel
	 */
	double facilities;
	/**
		The safety rating of the hostel
	 */
	double safety;
	/**
		The fun rating fo the hostel
	 */
	double fun;
	/**
		The value rating of the hostel
	 */
	double value;
	/**
		Array of image URIs for this hostel
	 */
	NSArray *images;
	/**
		Array of thumb URIs for this hostel
	 */
	NSArray *thumbs;
	/**
		Array of features this hostel provides
	 */
	NSArray *features;	
	/**
		The lowest estimated shared price per person for this hostel
	 */
	double sharedprice;
	/**
		The lowest estimated private price per person for this hostel
	 */
	double privateprice;
	
}

#pragma mark Initalisation 
/**
	Creates and returns a Hostel from a dictionary of data
	@param aHostel The hostel data
	@returns The Hostel object
 */
- (id)initWithDictionary:(NSDictionary *)aHostel;

#pragma mark Accessors
/**
	Returns an array of URI strings for images of this hostel
	@param thumbURI Flag for returning full size or thumbmail array
	@returns The array of strings
 */
- (NSArray *)loadImages:(BOOL)thumbURI;
/**
	Returns and array of features of this hostel
	@returns The features
 */
- (NSArray *)loadFeatures;
/**
	Returns a dictionary containing the lowest estimated price for this hostel, and 
	whether is a private or shared price being returned.
	@returns The price information
 */
- (NSDictionary *)lowestPrice;

@property (nonatomic, assign, readonly) int hostelid;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *street1;
@property (nonatomic, strong, readonly) NSString *street2;
@property (nonatomic, strong, readonly) NSString *street3;
@property (nonatomic, strong, readonly) NSString *city;
@property (nonatomic, strong, readonly) NSString *state;
@property (nonatomic, strong, readonly) NSString *country;
@property (nonatomic, strong, readonly) NSString *zip;
@property (nonatomic, strong, readonly) NSString *shortdescription;
@property (nonatomic, strong, readonly) NSString *longdescription;
@property (nonatomic, strong, readonly) NSString *map;
@property (nonatomic, strong, readonly) NSString *importantinfo;
@property (nonatomic, strong, readonly) NSString *checkin;
@property (nonatomic, strong, readonly) NSString *checkout;
@property (nonatomic, assign, readonly) double latitude;
@property (nonatomic, assign, readonly) double longitude;
@property (nonatomic, assign, readonly) double distance;
@property (nonatomic, assign, readonly) double overall;
@property (nonatomic, assign, readonly) double atmosphere;
@property (nonatomic, assign, readonly) double staff;
@property (nonatomic, assign, readonly) double location;
@property (nonatomic, assign, readonly) double cleanliness;
@property (nonatomic, assign, readonly) double facilities;
@property (nonatomic, assign, readonly) double safety;
@property (nonatomic, assign, readonly) double fun;
@property (nonatomic, assign, readonly) double value;
@property (nonatomic, assign, readonly) double sharedprice;
@property (nonatomic, assign, readonly) double privateprice;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *thumbs;
@property (nonatomic, strong) NSArray *features;

@end
