//
//  DateViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 28/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DateViewController;

#pragma mark -
#pragma mark DateViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive a selected date.
 
	This protocol allows delegates to be given dates selected by a user when they are using a
	DaveViewController.
 */
@protocol DateViewControllerDelegate <NSObject>
#pragma mark Required Delegate Methods
@required

/**
	Delegate method signalled when a user confirms the choice of a date
	@param dvc The DateViewController object used to select the date
	@param date The date that was selected
 */
- (void)dateViewController:(DateViewController *)dvc didSaveWithDate:(NSDate *)date;
/**
	Delegate method signalled when a user wishes to cancel selecting a date.
	@param dvc The DateViewController object used to select a date 
 */
- (void)dateViewControllerDidCancel:(DateViewController *)dvc;

@end

#pragma mark -
#pragma mark DateViewController Declaration
/**
	@brief Provides functionality to select any date.
 
	This class provides functionality to select and message a delegate with a perticular selected date.
	Class captures date content during app close for use as part of Auto Save
 */
@interface DateViewController : UIViewController {

	/**
		The delegate that receives messages in regards to selection of a date
	 */
	id <DateViewControllerDelegate> __weak delegate;
	/**
		A label displaying the currently selected date to the user
	 */
	UILabel *dateLabel;
	/**
		The currently selected date
	 */
	NSDate *theDate;
	/**
		A picker used to select a date
	 */
	UIDatePicker *picker;
}

#pragma mark IBActions
/**
	Method signalling the user wishes to cancel selecting a date
 */
- (IBAction)cancel;
/**
	Method signalling the user has finished selecting a date
 */
- (IBAction)save;
/**
	Method signalling a change in the selected date
	@param sender The picker object selecting the date
 */
- (IBAction)datePicked:(id)sender;

@property (nonatomic, weak) id <DateViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDate *theDate;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UIDatePicker *picker;

@end
