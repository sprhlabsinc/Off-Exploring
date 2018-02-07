//
//  HostelViewControllerDelegate.h
//  Off Exploring
//
//  Created by Off Exploring on 08/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hostel.h"
#import "Room.h"
#import "HostelViewController.h"

@class HostelViewController;

#pragma mark -
#pragma mark HostelViewControllerDelegate Declaration
/**
	@brief Details a protocol that must be adheared to, in order to receive a message that a Hostel has been booked
 
	This protocol allows delegates to be messaged when the user books a Room within a Hostel. The delegates receiver
	is expected to dismiss the current view at this point. It is also expected to dismiss the view when the closeHostelViewController:
	delegate method fires.
 */
@protocol HostelViewControllerDelegate <NSObject>
#pragma mark Optional Delegate Methods
@optional

/**
	Delegate method messaged when a user books a Room at a Hostel
	@param hostel The hostel that was booked
	@param room The room that was booked
	@param people The number of people the room was booked for
	@param hvc The HostelViewController object to be dismissed
 */
- (void) hostel:(Hostel *)hostel withRoom:(Room *)room wasBookedFor:(NSNumber *)people dismissingHostelViewController:(HostelViewController *)hvc;

/**
	Delegate method messaged when a user wishes to dismiss the HostelViewController
	@param hvc The HostelViewController object to be dismissed 
 */
- (void) closeHostelViewController:(HostelViewController *)hvc;

@end