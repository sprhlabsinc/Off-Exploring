//
//  BlogDetailTableViewCell.m
//  Off Exploring
//
//  Created by Off Exploring on 16/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "BlogDetailTableViewCell.h"


@implementation BlogDetailTableViewCell

@synthesize detail;
@synthesize label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
