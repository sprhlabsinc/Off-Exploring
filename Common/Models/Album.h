//
//  Album.h
//  Off Exploring
//
//  Created by Off Exploring on 20/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"

/**
 @brief An object representing one Off Exploring Album, and manages a collection of Photos  
 
 This object represents one Off Exploring Album, wrapping up key information about
 an album and providing accessors to its images. The remote image methods appropriatly wrap
 URLs for the album cover image. The collection methods provide managed access to the array of 
 Photos inside the album
 */
@interface Album : NSObject {
	
	/**
		The database id for the album on Off Exploring.
	 */
	NSString *albumID;
	/**
		The remote cover image URI
	 */
	NSString *imageURI;
	/**
		The name of the album
	 */
	NSString *name;
	/**
		The slug for the album
	 */
	NSString *slug;
	/**
		The name of the state this album was posted about
	 */
	NSString *state;
	/**
		The name of the area this album was posted about
	 */
	NSString *area;
	/**
		A dictionary containing the latitude and longitude of the blog post
	 */
	NSDictionary *geolocation;
	/**
		The number of photos the album has in it.
	 */
	int photoCount;
	/**
		Dictionary containing the name and the slug of the trip this album belongs to
	 */
	NSDictionary *trip;
	/**
		A ordered collection of photos this album wraps around
	 */
	NSMutableArray *photos;
}

#pragma mark Initialisation
/**
	Creates and returns an album object initialised from data
	@param data The data to setup the object
	@returns The Album object
 */
- (id)initFromDictionary:(NSDictionary *)data;

#pragma mark Image Accessors
/**
	Returns the local cover image file path
	@returns The file path
 */
- (NSString *)getImageFilePath;
/**
	Returns the local cover image thumbnail file path
	@returns The file path
 */
- (NSString *)getThumbImageFilePath;
/**
	Returns the remote cover image path
	@returns The remote path
 */
- (NSString *)getThumbImageFullRemotePath;

#pragma mark Photos Collection Management
/**
	Creates and sets an array of photos from data
	@param data The data
 */
- (void)setPhotosDataFromArray:(NSArray *)data;
/**
	Adds a photo to the photos array, maintaining indexs
	@param photo The photo to add
 */
- (void)addPhoto:(Photo *)photo;
/**
	Removes a photo from the photos array, maintaining indexs
	@param photo The photo to remove
 */
- (void)deletePhoto:(Photo *)photo;

@property (nonatomic, strong) NSString *imageURI;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSDictionary *trip;
@property (nonatomic, assign) int photoCount; 
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *area;
@property (nonatomic, strong) NSDictionary *geolocation;
@property (nonatomic, strong) NSString *albumID;
@end
