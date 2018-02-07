//
//  SettingsTableViewCell.h
//  Off Exploring
//
//  Created by Ian Outterside on 15/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SettingsTableViewCellStyleDefault = 0,
    SettingsTableViewCellStyleWide = 1,
    SettingsTableViewCellStyleThin = 2
} SettingsTableViewCellStyle;

@interface SettingsTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailTextLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIView *textLabelBackgroundView;

- (id)initWithSettingStyle:(SettingsTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)switchSettingStyle:(SettingsTableViewCellStyle)newStyle;

@end
