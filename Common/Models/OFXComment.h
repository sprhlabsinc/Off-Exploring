//
//  Comment.h
//  Off Exploring
//
//  Created by Ian Outterside on 07/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTextMessage.h"

@interface OFXComment : NSObject <MessageTextMessage>

@property (nonatomic, strong) NSNumber *messageId;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) NSString *guestname;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, weak) NSObject *modelObject;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
