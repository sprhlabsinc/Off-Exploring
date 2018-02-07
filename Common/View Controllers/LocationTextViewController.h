//
//  LocationTextViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 30/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocationTextViewController;

#pragma mark -
#pragma mark LocationTextViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive a entered location name
 
	This protocol allows delegates to be messaged when the user has finished entering a "area" from free text.
	It returns the string name entered. The delegate is also messaged if the user cancels area entry.
	The delegate may also optionally set the label of the dialogue via a delegate method.
 */
@protocol LocationTextViewControllerDelegate <NSObject>

@required
#pragma mark Required Delegate Methods
/**
	Delegate method messaged when the user has finished inputing a location name
	@param ltvc The LocationTextViewController used to enter the location name
	@param title The title for the page
	@param location The location name that was entered
 */
- (void)locationTextViewController:(LocationTextViewController *)ltvc withTitle:(NSString *)title didFinishEditingLocation:(NSDictionary *)location;
/**
	Delegate method messaged when the user cancels editing the location name
	@param ltvc The LocationTextViewController to dismiss
 */
- (void)locationTextViewControllerDidCancel:(LocationTextViewController *)ltvc;

@optional 
#pragma mark Optional Delegate Methods
/**
	The label to set next to the text entry, used to customise the view
	@param ltvc The LocationTextViewController used to edit the text
	@returns The label text to set
 */
- (NSString *)labelForLocationTextViewController:(LocationTextViewController *)ltvc;

@end

#pragma mark -
#pragma mark LocationTextViewController Interface

/**
	@brief A UIViewController Subclass that allows users to enter a free piece of text, primarily a location name
 
	This class provides an interface to enter a free piece of text to be returned to a delegate, usually a location,
	but this can be over-ridden by the the delegate. The class uses a UITextField to enter the text, and so sets itself
	as a UITextField Delegate to handle various delegate methods for presing return
 */
@interface LocationTextViewController : UIViewController <UITextFieldDelegate> {

	/**
		The delegate to be messaged with the text
	 */
	id <LocationTextViewControllerDelegate> __weak delegate;
	/**
		The textfield to enter the text
	 */
	UITextField *locationName;
	/**
		Can be optionally pre-populated to edit location names
	 */
	NSDictionary *area;
	/**
		The label to display next to the free text
	 */
	UILabel *textLabel;
	/**
		A pointer to the title of the page for customisation
	 */
	UINavigationBar *navBar;
}

#pragma mark IBActions
/**
	Action signalling the user wishes to cancel editing
 */
- (IBAction)cancel;
/**
	Action signalling the user wishes to commit editing
 */
- (IBAction)save;

@property (nonatomic, strong) IBOutlet UITextField *locationName;
@property (nonatomic, strong) NSDictionary *area;
@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) id <LocationTextViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;


@end
