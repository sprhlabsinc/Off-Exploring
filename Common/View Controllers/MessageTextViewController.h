//
//  MessageTextViewController.h
//  Off Exploring
//
//  Created by Ian Outterside on 07/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
#import "TouchableTableView.h"
#import "MessageTextMessage.h"

@class MessageTextViewController;

@protocol MessageTextViewControllerDelegate <NSObject>

@optional

- (void)sendMessage:(NSString *)message;
- (void)deleteMessage:(id <MessageTextMessage>)aMessage;
- (void)messageTextViewControllerDidFinish:(MessageTextViewController *)messageTextViewController;

@end

@interface MessageTextViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TouchableTableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *messages;
@property (weak, nonatomic) id <MessageTextViewControllerDelegate> delegate;

- (void)loadMessagesForTrip:(Trip *)trip;
- (void)hideHUDMessage;
- (void)resetView;

@end
