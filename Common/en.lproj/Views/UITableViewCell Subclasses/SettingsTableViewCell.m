//
//  SettingsTableViewCell.m
//  Off Exploring
//
//  Created by Ian Outterside on 15/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import "SettingsTableViewCell.h"
#import "GroupedStyleView.h"
#import "Constants.h"

@implementation SettingsTableViewCell

@synthesize titleLabel = __titleLabel;
@synthesize textLabel = __textLabel;
@synthesize detailTextLabel = __detailTextLabel;
@synthesize actionButton = __actionButton;
@synthesize textLabelBackgroundView = __textLabelBackgroundView;

- (id)initWithSettingStyle:(SettingsTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.bounds.origin.x + 12.0f, self.contentView.bounds.origin.y, 300.0, 50.0)];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textAlignment = NSTextAlignmentLeft;
        headerLabel.textColor = [UIColor headerLabelTextColor];
        headerLabel.font = [ UIFont boldSystemFontOfSize: 14];
        headerLabel.shadowColor = [UIColor headerLabelShadowColor];
        headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        self.titleLabel = headerLabel;
        [self.contentView addSubview:headerLabel];
        
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        self.actionButton = actionButton;
        [self.contentView addSubview:actionButton];
        
        GroupedStyleView *view = [[GroupedStyleView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        self.textLabelBackgroundView = view;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(view.bounds.origin.x + 10, view.bounds.origin.y + 10, view.bounds.size.width - 20, view.bounds.size.height - 20)];
        label.textColor = [UIColor colorWithRed:64.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0f];
        label.font = [UIFont systemFontOfSize:17.0];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.textLabel = label;
        [view addSubview:label];
        [self.contentView addSubview:view];
        
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        detailLabel.numberOfLines = 0;
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.textAlignment = NSTextAlignmentLeft;
        detailLabel.textColor = [UIColor headerLabelTextColor];
        detailLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        detailLabel.shadowColor = [UIColor headerLabelShadowColor];
        detailLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [self.contentView addSubview:detailLabel];
        self.detailTextLabel = detailLabel;

        
        [self switchSettingStyle:style];
    }
    return self;
}

- (void)switchSettingStyle:(SettingsTableViewCellStyle)newStyle {
    
    // Reset Properties
    self.textLabel.text = @"";
    self.textLabel.hidden = YES;
    self.actionButton.hidden = YES;
    self.detailTextLabel.text = @"";
    self.detailTextLabel.hidden = YES;
    self.textLabelBackgroundView.hidden = YES;
    [self.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents]; 
    
    CGRect groupedViewRect;
    switch (newStyle) {
        case SettingsTableViewCellStyleThin:
            groupedViewRect = CGRectMake(self.contentView.bounds.origin.x + 10.0f, self.contentView.bounds.origin.y + self.titleLabel.frame.size.height, 200.0f, 47.0f);
            [self.actionButton setBackgroundImage:[UIImage settingsActionButtonBackground] forState:UIControlStateNormal];
            [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.actionButton.frame = CGRectMake(groupedViewRect.origin.x + groupedViewRect.size.width + 7, self.contentView.bounds.origin.y + self.titleLabel.frame.size.height, 95, 47);
            self.actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            self.actionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            self.textLabel.hidden = NO;
            self.actionButton.hidden = NO;
            self.textLabelBackgroundView.hidden = NO;
            self.textLabelBackgroundView.frame = groupedViewRect;
            break;
        case SettingsTableViewCellStyleWide:
            groupedViewRect = CGRectMake(self.contentView.bounds.origin.x + 10.0f, self.contentView.bounds.origin.y + self.titleLabel.frame.size.height, self.contentView.bounds.size.width - 20.0f, 47.0f);
            self.textLabel.hidden = NO;
            self.textLabelBackgroundView.hidden = NO;
            self.textLabelBackgroundView.frame = groupedViewRect;
            break;
        case SettingsTableViewCellStyleDefault:
        default:
            self.textLabel.hidden = NO;
            self.detailTextLabel.hidden = NO;
            break;
    }
    
    self.textLabel.frame = CGRectMake(self.textLabelBackgroundView.bounds.origin.x + 10, self.textLabelBackgroundView.bounds.origin.y + 10, self.textLabelBackgroundView.bounds.size.width - 20, self.textLabelBackgroundView.bounds.size.height - 20);
}


@end
