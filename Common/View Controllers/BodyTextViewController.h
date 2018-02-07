//
//  BodyTextViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 29/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BodyTextViewController;

#pragma mark -
#pragma mark BodyTextViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive large amounts of edited text
 
	This protocol allows delegates to be given text strings for text they have edited using the BodyTextViewController
	class. The protocol allows the editor to be customised by having its title changed and what to do when it opens 
	up a new editor.
 */
@protocol BodyTextViewControllerDelegate <NSObject>
#pragma mark Required Delegate Methods
@required

/**
	Delegate is signalled by this when the user finishes editing body text
	@param btvc The BodyTextViewController object used to edit the text
	@param bodyText The edited text
 */
- (void)bodyTextViewController:(BodyTextViewController *)btvc didFinishEditingBody:(NSString *)bodyText;
/**
	Delegate is signalled by this when the user cancels editing
	@param btvc The BodyTextViewController object used to edit the text
 */
- (void)bodyTextViewControllerDidCancel:(BodyTextViewController *)btvc;

#pragma mark Optional Delegate Methods
@optional 

/**
	Delegate is asked for the title to display on the page for editing
	@param btvc The BodyTextViewController object used to edit the text
	@returns The string title
 */
- (NSString *)titleForBodyTextViewController:(BodyTextViewController *)btvc;
/**
	Delegate is asked wether it should clear the text view when the user begins editing
	@param btvc The BodyTextViewController object used to edit the text
	@returns Wether to clear or not
 */
- (BOOL)bodyTextViewControllerShouldClearOnEdit:(BodyTextViewController *)btvc;

/**
 Delegate is asked wether it should display a warning when the cancel button is hit. Default is not to.
 @param btvc The BodyTextViewController object used to edit the text
 @returns Wether to display warning or not
 */
- (BOOL)bodyTextViewControllerShouldDisplayCancelWarning:(BodyTextViewController *)btvc;

@end

#pragma mark -
#pragma mark BodyTextViewController Declaration
/**
	@brief Provides functionality to edit a piece of body text.
 
	This class provides functionality to display and edit a single piece of text. It can be customised
	by its delegate by having its title set and wether it clears its textarea on editing. It sets itself as
	a UITextViewDelegate to provide this functionality. Class captures text content during app close for use as part of Auto Save
 */
@interface BodyTextViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate>{

	/**
		The delegate that receives messages in regards to updates to the text
	 */
	id <BodyTextViewControllerDelegate> __weak delegate;
	/**
		The text being edited
	 */
	NSString *body;
	/**
		The textview wrapping around the text
	 */
	UITextView *textView;
	/**
		A pointer to the navigation bar to allow for changes to the title
	 */
	UINavigationBar *navBar;
}

#pragma mark IBActions
/**
	Method signalling users wish to cancel editing
 */
- (IBAction)cancel;

/**
	Method signalling users wish to commit editing
 */
- (IBAction)save;

@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, weak) id <BodyTextViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;

@end
