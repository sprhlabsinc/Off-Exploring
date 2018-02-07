//
//  HostelMapViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 13/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelMapViewController.h"
#import "DDAnnotation.h"
#import "DDAnnotationView.h"
#import "Hostels.h"
#import "Hostel.h"
#import "User.h"
#import "GANTracker.h"

#pragma mark -
#pragma mark HostelMapViewController Private Interface
/**
	@brief Private methods used to place annotaions on the map and create a timer to zoom into them
 
	This interface provides private methods to place pin annotations (DDAnnotation objects) on the MKMapView
	to display where the hostels are on a map. In addition, it provides a method to call to automatically
	zoom into the pins, once they have been placed, via a timer.
 */
@interface HostelMapViewController()
#pragma mark Private Method Declarations
/**
	Zooms in to the annotations after the given timer has fired
	@param theTimer The timer that fired the method
 */
- (void)zoomInToPoints:(NSTimer *)theTimer;
/**
	Lays out the DDAnnotation objects on the map
 */
- (void)placePointsOnMap;

@end

#pragma mark -
#pragma mark HostelMapViewController Implementation
@implementation HostelMapViewController

@synthesize mapView;
@synthesize annotations;
@synthesize hostels;
@synthesize parentTabController;

#pragma mark UIViewController Methods
- (void)dealloc {
	[hostels release];
	for (DDAnnotation *annotation in self.annotations) {
		[self.mapView removeAnnotation:annotation];
	}
	[annotations release];
	mapView.delegate = nil;
	[mapView release];
	[super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(zoomInToPoints:) userInfo:nil repeats:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[self placePointsOnMap];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.mapView = nil;
}

#pragma mark Map Methods
- (void)zoomIn:(BOOL)animated {
	CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(DDAnnotation* annotation in self.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:animated];
	
}

#pragma mark Private Methods
- (void)zoomInToPoints:(NSTimer *)theTimer { 
	[self zoomIn:YES];
}

- (void)placePointsOnMap {

	for (DDAnnotation *annotation in self.annotations) {
		[self.mapView removeAnnotation:annotation];
	}
	self.annotations = nil;
	
	User *user = [User sharedUser];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *lastHostelLookup = [[prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelLookup_%@",user.username]] retain];
	NSDictionary *searchLocation = [lastHostelLookup objectForKey:@"determinedDestination"];
	
	self.hostels = [Hostels loadHostelsFromDBorderedBy:HOSTELS_ORDER_OVERALL];
	if (searchLocation != nil) {
		NSMutableArray *anns = [[NSMutableArray alloc] initWithCapacity:([self.hostels count] + 1)];
		self.annotations = anns;
		[anns release];
	}
	else {
		NSMutableArray *anns = [[NSMutableArray alloc] initWithCapacity:[self.hostels count]];
		self.annotations = anns;
		[anns release];
	}
	
	int i = 0;
	
	NSString *currencySymbol = [[lastHostelLookup objectForKey:@"currency"] objectForKey:@"symbol"];
	[lastHostelLookup release];
	for (Hostel *aHostel in self.hostels) {
		CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:aHostel.latitude longitude:aHostel.longitude];
		DDAnnotation *annotation = [[DDAnnotation alloc] initWithCoordinate:newLocation.coordinate addressDictionary:nil];
		annotation.title = aHostel.name;
		if (aHostel.overall != 0) {
			annotation.subtitle = [NSString stringWithFormat:@"Price - %@%.2f, Rating - %.0f%%, Distance - %.2fM", currencySymbol,[[[aHostel lowestPrice] objectForKey:@"price"] doubleValue], aHostel.overall, aHostel.distance];
		}
		else {
			annotation.subtitle = [NSString stringWithFormat:@"Price - %@%.2f, Distance - %.2fM", currencySymbol,[[[aHostel lowestPrice] objectForKey:@"price"] doubleValue], aHostel.distance];
		}
		[self.annotations insertObject:annotation atIndex:i];
		[self.mapView addAnnotation:annotation];
		[annotation release];
		i++;
	}
	
	if (searchLocation != nil) {
	
		CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:[[searchLocation objectForKey:@"latitude"] doubleValue] longitude:[[searchLocation objectForKey:@"longitude"] doubleValue] ];
		DDAnnotation *searchLocationAnnotation = [[DDAnnotation alloc] initWithCoordinate:newLocation.coordinate addressDictionary:nil];
		searchLocationAnnotation.title = [NSString stringWithFormat:@"Searched For: %@",[searchLocation objectForKey:@"name"]];
		[self.annotations insertObject:searchLocationAnnotation atIndex:i];
		[self.mapView addAnnotation:searchLocationAnnotation];
		[searchLocationAnnotation release];
	}
}

#pragma mark MKMapView Delegate Method
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	
	DDAnnotation *ann = (DDAnnotation *)annotation;
	
	BOOL redPin = NO;
	int i = 0;
	for (Hostel *aHostel in self.hostels) {
		if ([aHostel.name isEqualToString:ann.title]) {
			redPin = YES;
			break;
		}
		else {
			i++;
		}
	}
	
	if (redPin) {
		
		DDAnnotationView *annotationView = (DDAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
		if (annotationView == nil) {
			annotationView = [[DDAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
			annotationView.moveAble = NO;
		}
		// Dragging annotation will need _mapView to convert new point to coordinate;
		annotationView.mapView = self.mapView;
	
		UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[button addTarget:self 
				   action:@selector(buttonClicked:) 
		 forControlEvents:UIControlEventTouchUpInside];
		button.tag = i;
		
		annotationView.rightCalloutAccessoryView = button;
		return annotationView;
		
	}
	else {
		
		MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
		annotationView.image = [UIImage imageNamed:@"UserPin.png"];
		annotationView.canShowCallout = YES;
		return annotationView;
	}
	
	return nil;
}

#pragma mark Action
- (void)buttonClicked:(id)sender {
	UIButton *button = (UIButton *)sender;
	Hostel *hostel = [self.hostels objectAtIndex:button.tag];
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/hostel/" withError:nil];
	HostelViewController *hostelView = [[HostelViewController alloc] initWithNibName:nil bundle:nil];
	hostelView.hostel = hostel;
	hostelView.delegate = self;
	[self.parentTabController presentViewController:hostelView animated:YES completion:nil];
	[hostelView release];
}

#pragma mark HostelViewController Delegate Methods
- (void)hostel:(Hostel *)hostel withRoom:(Room *)room wasBookedFor:(NSNumber *)people dismissingHostelViewController:(HostelViewController *)hvc {
	[self dismissViewControllerAnimated:NO completion:nil];
	[self.parentTabController.rootNav hostel:hostel withRoom:room wasBookedFor:people dismissingHostelViewController:hvc];
}

- (void)closeHostelViewController:(HostelViewController *)hvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/hostels/map/" withError:nil];
	[hvc dismissViewControllerAnimated:YES completion:nil];
}


@end
