//
//  Constants.h
//  Off Exploring
//
//  Created by Off Exploring on 22/11/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 Static Constants used to specify remote addresses and API keys
 */
extern NSString * const OFFEX_API_ADDRESS;
extern NSString * const OFFEX_API_KEY;
extern NSString * const HB_API_ADDRESS;
extern NSString * const TARGET_PARTNER;
extern NSString * const TARGET_PARTNER_ANALYTICS_KEY;
extern NSString * const TARGET_PARTNER_JANRAIN_APP_ID;

extern NSString * const OFFEX_VIDEO_UPLOAD_ADDRESS;
extern NSString * const OFFEX_AWS_ACCESS_KEY;
extern NSString * const OFFEX_AWS_SECRET_KEY;
extern NSString * const OFFEX_S3_BUCKET;
extern NSString * const OFFEX_S3_FOLDER;
extern NSString * const OFFEX_MAX_FILE_SIZE;
extern NSString * const OFFEX_VID_NOTIFY_URL;
extern NSString * const OFFEX_VID_UPLOAD_ROOT;
extern NSString * const OFFEX_VID_MAX_WIDTH;
extern NSString * const OFFEX_VID_MAX_HEIGHT;
extern NSString * const OFFEX_VID_MAX_DURATION;

extern UIStatusBarStyle const DEFAULT_UI_BAR_STYLE;

/**
 UIColor constants
*/
@interface UIColor (PartnerStyleExtensions)

+ (UIColor *)tableViewSeperatorColor;
+ (UIColor *)headerLabelTextColor;
+ (UIColor *)headerLabelShadowColor;
+ (UIColor *)headerLabelTextColorPlainStyle;
+ (UIColor *)headerLabelShadowColorPlainStyle;
+ (UIColor *)navBarColor;
+ (UIColor *)settingsWebsiteButtonColor;
+ (UIColor *)settingsClearTemporaryLabelColor;
+ (UIColor *)navBarTextColor;

@end

@interface NSString (PartnerStyleExtensions)

+ (NSString *)partnerName;
+ (NSString *)partnerDisplayName;
+ (NSString *)partnerWebsite;
+ (NSString *)backgroundImageNameByFileName:(NSString *)fileName;
+ (NSString *)backgroundHomeLogo;
+ (NSString *)backgroundHome;
+ (NSString *)background;
+ (NSString *)background2;
+ (NSString *)backgroundLogo2;
+ (NSString *)datepicker2;
+ (NSString *)splash;

@end

@interface UIImage (PartnerStyleExtensions)

+ (UIImage *)settingsActionButtonBackground;

@end