//
//  MessageEntryView.h
//  Off Exploring
//
//  Created by Denis Zakharov on 23/09/15.
//
//

#import <Foundation/Foundation.h>

@class MessageEntryView;
@protocol MessageEntryViewDelegate <NSObject>

- (void)messageEntryViewWasTouched:(MessageEntryView *)messageEntryView;

@end

@interface MessageEntryView : UIView <UITextViewDelegate>

@property (nonatomic, weak) id <MessageEntryViewDelegate> delegate;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) CGSize previousTextSize;
@property (nonatomic, assign) BOOL showsSubmitButton;
@property (nonatomic, strong) UIButton *submitButton;

- (void)setup;
- (void)resizeViewsForText;

@end
