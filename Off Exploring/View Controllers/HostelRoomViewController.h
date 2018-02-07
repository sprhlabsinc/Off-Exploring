//
//  HostelRoomViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 03/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hostel.h"
#import "Room.h"

/**
	@brief A UIViewController Subclass that displays an array of Hostel Room objects
 
	This class provides the functionality to display an array of Room objects belonging to a Hostel, so that one
	can be selected for use as part of a booking. The class displays the Rooms as part of a tableview, and sets
	itself as a UITableView delegate and data source appropriately. In order to select a room as part of a booking,
	the number of people booking the room must be set, and this is done using a UIPickerView. Therefore, the class
	is also a UIPickerView delegate and data source.
 */
@interface HostelRoomViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, 
														UIPickerViewDelegate, UIPickerViewDataSource>
{
	/**
		The tableview displaying the array of rooms
	 */
	UITableView *tableView;
	/**
		The array of rooms a Hostel has
	 */
	NSArray *rooms;
	/**
		The hostel the rooms belong to
	 */
	Hostel *hostel;
	
@private
	/**
		The room selected to book
	 */
	Room *selectedRoom;
	/**
		The number of people selected to book the room
	 */
	int people;
	/**
		UIActionSheet wrapping up a UIPickerView for selecting number of people booking a room
	 */
	UIActionSheet *actionSheet;
}

#pragma mark Actions
/**
	Action signalling the user wishes to book a hostel
	@param button The book button that was pressed
 */
- (void)bookHostel:(id)button;
/**
	Action signalling the user has selected the number of people to book with
 */
- (void)pickerDoneClick;
/**
	Action signalling the user wishes to cancel picking the number of people to book with
 */
- (void)pickerCancelClick;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) Hostel *hostel;
@property (nonatomic, retain) NSArray *rooms;

@end
