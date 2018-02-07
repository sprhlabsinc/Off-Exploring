//
//  Photo.h
//  Off Exploring
//
//  Created by Off Exploring on 20/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief An object representing one Off Exploring Photo
 
 This object represents one Off Exploring Photo, wrapping up key information about
 a blog and providing accessors to its paths.
 */
@interface Photo : NSObject {

	/**
		The Off Exploring database id for the photo
	 */
	NSString *photoid;
	/**
		The caption for the photo
	 */
	NSString *caption;
	/**
		The full size remote path
	 */
	NSString *imageURI;
	/**
		The thumbnail remote path
	 */
	NSString *thumbURI;
	/**
		The photo description
	 */
	NSString *description;
	/**
		Dictionary containing the name and slug of the trip this photo belongs to
	 */
	NSDictionary *trip;
	/**
		Dictionary containing the name and slug of the album this photo belongs to
	 */
	NSDictionary *album;
	/**
		The photo image
	 */
	UIImage *theImage;
	/**
		The name of the state this photo belongs to
	 */
	NSString *state;
	/**
		The name of the area this photo belongs to
	 */
	NSString *albumName;
	/**
		A boolean flag to set that the image is being downloaded
	 */
	BOOL imageDownloading;
}

#pragma mark Initialisation
/**
	Creats and returns the Photo from a dictionary of data
	@param data The data
	@returns The photo
 */
- (id)initWithDictionary:(NSDictionary *)data;

#pragma mark Image Accesors
/**
	Returns the full remote path for the thumbnail of the image
	@returns The remote path
 */
- (NSString *)getThumbImageFullRemotePath;
/**
	Returns the full remote path for the image
	@returns The remote path
 */
- (NSString *)getImageFullRemotePath;

@property (nonatomic, strong) NSString *photoid;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *imageURI;
@property (nonatomic, strong) NSString *thumbURI;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSDictionary *trip;
@property (nonatomic, strong) NSDictionary *album;
@property (nonatomic, strong) UIImage *theImage;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, assign) BOOL imageDownloading;

@end
