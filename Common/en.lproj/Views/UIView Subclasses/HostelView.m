//
//  HostelView.m
//  Off Exploring
//
//  Created by Off Exploring on 19/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelView.h"
#import "Hostel.h"
#import "User.h"

@implementation HostelView

@synthesize hostel;
@synthesize imageWrapper;
@synthesize image;
@synthesize highlighted;
@synthesize editing;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
		self.opaque = YES;
		self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setHostel:(Hostel *)newHostel {
	if (hostel != newHostel) {
		hostel = newHostel;
		
	}
	[self setNeedsDisplay];
}

- (void)setImage:(UIImage *)newImage {
	if (image != newImage) {
		image = newImage;
		
	}
	[self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)lit {
	// If highlighted state changes, need to redisplay.
	if (highlighted != lit) {
		highlighted = lit;	
		[self setNeedsDisplay];
	}
}

/**
	View drawing code
	@param rect The rect space to draw within
 */
- (void)drawRect:(CGRect)rect {
    // Drawing code
	
#define LEFT_COLUMN_OFFSET 0
#define LEFT_COLUMN_WIDTH 55
	
#define RIGHT_COLUMN_OFFSET 75
#define RIGHT_COLUMN_WIDTH 200
	
#define UPPER_ROW_TOP 0
#define NAME_ROW_TOP 5
#define DESCRIPTION_ROW_TOP 25
	
#define MAIN_FONT_SIZE 14
#define MIN_MAIN_FONT_SIZE 10
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10
	
	UIColor *mainTextColor = nil;
	UIFont *mainFont = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
	
	// Color and font for the secondary text items (GMT offset, day)
	UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
	
	// Choose font color based on highlighted state.
	if (self.highlighted) {
		mainTextColor = [UIColor whiteColor];
	}
	else {
		mainTextColor = [UIColor darkGrayColor];
		self.backgroundColor = [UIColor whiteColor];
	}
	
	CGRect contentRect = self.bounds;
	
	CGFloat boundsX = contentRect.origin.x;
	CGPoint point;
	
	// Set the color for the main text items.
	[mainTextColor set];
	
	// DRAW IMAGE
	point = CGPointMake(boundsX + LEFT_COLUMN_OFFSET, UPPER_ROW_TOP);
	
	if (image == nil) {
		image = [UIImage imageNamed:@"placeholder.png"];
	}
	imageWrapper = [[UIImageView alloc] initWithFrame:CGRectMake(point.x, point.y, 65, 60)];
	imageWrapper.contentMode = UIViewContentModeScaleToFill;
	imageWrapper.image = image;
	
	[imageWrapper drawRect:rect];
	
	// DRAW NAME
	point = CGPointMake(boundsX + RIGHT_COLUMN_OFFSET, NAME_ROW_TOP);
	[hostel.name drawAtPoint:point forWidth:RIGHT_COLUMN_WIDTH withFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:NULL lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];

	// DRAW RATING
	if (hostel.overall != 0) {
		UIFont *ratingFont = [UIFont systemFontOfSize:14];
		CGSize theSize = [hostel.name sizeWithFont:mainFont forWidth:RIGHT_COLUMN_WIDTH lineBreakMode:NSLineBreakByTruncatingTail];
		point = CGPointMake((point.x + theSize.width + 5), point.y);
		[[NSString stringWithFormat:@"(%.0f%%)",hostel.overall] drawAtPoint:point forWidth:50.0 withFont:ratingFont minFontSize:MIN_SECONDARY_FONT_SIZE actualFontSize:NULL lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	}
	
	// DRAW PRICE
	point = CGPointMake(boundsX + RIGHT_COLUMN_OFFSET, DESCRIPTION_ROW_TOP);
	
	User *user = [User sharedUser];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *lastHostelLookup = [prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelLookup_%@",user.username]];
	
	NSString *currencySymbol = lastHostelLookup[@"currency"][@"symbol"];
	NSString *pricesFrom = nil;
	if (hostel.privateprice > 0 && hostel.sharedprice > 0) {
		pricesFrom = [NSString stringWithFormat:@"Private from %@%.2f",currencySymbol, hostel.privateprice];
		[pricesFrom drawAtPoint:point forWidth:RIGHT_COLUMN_WIDTH withFont:secondaryFont minFontSize:MIN_SECONDARY_FONT_SIZE actualFontSize:NULL lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
		point = CGPointMake(boundsX + RIGHT_COLUMN_OFFSET, DESCRIPTION_ROW_TOP + 15);		
		pricesFrom = [NSString stringWithFormat:@"Shared from %@%.2f",currencySymbol, hostel.sharedprice];
		[pricesFrom drawAtPoint:point forWidth:RIGHT_COLUMN_WIDTH withFont:secondaryFont minFontSize:MIN_SECONDARY_FONT_SIZE actualFontSize:NULL lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	}
	else {
		if (hostel.privateprice > 0) {
			pricesFrom = [NSString stringWithFormat:@"Private from %@%.2f",currencySymbol, hostel.privateprice];
		}
		else {
			pricesFrom = [NSString stringWithFormat:@"Shared from %@%.2f",currencySymbol, hostel.sharedprice];
		}
		[pricesFrom drawAtPoint:point forWidth:RIGHT_COLUMN_WIDTH withFont:secondaryFont minFontSize:MIN_SECONDARY_FONT_SIZE actualFontSize:NULL lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	}
}

@end
