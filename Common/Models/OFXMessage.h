//
//  Message.h
//  Off Exploring
//
//  Created by Ian Outterside on 07/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTextMessage.h"
#import "Trip.h"

@interface OFXMessage : NSObject <MessageTextMessage>

@property (nonatomic, strong) NSNumber *messageId;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) NSString *guestname;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) Trip *trip;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
