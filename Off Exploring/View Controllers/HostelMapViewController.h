//
//  HostelMapViewController.h
//  Off Exploring
//
//  Created by Off Exploring on 13/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "HostelViewController.h"
#import "HostelTabBarViewController.h"
#import "HostelViewControllerDelegate.h"

@class HostelTabBarViewController;
/**
	@brief A UIViewController Subclass that displays a selectable list of recommended Hostels on a Map
 
	This class provides functionality to display the list of downloaded recommened hostels from Off Exploring,
	displaying them on a mapview. The class sets itself as a MKMapViewDelegate as appropriate.
	Finally, in order to display Hostel information, the class sets itself as a HostelViewController Delegate.
 */
@interface HostelMapViewController : UIViewController <MKMapViewDelegate, HostelViewControllerDelegate> {

	/**
		The map to display the hostels on
	 */
	MKMapView *mapView;
	/**
		The array of hostel annotations to display
	 */
	NSMutableArray *annotations;
	/**
		The array of hostels to display
	 */
	NSArray *hostels;
	/**
		TabBarViewController wrapping up this view
	 */
	HostelTabBarViewController *parentTabController;
}

#pragma mark Map Methods
/**
	Method called to zoom the map the area where pins have been dropped
	@param animated Wether to animate the zoom or not.
 */
- (void)zoomIn:(BOOL)animated;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *annotations;
@property (nonatomic, retain) NSArray *hostels;
@property (nonatomic, assign) HostelTabBarViewController *parentTabController;

@end
