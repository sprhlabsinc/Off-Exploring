//
//  GANTracker.m
//  Off Exploring
//
//  Created by Denis Zakharov on 21/09/15.
//
//

#import "GANTracker.h"
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIFields.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>

@implementation GANTracker

+ (GANTracker *)sharedTracker {
    static GANTracker *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil) {
            [[GAI sharedInstance] trackerWithTrackingId:@"UA-765086-3"];
            sharedMyManager = [[self alloc] init];
        }
    }
    return sharedMyManager;
}

- (void)trackPageview:(NSString *)pageName withError:(NSError **)err {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:pageName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

@end
