//
//  HostelTableViewCell.m
//  Off Exploring
//
//  Created by Off Exploring on 19/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelTableViewCell.h"
#import "Hostel.h"
#import "HostelView.h"

@implementation HostelTableViewCell
@synthesize hostelView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		CGRect hostelViewFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		hostelView = [[HostelView alloc] initWithFrame:hostelViewFrame];
		hostelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:hostelView];
	}
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHostel:(Hostel *)newHostel {
	hostelView.hostel = newHostel;
}

- (void)setHostelImage:(UIImage *)newHostelImage {
	hostelView.image = newHostelImage;
}

- (void)redisplay {
	[hostelView setNeedsDisplay];
}



@end
