//
//  Trip.h
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Blogs.h"
#import "Albums.h"
#import "Videos.h"

/**
 @brief An object representing an Off Exploring Trip. 
 
 Off Exploring Users have trips which store various content. Each trip can have Blogs, Photos 
 and Videos (not implemented yet - 22.09.10). Users can have multiple trips spanning various 
 time periods. Currently, trips are not live on Off Exploring so this object is simply a wrapper.
 */
@interface Trip : NSObject {

	/**
		The database id of the Trip on Off Exploring
	 */
	NSString *tripId;
	/**
		The name of the trip
	 */
	NSString *name;
	/**
		The description of the trip
	 */
	NSString *description;
	/**
		The API slug for this trip
	 */
	NSString *urlSlug;
	/**
		URL for the thumbnail to be used when display blog content for this trip.
	 */
	NSString *blogCoverImageURL;
	/**
		URL for the thumbnail to be used when display album content for this trip.
	 */
	NSString *albumCoverImageURL;
	/**
		URL for the thumbnail to be used when display video content for this trip. Not in use - as of 22.09.2010
	 */
	NSString *videoCoverImageURL;
	/**
		The Image to be used when display blog content for this trip.
	 */
	UIImage	*blogCoverImageFile;
	/**
	 The Image to be used when display album content for this trip.
	 */
	UIImage *albumCoverImageFile;
	/**
	 The Image to be used when display video content for this trip. Not in use - as of 22.09.2010
	 */
	UIImage *videoCoverImageFile;
	/**
		The date the trip was created
	 */
	NSDate *created;
	/**
		The date the trip was last updated
	 */
	NSDate *updated;
	/**
		The number of blogs belonging to this trip
	 */
	int blogCount;
	/**
		The number of albums belonging to this trip
	 */
	int albumCount;
	/**
		The number of videos belonging to this trip
	 */
	int videoCount;
	
	/**
		The Blogs collection of Blog objects beloning to this trip
	 */
	Blogs *blogs;
	/**
		The Albums collection of Album objects belonging to this trip
	 */
	Albums *albums;
    
    /** 
        The Video collection of Video objects belonging to this trip
     */
    Videos *videos;
}

#pragma mark Initialization
/**
	Creates and returns a Trip object, initialized with data
	@param data The initalizing data
	@returns The returned Trip object
 */
- (id)initFromDictionary:(NSDictionary *)data;

#pragma mark Pass Through Setters
/**
	Sets the data used to build Blogs objects and passes through to the Blogs object
	@param data The data used to build the object
 */
- (void)setBlogsDataFromArray: (NSArray *)data;
/**
 Sets the data used to build Albums objects and passes through to the Albums object
 @param data The data used to build the object
 */
- (void)setAlbumsDataFromArray: (NSArray *)data;
/**
 Sets the data used to build an NSArray of video objects
 @param data The data used to build the object
 */
- (void)setVideosDataFromArray:(NSArray *)data;

@property (nonatomic, strong) NSString *tripId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *urlSlug;
@property (nonatomic, strong) NSString *blogCoverImageURL;
@property (nonatomic, strong) UIImage *blogCoverImageFile;
@property (nonatomic, strong) NSString *albumCoverImageURL;
@property (nonatomic, strong) UIImage *albumCoverImageFile;
@property (nonatomic, strong) NSString *videoCoverImageURL;
@property (nonatomic, strong) UIImage *videoCoverImageFile;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, assign) int blogCount;
@property (nonatomic, assign) int albumCount;
@property (nonatomic, assign) int videoCount;
@property (nonatomic, strong) Blogs *blogs;
@property (nonatomic, strong) Albums *albums;
@property (nonatomic, strong) Videos *videos;

@end
