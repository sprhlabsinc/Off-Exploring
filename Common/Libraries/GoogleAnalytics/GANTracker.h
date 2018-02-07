//
//  GANTracker.h
//  Off Exploring
//
//  Created by Denis Zakharov on 21/09/15.
//
//

#import <Foundation/Foundation.h>

@interface GANTracker : NSObject

+ (GANTracker *) sharedTracker;
- (void) trackPageview:(NSString *)pageName withError:(NSError **)err;

@end
