//
//  constants.m
//  Off Exploring
//
//  Created by Off Exploring on 22/11/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "Constants.h"

NSString * const OFFEX_API_ADDRESS = @"http://api.offexploring.com/api/";
NSString * const HB_API_ADDRESS = @"http://api.offexploring.com/hbapi/";

// Off Exploring Config
NSString * const OFFEX_API_KEY = @"04c8dee11082219e7622c698bd9de2264b715ac895ae7";
NSString * const TARGET_PARTNER = @"offexploring";
NSString * const TARGET_PARTNER_ANALYTICS_KEY = @"UA-765086-3";
NSString * const TARGET_PARTNER_JANRAIN_APP_ID = @"fmkmienahanfdiakdoni";

NSString * const OFFEX_VIDEO_UPLOAD_ADDRESS = @"http://offexploring-videos.s3.amazonaws.com";
NSString * const OFFEX_AWS_ACCESS_KEY = @"1VBP5PZ1YGYBC5NFVCR2";
NSString * const OFFEX_AWS_SECRET_KEY = @"QRVLVuDZIxNGFv3HZtou5Drks3USf/30uByLIdJD";
NSString * const OFFEX_S3_BUCKET = @"offexploring-videos";
NSString * const OFFEX_S3_FOLDER = @"uploads";
NSString * const OFFEX_MAX_FILE_SIZE = @"524288000";
NSString * const OFFEX_VID_NOTIFY_URL = @"http://beta.offexploring.com/static/video.php";
NSString * const OFFEX_VID_UPLOAD_ROOT = @"http://offexploring-videos.s3.amazonaws.com/";
NSString * const OFFEX_VID_MAX_WIDTH = @"854";
NSString * const OFFEX_VID_MAX_HEIGHT = @"640";
NSString * const OFFEX_VID_MAX_DURATION = @"600";

UIStatusBarStyle const DEFAULT_UI_BAR_STYLE = UIStatusBarStyleDefault;

//Test API address
//NSString * const OFFEX_API_ADDRESS = @"http://192.168.19.102/";

@implementation UIColor (PartnerStyleExtensions)

+ (UIColor *)tableViewSeperatorColor {
    return [UIColor colorWithRed:41.0f/255.0f green:59.0f/255.0f blue:71.0f/255.0f alpha:1.0f];
}

+ (UIColor *)headerLabelTextColor {
    return [UIColor whiteColor];
}

+ (UIColor *)headerLabelShadowColor {
    return [UIColor darkGrayColor];
}

// CHECK THIS
+ (UIColor *)headerLabelTextColorPlainStyle {
    return [UIColor whiteColor];
}

// CHECK THIS 
+ (UIColor *)headerLabelShadowColorPlainStyle {
    return [UIColor darkGrayColor];
}

+ (UIColor *)navBarColor {
    return [UIColor colorWithRed:19.0f/255.0f green:51.0f/255.0f blue:65.0f/255.0f alpha:1.0f];
}

+ (UIColor *)settingsWebsiteButtonColor {
    return [UIColor colorWithRed:255.0f/255.0f green:192.0f/255.0f blue:56.0f/255.0f alpha:1.0f];
}

+ (UIColor *)settingsClearTemporaryLabelColor {
    return [UIColor colorWithRed:255.0f/255.0f green:192.0f/255.0f blue:56.0f/255.0f alpha:1.0f];
}

+ (UIColor *)navBarTextColor {
    return [UIColor colorWithRed:255.0f/255.0f green:192.0f/255.0f blue:56.0f/255.0f alpha:1.0f];
}

@end

@implementation NSString (PartnerStyleExtensions)

+ (NSString *)partnerName {
    return TARGET_PARTNER;
}

+ (NSString *)partnerDisplayName {
    return @"Off Exploring";
}

+ (NSString *)partnerWebsite {
    return @"www.offexploring.com";
}

+ (NSString *)backgroundImageNameByFileName: (NSString *)fileName
{
    if (IS_WIDESCREEN)
        return [NSString stringWithFormat:@"%@-568h.png", fileName];
    
    return [NSString stringWithFormat:@"%@.png", fileName];
}


+ (NSString *)backgroundHomeLogo {
    return [NSString backgroundImageNameByFileName:@"background_home_logo"];
}
+ (NSString *)backgroundHome {
    return [NSString backgroundImageNameByFileName:@"background_home"];
}
+ (NSString *)background {
    return [NSString backgroundImageNameByFileName:@"background"];
}
+ (NSString *)background2 {
    return [NSString backgroundImageNameByFileName:@"background2"];
}
+ (NSString *)backgroundLogo2 {
    return [NSString backgroundImageNameByFileName:@"background_logo2"];
}
+ (NSString *)datepicker2 {
    return [NSString backgroundImageNameByFileName:@"datepicker2"];
}
+ (NSString *)splash {
    return [NSString backgroundImageNameByFileName:@"splash"];
}

@end

@implementation UIImage (PartnerStyleExtensions)

+ (UIImage *)settingsActionButtonBackground {
    return [UIImage imageNamed:@"redButtonSmall.png"];
}

@end