//
//  OffexConnex.h
//  Off Exploring
//
//  Created by Off Exploring on 23/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Blog.h"
#import "Constants.h"

@class OffexConnex;

#pragma mark -
#pragma mark OffexploringConnectionDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive remote information loaded from the Off Exploring API.
 
	This protocol allows delegates to be given signals in relation to Off Exploring API connection and responses.
 */
@protocol OffexploringConnectionDelegate <NSObject>

#pragma mark Required Delegate Methods
@required

/**
	Delegate method called on Successful (Status code:200) call to Off Exploring API, passing a JSON parsed dictionary of results
	@param offex The OffexConnex object used to make the 
	@param results The NSDictionary of results
 */
- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results;

#pragma mark Optional Delegate Methods
@optional

/**
	Delegate method called to signal a succesful connection to the URI (Status code:200), called before JSON parsing begins
	@param offex The OffexConnex object used to make the connection
	@param uri The URI being connected to
	@note This is currently not used / implemented in the app, as of 24.0.9.2010 and is declared for convienience only.
 */
- (void)offexploringConnection:(OffexConnex *)offex didConnectToURI:(NSString *)uri;
/**
	Delegate method called to signal a failed connection to the Off Exploring API
	@param offex The OffexConnex object used to make the connection
	@param error An NSError object containing the connection error
 */
- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *)error;

@end

#pragma mark -
#pragma mark OffexConnex Declaration
/**
	@brief Provides functionality to load data from Off Exploring API
 
	This class handles all communication between the iPhone app and Off Exploring on the internet. The class interfaces with
	the Off Exploring API at http://api.offexploring.com and parses its REST implementation in the JSON format, using the JSON
	library attached. The class handles errors by wrapping them up into an NSError object and returning this to the delegate,
	and passes the successfuly parsed JSON data into an NSDictionary and passes this to the delegate. The class provides POST, 
	GET and DELETE implementaions, appropriately escaping strings and correctly character encoding them using NSUTF8StringEncoding.
	The class also generates a CRC hash for posted data, and transmits this along with the data for the server to validate in case
	of transmission error.
 */
@interface OffexConnex : NSObject {
	
	/**
		An OffexploringConnectionDelegate class to passed connection messages 
	 */
	id <OffexploringConnectionDelegate> __weak delegate;
    
    /** 
        Access to the request object
     */
    NSURLRequest *__request;
    
@private 
	/**
    	An asynchronus connection handler
     */
    NSURLConnection *offexploringConnection;
    /**
    	A mutable data store to keep data returned from Off Exploring as its being downloaded
     */
    NSMutableData *offexploringData;
}

#pragma mark Connection Construction Methods
/**
	Returns a correctly formatted Hostels API URI from the given URI
	@param uri The URI being requested
	@returns The formatted URI
 */
- (NSString *)buildHBRequestStringWithURI:(NSString *)uri;
/**
	Returns a correctly formatted Off Exploring API URI from the given URI
	@param uri The URI being requested
	@returns The formatted URI
 */
- (NSString *)buildOffexRequestStringWithURI:(NSString *)uri;
/**
	Returns a correctly formatted Off Exploring API URI from the given URI, with the username and password allowed to be specified directly
	@param uri The URI being request
	@param username The username to request with
	@param password The password to request with
	@returns The formatted URI
 */
- (NSString *)buildAuthenticatedOffexRequestStringWithURI:(NSString *)uri andUsername:(NSString *)username andPassword:(NSString *)password;
/**
	Returns an NSData object encapuslating NSUTF8CharacterEncoded data from a given NSDictionary. Adds CRC data to each key check. 
	@param dict The data dictionary to be encoded
	@returns The NSData object
 */
- (NSData *)paramaterBodyForDictionary:(NSDictionary *)dict;
/**
	Returns an NSData object encapuslating a single image, and a data dictionary 
	@param image The image to encapuslate in data
	@param boundary A string boundry to use in the HTTP request
	@param filename A filename to give the image
	@param dict The data dictionary to be encapsulated
	@returns The NSData object
 */
- (NSData *)parameterBodyForImage:(UIImage *)image andBoundary:(NSString *)boundary andFilename:(NSString *)filename andDictionary:(NSDictionary *)dict;

#pragma mark Connection Methods
/**
	Starts a remote GET request to the given URL
	@param urlString The URL to make the request to
 */
- (void)beginLoadingOffexploringDataFromURL:(NSString *)urlString;
/**
	Stars a remote POST request to the given URL with the given data
	@param dataString The data to post
	@param contentMode The method to post by
	@param urlString The URL to make the request to
 */
- (void)postOffexploringData:(NSData *)dataString withContentMode:(NSString *)contentMode toURL:(NSString *)urlString;
/**
	Starts a remote DELETE request to the given URL
	@param urlString The URL to make the request to
 */
- (void)deleteOffexploringDataAtUrl:(NSString *)urlString;

/**
 Encodes, escapes and returns the given string using CF library CFURLCreateStringByAddingPercentEscapes method
 @param str The string to encode
 @returns The encoded string
 */
- (NSString *)urlEncodeValue:(NSString *)str;

@property (nonatomic, weak) id <OffexploringConnectionDelegate> delegate;
@property (nonatomic, strong) NSURLRequest *request;

@end
