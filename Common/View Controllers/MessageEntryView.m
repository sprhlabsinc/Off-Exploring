//
//  MessageEntryView.m
//  Off Exploring
//
//  Created by Denis Zakharov on 23/09/15.
//
//

#import "MessageEntryView.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define NAVBAR_TAG 99999

@interface MessageEntryView()
@property(nonatomic, assign, readonly) float keyboardHeight;
@end

@implementation MessageEntryView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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

- (void)setup {
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 6, self.bounds.size.width - 20, self.bounds.size.height - 12)];
    textView.text = @"Write a reply...";
    textView.backgroundColor = [UIColor clearColor];
    textView.delegate = self;
    textView.textColor = [UIColor lightGrayColor];
    textView.font = [UIFont systemFontOfSize:16.0f];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.contentInset = UIEdgeInsetsZero;
    textView.scrollsToTop = NO;
    [self addSubview:textView];
    self.textView = textView;
    
    self.showsSubmitButton = NO;
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [submitButton setTitle:@"Send" forState:UIControlStateNormal];
    submitButton.frame = CGRectMake(self.bounds.size.width - 60, self.bounds.size.height - 36, 54, 29);
    submitButton.hidden = YES;
    submitButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    [self addSubview:submitButton];
    self.submitButton = submitButton;
    
    [self addObserver:self forKeyPath:@"showsSubmitButton" options:NSKeyValueChangeNewKey || NSKeyValueChangeOldKey context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    [UIView beginAnimations:@"Width-Resize" context:NULL];
    [UIView setAnimationDuration:0.25];
    
    if (self.showsSubmitButton) {
        self.textView.frame = CGRectMake(10, 6, self.bounds.size.width - 80, self.bounds.size.height - 12);
        self.submitButton.hidden = NO;
    }
    else {
        self.textView.frame = CGRectMake(10, 6, self.bounds.size.width - 20, self.bounds.size.height - 12);
        self.submitButton.hidden = YES;
    }
    
    [UIView commitAnimations];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    CGFloat outsideOffset = 100.0f;
    size_t num_locations = 2;
    CGFloat radius = 5.0f;
    
    CGFloat colors[8] = {
        1.0, 1.0, 1.0, 0.85,
        1.0, 1.0, 1.0, 0.75
    };
    
    CGFloat locations[2] = {
        0.0, 1.0
    };
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw top line
    CGContextSaveGState(context);
    CGContextSetAllowsAntialiasing(context, NO);
    CGContextSetStrokeColorWithColor(context, [[UIColor darkGrayColor] CGColor]);
    CGContextStrokeRect(context, CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, 1));
    CGContextRestoreGState(context);
    
    // Draw TextArea wrapper
    CGRect shapeRect;
    if (self.showsSubmitButton) {
        shapeRect = CGRectMake(5, 5, self.bounds.size.width - 70, self.bounds.size.height - 10);
    }
    else {
        shapeRect = CGRectMake(5, 5, self.bounds.size.width - 10, self.bounds.size.height - 10);
    }
    
    // Rounded box
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddArc(path, NULL, CGRectGetMinX(shapeRect) + radius -outsideOffset, CGRectGetMinY(shapeRect) + radius -outsideOffset, radius, DEGREES_TO_RADIANS(270), DEGREES_TO_RADIANS(180), 1);
    CGPathAddArc(path, NULL, CGRectGetMinX(shapeRect) + radius -outsideOffset, CGRectGetMaxY(shapeRect) - radius +outsideOffset, radius, DEGREES_TO_RADIANS(180), DEGREES_TO_RADIANS(90), 1);
    CGPathAddArc(path, NULL, CGRectGetMaxX(shapeRect) - radius +outsideOffset, CGRectGetMaxY(shapeRect) - radius +outsideOffset, radius, DEGREES_TO_RADIANS(90), 0, 1);
    CGPathAddArc(path, NULL, CGRectGetMaxX(shapeRect) - radius +outsideOffset, CGRectGetMinY(shapeRect) + radius -outsideOffset, radius, 0, DEGREES_TO_RADIANS(270), 1);
    CGPathCloseSubpath(path);
    
    // Draw a big rectange
    
    CGMutablePathRef outerpath = CGPathCreateMutable();
    
    CGPathAddArc(outerpath, NULL, CGRectGetMaxX(shapeRect) - radius, CGRectGetMinY(shapeRect) + radius, radius, DEGREES_TO_RADIANS(270), 0, 0);
    CGPathAddArc(outerpath, NULL, CGRectGetMaxX(shapeRect) - radius, CGRectGetMaxY(shapeRect) - radius, radius, 0,DEGREES_TO_RADIANS(90), 0);
    CGPathAddArc(outerpath, NULL, CGRectGetMinX(shapeRect) + radius, CGRectGetMaxY(shapeRect) - radius, radius, DEGREES_TO_RADIANS(90), DEGREES_TO_RADIANS(180), 0);
    CGPathAddArc(outerpath, NULL, CGRectGetMinX(shapeRect) + radius, CGRectGetMinY(shapeRect) + radius, radius, DEGREES_TO_RADIANS(180), DEGREES_TO_RADIANS(270), 0);
    CGPathCloseSubpath(outerpath);
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    // Now create a larger rectangle, which we're going to subtract the visible path from
    // and apply a shadow
    
    // Add the visible path (so that it gets subtracted for the shadow)
    
    CGPathAddPath(outerpath, NULL, path);
    CGPathCloseSubpath(outerpath);
    
    // Add the visible paths as the clipping path to the context
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    // Now setup the shadow properties on the context
    CGContextSaveGState(context);
    CGContextSetAllowsAntialiasing(context, NO);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 2.5f, [[UIColor darkGrayColor] CGColor]);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    // Now fill the rectangle, so the shadow gets drawn
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextAddPath(context, outerpath);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, outerpath);
    CGContextClip(context);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, num_locations);
    CGContextDrawLinearGradient(context, gradient, CGPointMake((self.bounds.size.width / 2), self.bounds.origin.y + 1), CGPointMake((self.bounds.size.width / 2), self.bounds.size.height), 0);
    CGContextRestoreGState(context);
    
    // Release the paths and gradients
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    CGPathRelease(outerpath);
    CGPathRelease(path);
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageEntryViewWasTouched:)]) {
        [self.delegate messageEntryViewWasTouched:self];
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self resizeViewsForText];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    textView.contentInset = UIEdgeInsetsZero;
}

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _keyboardHeight = kbSize.height;
}
- (void)keyboardWillHide:(NSNotification*)notification {
    _keyboardHeight = 0.0f;
}

