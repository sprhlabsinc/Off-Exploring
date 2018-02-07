//
//  Blog.h
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief An object representing one Off Exploring Blog post 
 
 This object represents one Off Exploring Blog post, wrapping up key information about
 a blog and providing accessors to its images. The remote image methods appropriate wrap
 URLs for the images. Conforms to NSCoding for archival - for use with AutoSave feature.
 */
@interface Blog : NSObject <NSCoding>{

	/**
		The database id for the blog on Off Exploring.
	 */
	NSString *blogid;
	/**
		The full size image URI for the image on Off Exploring / Amazon S3.
	 */
	NSString *imageURI;
	/**
		The thumbnail image URI for the image on Off Exploring / Amazon S3.
	 */
	NSString *thumbURI;
	/**
		A local store of the full size image.
	 */
	UIImage *imageFile;
	/**
		A local store of the thumbnail image.
	 */
	UIImage *thumbFile;
	/**
		The body text of the blog post.
	 */
	NSString *body;
	/**
		A dictionary containing information about the trip this blog post belongs to.
		The trip dictionary should containt a URL slug, and a name
	 */
	NSDictionary *trip;
	/**
	 A dictionary containing information about the state this blog post belongs to.
	 The state dictionary should containt a URL slug, and a name
	 */
	NSDictionary *state;
	/**
	 A dictionary containing information about the area this blog post belongs to.
	 The area dictionary should containt a URL slug, and a name
	 */
	NSDictionary *area;
	/**
		A dictionary containing latitude and longditude information about the blog post.
	 */
	NSDictionary *geolocation;
	/**
		The timestamp for the day the blog post is referring to
	 */
	int timestamp;
	/**
		A timestamp used to identify the blog post, primarily for drafts. Generated on creation
		of the post in the app.
	 */
	int original_timestamp;
	/**
		A wrapper for the timestamp of the blog post.
	 */
	NSDate *datetime;
	/**
		The rating of the blog on Off Exploring - not used as of 23.09.2010
	 */
	int rating;
	/**
		The number of views a blog post has had on Off Exploring
	 */
	int views;
	/**
		A flag to indicate if this blog post is a draft
	 */
	BOOL draft;
	/**
		String version of the blog date for direct links
	 */
	NSString *entryDate;
	/**
		String blog title
	 */
	NSString *entryTitle;
}

#pragma mark Blog Creation Methods
/**
	Creates and returns a blog object, initialised from data
	@param data The data to create the blog object with
	@returns The initialised blog object
 */
- (id)initFromDictionary:(NSDictionary *)data;
/**
	Sets a blog objects properties from data
	@param data The data
 */
- (void)setFromDictionary:(NSDictionary *)data;

#pragma mark Image Accessors
/**
	Returns the local file path address of the blog image
	@returns The address
 */
- (NSString *)getImageFilePath;
/**
	Returns the local file path address of the blog image when the blog is being edited
	@returns The address
 */
- (NSString *)getTempImageFilePath;
/**
	Returns the local file path address of the blog thumbnail
	@returns The address
 */
- (NSString *)getThumbImageFilePath;
/**
	Returns the local file path address of the blog thumbnail when the blog is being edited
	@returns The address
 */
- (NSString *)getTempThumbImageFilePath;
/**
	Returns the full, formatted remote address of the blog image
	@returns The address
 */
- (NSString *)getThumbImageFullRemotePath;

#pragma mark Deletion Methods
/**
	Removes this blog from the file system
 */
- (void)deleteBlog;

@property (nonatomic, strong) NSString *blogid;
@property (nonatomic, strong) NSString *imageURI;
@property (nonatomic, strong) NSString *thumbURI;
@property (nonatomic, strong) UIImage *imageFile;
@property (nonatomic, strong) UIImage *thumbFile;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSDictionary *trip;
@property (nonatomic, strong) NSDictionary *state;
@property (nonatomic, strong) NSDictionary *area;
@property (nonatomic, strong) NSDictionary *geolocation;
@property (nonatomic, assign) int timestamp;
@property (nonatomic, assign) int original_timestamp;
@property (nonatomic, strong) NSDate *datetime;
@property (nonatomic, assign) int rating;
@property (nonatomic, assign) int views;
@property (nonatomic, assign) BOOL draft;
@property (nonatomic, strong) NSString *entryDate;
@property (nonatomic, strong) NSString *entryTitle;

@end
