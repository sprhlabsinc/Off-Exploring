//
//  OFXNavigationBar.m
//  Off Exploring
//
//  Created by Ian Outterside on 20/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import "OFXNavigationBar.h"
#import "Constants.h"

@interface OFXNavigationBar(Private)

- (void)forceTintColor;

@end

@interface OFXNavigationBar()
@property (nonatomic, assign) BOOL hiddenLogo;

- (void)setup;
@end

@implementation OFXNavigationBar

@synthesize hiddenLogo = _hiddenLogo;

- (id)init {
    if (self = [super init]) {
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

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    self.hiddenLogo = YES;
    [self forceTintColor];
}

- (void)forceTintColor {
    [self setTintColor:[UIColor navBarColor]];
}

- (void)setLogoHidden:(BOOL)hidden {
    _hiddenLogo = hidden;
    [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect {
    NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:@"navBarBackground" ofType:@"png"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName]) {
        
        UIImage *image = [UIImage imageNamed:@"navBarBackground.png"];
        [image drawInRect:self.bounds];
        
    }
    else {
        [super drawRect:rect];
    }
    
    if (!_hiddenLogo) {
        UIImage *image = [UIImage imageNamed:@"navBarLogo.png"];
        CGRect imageRect = CGRectMake(((rect.size.width / 2) - (image.size.width / 2)), 4, image.size.width, image.size.height);
    
        [image drawInRect:imageRect]; 
    }
}


@end
