//
//  Blogs.h
//  Off Exploring
//
//  Created by Off Exploring on 31/03/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Blog.h"

@class Trip;

/**
 @brief A collection object containing an array of blogs, grouped by state, area. 
 
 This is a collection providing adding, deletion and reloading of an ordered array of Blogs.
 Using addBlog: and deleteBlog: keeps the array indexed and ordered correctly. It also handles
 duplicates appropriately.
 */
@interface Blogs : NSObject {
	
	/**
		An array of blogs, subdivided by area, then state.
	 */
	NSMutableArray *states;
	/**
		Key trip information to pass to blogs
	 */
	NSDictionary *parentTrip;
	/**
		A pointer to the trip this blogs object belongs to.
	 */
	Trip *__weak theTrip;
}

#pragma mark Blogs Collection Management
/**
	Adds blog objects from a data array
	@param data The array of data
 */
- (void)setFromArray:(NSArray *)data;

/**
	Adds one blog to the array of blogs in the correct position
	@param blog The Blog to be added
 */
- (void)addBlog:(Blog *)blog;

/**
	Deletes one blog from the array of blogs, maintaining indexes
	@param blog The Blog to be removed
 */
- (void)deleteBlog:(Blog *)blog;

/**
	Reloads the array of draft blogs stored in the file system, and 
	adds them to the blogs array appropriatly maintaining indexes
 */
- (void)reloadTemp;

#pragma mark Custom Accessors 
/**
	Returns an individual blog based upon its subdevidors (timestamp, area and state)
	@param original_time The timestamp of the blog
	@param theState The state the blog was recorded for
	@param theArea The area the blog was recorded for
	@returns The blog matching specified parameters
 */
- (Blog *)getBlogUsingTimestamp:(int)original_time andState:(NSDictionary *)theState andArea:(NSDictionary *)theArea;

@property (nonatomic, strong) NSMutableArray *states;
@property (nonatomic, strong) NSDictionary *parentTrip;
@property (nonatomic, weak) Trip *theTrip;

@end
