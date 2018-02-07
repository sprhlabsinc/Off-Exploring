//
//  StateSelectionViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 29/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StateSelectionViewController;

#pragma mark -
#pragma mark StateSelectionViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive a selected state name
 
	This protocol allows delegates to be messaged when the user has finished selecting a "state" from the list of states Off
	Exploring uses. It returns the ISO code and state name for the state. The delegate is also messaged if the user cancels state selection.
	The delegate may also optionally set the title of the dialogue via a delegate method.
 */
@protocol StateSelectionViewControllerDelegate <NSObject>

@required
#pragma mark Required Delegate Methods
/**
	Delegate method messaged when a user has finished selecting a state
	@param ssvc The StateSelectionViewController object used to select the state
	@param stateDict The dictionary containing state information about the selected state
 */
- (void)stateSelectionViewController:(StateSelectionViewController *)ssvc didFinishSelectingState:(NSDictionary *)stateDict;
/**
	Delegate method messaged when a user cancels selecting a state
	@param ssvc The StateSelectionViewController to dismiss
 */
- (void)stateSelectionViewControllerDidCancel:(StateSelectionViewController *)ssvc;

@optional 
#pragma mark Optional Delegate Method
/**
	Delegate method used for delegates to optionally set the title of the view
	@param ssvc The StateSelectionViewController object used to select the state
	@param status A flag stating wether the list of states was preloaded
	@returns The title to set on the page
 */
- (NSString *)titleForStateSelectionViewController:(StateSelectionViewController *)ssvc wasPreloaded:(BOOL)status;

@end

#pragma mark -
#pragma mark StateSelectionViewController Interface

/**
	@brief A UIViewController Subclass that allows users to select a country / state from a list 
 
	This class provides an interface to select a state or country from a list in order to help specify a location.
	It sets itself as a UITableView Delegate and Data Source to list the countries and states
 */
@interface StateSelectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{

	/**
		Delegate method to be signalled about selection
	 */
	id <StateSelectionViewControllerDelegate> __weak delegate;
	/**
		The list of states to display
	 */
	NSDictionary *stateList;
	/**
		A flag to say if the list of states was loaded from the plist or generated elsewhere
	 */
	BOOL preLoaded;
	/**
		A pointer to the navigation bar to change the title
	 */
	UINavigationBar *navBar;

@private
	/**
		The name of the selected state to return
	 */
	NSString *stateName;
	/**
		An array of keys to use to identify states in the tableview
	 */
	NSArray *dictionaryKeys;
	/**
		An array of section titles to use to jump between sections in the tableview
	 */
	NSArray *sectionIndexTitles;
	/**
		A counter for how many rows are in each section of the tableview
	 */
	NSMutableDictionary *rowNumbers;
	/**
		The running total of how many rows are in a section of the tableview
	 */
	int runningTotal;
}

#pragma mark IBActions
- (IBAction)cancel;

@property (nonatomic, weak) id <StateSelectionViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *stateList;
@property (nonatomic, assign) BOOL preLoaded;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;

@end
