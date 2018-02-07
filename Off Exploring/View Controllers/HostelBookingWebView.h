//
//  HostelBookingWebView.h
//  Off Exploring
//
//  Created by Off Exploring on 06/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hostel.h"
#import "Room.h"

#pragma mark -
#pragma mark HostelBookingWebView Interface

/**
	@brief A UIViewController Subclass that allows users to make bookings to Hostelbookers via the embedded webview. 
 
	This class provides a webview allowing users of the app to fill out information on Hostelbookers in order to book
	a hostel they have found using the app. The hostel information is pre-populated, and as soon as the hostel is booked
	a done button appears redirecting the user back to the home screen of the app. The app sets itself as a UIWebViewDelegate
	to detect when a successful booking has been made via the URL
 */
@interface HostelBookingWebView : UIViewController <UIWebViewDelegate> {

	/**
		The webview displaying the booking page
	 */
	UIWebView *webView;
	/**
		The hostel the booking is for
	 */
	Hostel *hostel;
	/**
		The room the booking is for
	 */
	Room *room;
	/**
		The number of people the booking is for
	 */
	int people;
	/**
		A loader to display when making remote requests
	 */
	UIActivityIndicatorView *activityIndicator;
	/**
		A button pressed to reset the form
	 */
	UIBarButtonItem *resetButton;
	/**
		A button pressed when booking is complete
	 */
	UIBarButtonItem *doneButton;
	/**
		Pointer to the toolbar to remove restart booking button
	 */
	UIToolbar *toolBar;
	
@private
	BOOL success;
}

#pragma mark IBActions
/**
	Action signalling the users wish to reset the form in the webview
 */
- (IBAction)resetPage;
/**
	Action signalling the user has completed there booking and wishes to return to the home screen
 */
- (IBAction)doneBooking;

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *resetButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) Hostel *hostel;
@property (nonatomic, retain) Room *room;
@property (nonatomic, assign) int people;

@end