- (void)resizeViewsForText {
    if (self.showsSubmitButton == NO) {
        self.frame = CGRectMake(self.frame.origin.x, self.superview.bounds.size.height - 44, self.frame.size.width, 44);
        [self.textView scrollRangeToVisible:NSMakeRange([self.textView.text length], 0)];
        [self setNeedsDisplay];
    }
    else {
        CGSize textSize = [self.textView.text sizeWithFont:self.textView.font constrainedToSize:CGSizeMake(self.textView.bounds.size.width - 16, CGFLOAT_MAX)];
        
        CGFloat availableSpace;
        CGFloat minOffset;
        if ([self.superview viewWithTag:NAVBAR_TAG]) {
            availableSpace = self.superview.bounds.size.height - 44 - self.keyboardHeight - 44;
            minOffset = 88;
        }
        else {
            availableSpace = self.superview.bounds.size.height - 44 - self.keyboardHeight;
            minOffset = 44;
        }
        
        if (textSize.height <= 34) {
            if (self.previousTextSize.height != textSize.height || self.previousTextSize.height == 0) {
                self.frame = CGRectMake(self.frame.origin.x, self.superview.bounds.size.height - self.keyboardHeight - 44, self.frame.size.width, 44);
                [self setNeedsDisplay];
            }
        }
        else if (textSize.height > 34 && textSize.height <= availableSpace) {
            if (self.previousTextSize.height != textSize.height) {
                self.frame = CGRectMake(self.frame.origin.x, (self.superview.bounds.size.height - self.keyboardHeight - 44 - (textSize.height - 34)), self.frame.size.width, 44 + (textSize.height - 34));
                [self setNeedsDisplay];
            }
        }
        else {
            if (self.previousTextSize.height != textSize.height && self.previousTextSize.height <= availableSpace) {
                self.frame = CGRectMake(self.frame.origin.x, minOffset, self.frame.size.width, availableSpace);
                [self setNeedsDisplay];
            }
        }
        
        self.previousTextSize = textSize;
    }
    
    self.textView.contentInset = UIEdgeInsetsZero;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"showsSubmitButton"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageEntryViewWasTouched:)]) {
        [self.delegate messageEntryViewWasTouched:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}


@end