//
//  CustomDatePicker.m
//  Off Exploring
//
//  Created by Denis Zakharov on 20/09/15.
//
//

#import "CustomDatePicker.h"

@interface CustomDatePicker()
@property (nonatomic, assign) BOOL changed;
@end

@implementation CustomDatePicker

- (void)addSubview:(UIView *)view {
    if (!self.changed) {
        self.changed = YES;
        [self setValue:[UIColor whiteColor] forKey:@"textColor"];
    }
    [super addSubview:view];
}

@end
