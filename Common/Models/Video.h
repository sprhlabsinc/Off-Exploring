//
//  Video.h
//  Off Exploring
//
//  Created by Ian Outterside on 06/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Video : NSObject {
    
    /**
     The database id for the album on Off Exploring.
     */
    NSString *videoID;
    
    /**
     The remote cover image URI
     */
    NSString *imageURI;
    
    /**
     The title of the video
     */
    NSString *title;
    
    /**
     The description of the video
     */
    NSString *video_description;
    
    /**
     The name of the state this video was posted about
     */
    NSString *state;
    
    /**
     The name of the area this video was posted about
     */
    NSString *area;
    
    /**
     A dictionary containing the latitude and longitude of the blog post
     */
    NSDictionary *geolocation;
    
    /**
     Dictionary containing the name and the slug of the trip this video belongs to
     */
    NSDictionary *trip;
    
    BOOL processing;
    
    NSString *videoPath;
    
    NSString *localVideoPath;
    
    BOOL failedUpload;
}

#pragma mark Initialisation
/**
 Creates and returns an video object initialised from data
 @param data The data to setup the object
 @returns The Video object
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

- (NSURL *)videoRemotePath;

@property (nonatomic, strong) NSString *imageURI;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *video_description;
@property (nonatomic, strong) NSDictionary *trip;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *area;
@property (nonatomic, strong) NSDictionary *geolocation;
@property (nonatomic, strong) NSString *videoID;
@property (nonatomic, assign) BOOL processing;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) NSString *localVideoPath;
@property (nonatomic, assign) BOOL failedUpload;


@end
