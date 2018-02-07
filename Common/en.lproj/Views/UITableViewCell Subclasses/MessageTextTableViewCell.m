//
//  MessageTextTableViewCell.m
//  Off Exploring
//
//  Created by Ian Outterside on 07/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import "MessageTextTableViewCell.h"

@implementation MessageTextTableViewCell

@synthesize dateLabel = _dateLabel;
@synthesize textLabel = __textLabel;
@synthesize detailTextLabel = __detailTextLabel;
@synthesize imageView = __imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_small.png"]];
        self.imageView = imageView;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        self.imageView.frame = CGRectMake(10, 15, 52, 41);
        [self.contentView addSubview:self.imageView];
        
        // Initialization code
        UILabel *postedLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 90, self.contentView.bounds.origin.y + 10, 80, 20)];
        postedLabel.font = [UIFont systemFontOfSize:12];
        postedLabel.textAlignment = NSTextAlignmentRight;
        postedLabel.textColor = [UIColor lightGrayColor];
        postedLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel = postedLabel;
        [self.contentView addSubview:postedLabel];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 52 + 20, 10, self.bounds.size.width - 52 - 60, 20)];
        label.backgroundColor = [UIColor clearColor];
        self.textLabel = label;
        [self.contentView addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 52 + 20, self.textLabel.frame.size.height + 10, self.bounds.size.width - 52 - 60, self.bounds.size.height - 30)];
        self.detailTextLabel = label;
        self.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label];

        self.textLabel.font = [UIFont boldSystemFontOfSize:14];
        self.textLabel.textColor = [UIColor darkGrayColor];
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.numberOfLines = 0;
    }
    return self;
}

- (void)setMessage:(id <MessageTextMessage>)message {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[message timestamp]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    
    self.dateLabel.text = [dateFormatter stringFromDate:date];
    self.textLabel.text = [message guestname];
    self.detailTextLabel.text = [message body];
    
}


@end
