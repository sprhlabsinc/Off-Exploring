//
//  MessageTextMessage.h
//  Off Exploring
//
//  Created by Ian Outterside on 07/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MessageTextMessage <NSObject>

@required
- (NSNumber *)messageId;
- (NSString *)body;
- (NSTimeInterval)timestamp;
- (NSString *)guestname;
- (NSString *)email;

@end
