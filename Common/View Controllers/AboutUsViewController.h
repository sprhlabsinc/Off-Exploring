//
//  AboutUsViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 30/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffexConnex.h"

#pragma mark -
#pragma mark AboutUsViewController Interface

/**
	@brief A UIViewController Subclass that displays system messages from the API source
 
	This class connects to Off Exploring and downloads the latest system messages, and is an OffexploringConnection
	delegate as such to respond to these connections. These messages are stored in a database table and displayed
	in a tableview for the user to see, and so the class sets itself as a UITableView delegate and data source.
 */
@interface AboutUsViewController : UIViewController <OffexploringConnectionDelegate, UITableViewDelegate, UITableViewDataSource>{

	UITableView *theTableView;
@private
	NSArray *messageArray;
	OffexConnex *connex;
}

@property (nonatomic, strong) IBOutlet UITableView *theTableView;

@end
