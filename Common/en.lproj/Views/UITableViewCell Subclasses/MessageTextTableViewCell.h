//
//  MessageTextTableViewCell.h
//  Off Exploring
//
//  Created by Ian Outterside on 07/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTextMessage.h"

@interface MessageTextTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailTextLabel;
@property (nonatomic, strong) UIImageView *imageView;

- (void)setMessage:(id <MessageTextMessage>)message;

@end
