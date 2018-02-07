//
//  HostelTabBarViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 12/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HostelSearchViewController.h"
#import "RootViewController.h"
#import "HostelListViewController.h"
#import "HostelMapViewController.h"

@class HostelListViewController, HostelMapViewController;
/**
	@brief A UIViewController Subclass that wraps up two TabBar Views for hostels
 
	This class wraps up and displays the two main Hostel display views (HostelListViewController and HostelMapViewController).
	It holds a pointer to the rootNav so navigation jumping can occur. The class sets itself as a HostelSearchViewController 
	delegate to dismiss the search modal dialogue, and a UITabBarController to be notified of which tab a user wishes to view 
	and message viewWillAppear as appropriate.
 */
@interface HostelTabBarViewController : UIViewController <HostelSearchViewControllerDelegate, UITabBarDelegate> {

	/**
		A pointer to the RootViewController used for view jumping
	 */
	RootViewController *rootNav;
	/**
		The HostelListViewController to display in the tab bar
	 */
	HostelListViewController *hlvc;
	/**
	 The HostelMapViewController to display in the tab bar
	 */
	HostelMapViewController *hmvc;
	/**
		Navigation bar to display above the view controller
	 */
	UINavigationBar *tabBarWrapper;
	/**
		The tab bar being displayed
	 */
	UITabBar *tabBar;
}

#pragma mark IBActions
/**
	Action signalling the user wishes to return to the rootViewController
 */
- (IBAction)homePressed;
/**
	Action signalling the user wishes to perform a new Hostel search
 */
- (IBAction)searchPressed;

@property (nonatomic, assign) RootViewController *rootNav;
@property (nonatomic, retain) HostelListViewController *hlvc;
@property (nonatomic, retain) HostelMapViewController *hmvc;
@property (nonatomic, retain) IBOutlet UINavigationBar *tabBarWrapper;
@property (nonatomic, retain) IBOutlet UITabBar *tabBar;
@end
