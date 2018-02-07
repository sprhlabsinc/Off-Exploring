//
//  HostelAddressViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 01/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HostelRatingViewController.h"

#pragma mark -
#pragma mark HostelAddressViewController Interface

/**
	@brief A HostelRatingViewController Subclass that displays the address of a Hostel
 
	This class extends HostelRatingViewController to redeclare the UITableView Delegate and Data Source methods to display
	a hostels address instead of a list of ratings.
 */
@interface HostelAddressViewController : HostelRatingViewController {

}

@end
