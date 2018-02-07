//
//  SystemMessage.h
//  Off Exploring
//
//  Created by Off Exploring on 30/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
	@brief An object representing one Off Exploring System Message  
 
	This object represents one Off Exploring System Message, wrapping up key information about
	the message including its id, title, description and postdate. 
 */
@interface SystemMessage : NSObject {

	/**
		The id of the system message on Off Exploring, used to check for duplicates
	 */
	int dbid;
	/**
		The tile of the post
	 */
	NSString *title;
	/**
		The body text description of the post
	 */
	NSString *description;
	/**
		An associated web link for the item
	 */
	NSString *link;
	/**
		The date when the message was posted
	 */
	NSDate *timestamp;
		
}

/**
	Creates and returns a default value System Message object
	@returns A new default SystemMessage;
 */
- (id)init;

/**
	Creates and returns a SystemMessage object initialised with set values
	@param newID The id of the system message on Off Exploring
	@param newTitle The title of the post
	@param newDescription The description of the post
	@param newLink The web link associated for the post
	@param newTimestamp The timestamp for when the message was posted
	@returns A new SystemMessage
 */
- (id)initWithDBID:(int)newID title:(NSString *)newTitle description:(NSString *)newDescription link:(NSString *)newLink timestamp:(NSDate *)newTimestamp;

@property (nonatomic, assign, readonly) int dbid;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *description;
@property (nonatomic, strong, readonly) NSString *link;
@property (nonatomic, strong, readonly) NSDate *timestamp;

@end
