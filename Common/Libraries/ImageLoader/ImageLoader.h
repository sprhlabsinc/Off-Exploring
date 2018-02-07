//
//  ImageLoader.h
//  Off Exploring
//
//  Created by Off Exploring on 12/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageLoader;

/** 
	Static constants used to specify remote image addresses
 */

extern NSString * const OFFEX_IMAGE_ADDRESS;
extern NSString * const S3_IMAGE_ADDRESS;

#pragma mark -
#pragma mark ImageLoaderDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive images loaded from the internet.
 
	This protocol allows delegates to be given an image downloaded from a given URI
 */
@protocol ImageLoaderDelegate <NSObject>

@required

#pragma mark Required Delegate Methods
/**
	Returns the Image at the requested URI
	@param loader The ImageLoader object used to load the image
	@param image The Image returned
	@param uri The request URI
 */
- (void)imageLoader:(ImageLoader *)loader didLoadImage:(UIImage *)image forURI:(NSString *)uri;

@end

#pragma mark -
#pragma mark ImageLoader Declaration
/**
	@brief Provides functionality to load Images from a remote address, either at Off Exploring, Amazon S3 or elsewhere
 
	This class handles all communication between the iPhone app and remote images on the internet. If the address provided
	is an Off Exploring one, the loader will first make a request to Amazon S3 to download the image. If the request fails
	to return an image from S3, it will make the same request to Off Exploring. If this still fails, a placeholder image
	is returned.  If the request is remote (set by using the foreign flag) the request is made directly, and returns either
	the image or a placeholder image on failure.
 */
@interface ImageLoader : NSObject {
	
	/**
		An ImageLoaderDelegate object to be passed the downloaded image
	 */
	id <ImageLoaderDelegate> __weak delegate;
    /**
    	The remote URI being requested
     */
    NSString *requestURI;
	/**
		A flag to state wether the URI is foreign or belongs to Off Exploring or Amazon S3
	 */
	BOOL foreign;
	
@private
	/**
		A mutable data store to keep the image data
	 */
	NSMutableData *activeDownload;
    /**
    	An asynchronus connection request
     */
    NSURLConnection *imageConnection;
	/**
		The original URI passed to the object
	 */
	NSString *originalURI;
	/**
		A flag to state where data is loaded from (Amazon S3 or Off Exploring)
	 */
	BOOL offexLoad;
}

#pragma mark Connection Methods
/**
	Convienience method to make image requests in one line
	@param url The URI of the image being requested
	@param remote Wether the URI is remote or is an Off Exploring / Amazon S3 URI
	@param theDelegate The delegate to return the image to
	@returns The ImageLoader Object
 */
- (id)initWithURL:(NSString *)url isForeign:(BOOL)remote delegate:(id<ImageLoaderDelegate>)theDelegate;
/**
	Makes a request for an image to the specified URI
	@param uri The uri from which to request the image
 */
- (void)startDownloadForURL:(NSString *)uri;

#pragma mark Cancellation Method
/**
	Cancel the remote download request and remove it from the queue.
 */
- (void)cancelDownload;

@property (nonatomic, weak) id <ImageLoaderDelegate> delegate;
@property (nonatomic, strong) NSString *requestURI;
@property (nonatomic, assign) BOOL foreign;

@end