//
//  CurrencyPreferenceViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 03/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CurrencyPreferenceViewController;

#pragma mark -
#pragma mark CurrencyPreferenceViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive a notification that a user has changed the default currency for the app
 
	This protocol allows delegates to be messaged when the user of the app switches the default currency of the app to a new one.
	Delegates are expected to dismiss the view. They are also expected to dimiss the view when the user cancels choosing a new currency, via
	the currencyPreferenceViewControllerDidCancel: delegate method
 */
@protocol CurrencyPreferenceViewControllerDelegate <NSObject>

@required

/**
	Delegate method messaged when the default currency for the app changes
	@param cpvc The CurrencyPrefenceViewController used to change the currency
	@param currency The new currency name
 */
- (void) currencyPreferenceViewController:(CurrencyPreferenceViewController *)cpvc didSetCurrency:(NSString *)currency;
/**
	Delegate method messaged when the user wishes to cancel choosing a new currency
	@param cpvc The CurrencyPrefenceViewController to dismiss
 */
- (void) currencyPreferenceViewControllerDidCancel:(CurrencyPreferenceViewController *)cpvc;

@end

#pragma mark -
#pragma mark CurrencyPreferenceViewController Interface

/**
	@brief A UIViewController Subclass that allows the user to change the default currency used by the app
 
	This class provides functionality to change the default currency used by the app. At present this is only relevant
	for booking Hostels, but may be used in the future for other features. The class displays the switcher using a 
	UITableView, and so sets itself as delegate and data source appropriately.
 */
@interface CurrencyPreferenceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{

	/**
		Delegate to notify of changes to the default currency
	 */
	id <CurrencyPreferenceViewControllerDelegate> __weak delegate;
	/**
		UITableView displaying the different currency options
	 */
	UITableView *tableView;
	/**
		Index for the currently selected currency
	 */
	NSIndexPath *selectedPath;
	/**
		Store for the previous stored currency
	 */
	NSString *oldCode;
}

#pragma mark IBActions
/**
	Action signalling user wishes to cancel setting a currency
 */
- (IBAction)cancel;
/**
	Action signalling user has finished selecting a new currency
 */
- (IBAction)set;

@property (nonatomic, weak) id <CurrencyPreferenceViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
