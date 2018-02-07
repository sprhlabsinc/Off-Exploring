//
//  GroupedStyleView.m
//  Off Exploring
//
//  Created by Ian Outterside on 15/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import "GroupedStyleView.h"
#import <QuartzCore/QuartzCore.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define GROUPED_CORNER_RADIUS 10.0f

#pragma mark Grouped Style Cells

@interface GroupedStyleView()
- (CGMutablePathRef)newPathForRect:(CGRect)boundsRect radius:(CGFloat)radius;
- (void)setup;
@end

@implementation GroupedStyleView

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = GROUPED_CORNER_RADIUS;
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect boundsRect = [self bounds];
    CGFloat radius = GROUPED_CORNER_RADIUS;
    
    CGMutablePathRef path = [self newPathForRect:boundsRect radius:radius];
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    CGPathRelease(path);
}

- (CGMutablePathRef)newPathForRect:(CGRect)boundsRect radius:(CGFloat)radius {
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddArc(path, NULL, CGRectGetMinX(boundsRect) + radius, CGRectGetMinY(boundsRect) + radius, radius, DEGREES_TO_RADIANS(270), DEGREES_TO_RADIANS(180), 1);
    CGPathAddArc(path, NULL, CGRectGetMinX(boundsRect) + radius, CGRectGetMaxY(boundsRect) - radius, radius, DEGREES_TO_RADIANS(180),DEGREES_TO_RADIANS(90), 1);
    CGPathAddArc(path, NULL, CGRectGetMaxX(boundsRect) - radius, CGRectGetMaxY(boundsRect) - radius, radius, DEGREES_TO_RADIANS(90), 0, 1);
    
    CGPathAddArc(path, NULL, CGRectGetMaxX(boundsRect) - radius, CGRectGetMinY(boundsRect) + radius, radius, 0, DEGREES_TO_RADIANS(270), 1);
    CGPathCloseSubpath(path);
    
    return path;
}

@end