//
//  MapViewController.h
//  Off Exploring
//
//  Created by Ian Outterside on 30/01/2013.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MapViewController;
@protocol MapViewControllerDelegate <NSObject>

@required

- (void)mapViewController:(MapViewController *)mvc didFinishWithXords:(NSDictionary *)xords;
- (void)mapViewControllerDidCancel:(MapViewController *)mvc;

@end

@interface MapViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate>

@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIToolbar *theToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *moveToMyLocationButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil presetLocation:(CLLocation *)location;

- (IBAction)save;
- (IBAction)cancel;
- (IBAction)locateMe;
- (IBAction)placePin;

@end
