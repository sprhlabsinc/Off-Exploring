//
//  MapViewController.m
//  Off Exploring
//
//  Created by Ian Outterside on 30/01/2013.
//
//

#import "MapViewController.h"
#import "INTULocationManager.h"

@interface OFXMapAnnotation : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString *subtitleString;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLPlacemark *locationInformation;

- (id)initWithCoordinate:(CLLocationCoordinate2D)location geocode:(BOOL)geocode;
- (void)geocodeLocation;

@end

@implementation OFXMapAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)location geocode:(BOOL)geocode {
    
    if (self = [super init]) {
        
        [self willChangeValueForKey:@"coordinate"];
        _coordinate = location;
        [self didChangeValueForKey:@"coordinate"];
        
        if (geocode) {
            [self geocodeLocation];
        }
    }
    
    return self;
}

- (NSString *)title {
    return @"Drag To Move Pin";
}

- (NSString *)subtitle {
    if (!self.subtitleString)
        return @"Locating...";
    else
        return self.subtitleString;
}

- (void)setLocationInformation:(CLPlacemark *)locationInformation {
    [self willChangeValueForKey:@"locationInformation"];
    
    _locationInformation = locationInformation;
    if (!locationInformation)
        self.subtitleString = nil;
    else {
        
        if (locationInformation.addressDictionary[@"City"]) {
            self.subtitleString = locationInformation.addressDictionary[@"City"];
        }
        else if (locationInformation.addressDictionary[@"State"]) {
            self.subtitleString = locationInformation.addressDictionary[@"State"];
        }
        else if (locationInformation.addressDictionary[@"Country"]) {
            self.subtitleString = locationInformation.addressDictionary[@"Country"];
        }
        else if (locationInformation.administrativeArea){
            self.subtitleString = locationInformation.administrativeArea;
        }
        else {
            self.subtitleString = nil;
        }
    }
    
    [self didChangeValueForKey:@"locationInformation"];
}

- (void)geocodeLocation {
    
    // Cancel previous geocode
    if (self.geocoder) {
        [self.geocoder cancelGeocode];
        self.geocoder = nil;
    }
    
    if (!self.locationInformation) {
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
        
        self.geocoder = [[CLGeocoder alloc] init];
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error && [placemarks count]) {
                self.locationInformation = placemarks[0];
            }
        }];
    }
}

@end

@interface MapViewController()

@property (strong, nonatomic) CLLocation *presetLocation;
@property (strong, nonatomic) OFXMapAnnotation *selectedAnnotation;
@property (strong, nonatomic) CLGeocoder *forwardGeocoder;
@property (assign, nonatomic) BOOL annotationAdded;

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil presetLocation:(CLLocation *)location {
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.presetLocation = location;
        
        self.annotationAdded = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CLLocation *initialLocation = nil;
    
    if (self.presetLocation) {
        
        initialLocation = self.presetLocation;
    }
    // If no location services, default to london and cant move to my location, disable the button
    else if ([INTULocationManager locationServicesState] != INTULocationServicesStateAvailable) {
        initialLocation = [[CLLocation alloc] initWithLatitude:51.499101 longitude:-0.124632];
    }
    
    self.moveToMyLocationButton.enabled = NO;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    if (initialLocation) {
        [self setPinWithLocation:initialLocation];
    }
    else {
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(setDefaultPin) userInfo:nil repeats:NO];
    }
}

- (IBAction)save {
    
    // Cant save if geocoding is happening
    if (self.forwardGeocoder.geocoding || self.selectedAnnotation.geocoder.geocoding) {
        
        [[[UIAlertView alloc] initWithTitle:@"Please Wait" message:@"We are still getting the requested location, please wait." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else {
        
        CLPlacemark *newPlacemark = self.selectedAnnotation.locationInformation;
        NSDictionary *returnDictionary = [self xordsDictionaryWithPlaceMark:newPlacemark];
        
        if (!returnDictionary) {
            
            [[[UIAlertView alloc] initWithTitle:@"Unable To Locate" message:@"You have selected an unrecognised location." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        else {
            
            if ([self.delegate respondsToSelector:@selector(mapViewController:didFinishWithXords:)]) {
                [self.delegate mapViewController:self didFinishWithXords:returnDictionary];
            }
        }
    }
}

- (NSDictionary *)xordsDictionaryWithPlaceMark:(CLPlacemark *)newPlacemark {
    
    NSMutableDictionary *xords = [[NSMutableDictionary alloc] init];
    (xords)[@"latitude"] = @(newPlacemark.location.coordinate.latitude);
    (xords)[@"longitude"] = @(newPlacemark.location.coordinate.longitude);
    
    if ((newPlacemark.addressDictionary)[@"City"] && (![(newPlacemark.addressDictionary)[@"City"] isEqualToString:(newPlacemark.addressDictionary)[@"State"]]))
        (xords)[@"addressDetails"] = newPlacemark.addressDictionary;
    else if ((newPlacemark.addressDictionary)[@"State"])
        (xords)[@"addressDetails"] = newPlacemark.addressDictionary;
    else if ((newPlacemark.addressDictionary)[@"Country"])
        (xords)[@"addressDetails"] = newPlacemark.addressDictionary;
    
    if (!xords[@"addressDetails"]) {
        NSLog(@"No Address for location: %@", newPlacemark);
        return nil;
    }
    else
        return [NSDictionary dictionaryWithDictionary:xords];
}

- (IBAction)cancel {
    if ([self.delegate respondsToSelector:@selector(mapViewControllerDidCancel:)])
        [self.delegate mapViewControllerDidCancel:self];
}

- (IBAction)locateMe {
    [self setPinWithLocation:self.mapView.userLocation.location];
}

- (IBAction)placePin {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    [self setPinWithLocation:location geocode:YES zoom:NO];
}

// If an annotation was not added in 5 seconds, manually add one
- (void)setDefaultPin {
    if (!self.annotationAdded) {
        [self setPinWithLocation:[[CLLocation alloc] initWithLatitude:51.499101 longitude:-0.124632]];
    }
}

- (void)setPinWithLocation:(CLLocation *)location {
    [self setPinWithLocation:location geocode:YES zoom:YES];
}

- (void)setPinWithLocation:(CLLocation *)location geocode:(BOOL)geocode zoom:(BOOL)zoom {
    
    self.annotationAdded = YES;
    
    if (self.selectedAnnotation) {
        [self.mapView removeAnnotation:self.selectedAnnotation];
        
        self.selectedAnnotation = nil;
    }
    
    self.selectedAnnotation = [[OFXMapAnnotation alloc] initWithCoordinate:location.coordinate geocode:geocode];
    [self.mapView addAnnotation:self.selectedAnnotation];
    
    if (zoom) {
        [self setMapZoomAndRegionIncludingUserLocation:YES];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.doneButton.enabled = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	// Forward geocode!
    // Cancel previous geocode
    
    self.doneButton.title = @"Wait...";
    
    if (self.forwardGeocoder) {
        [self.forwardGeocoder cancelGeocode];
        self.forwardGeocoder = nil;
    }
    
    self.forwardGeocoder = [[CLGeocoder alloc] init];
    [self.forwardGeocoder geocodeAddressString:theSearchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        
        self.doneButton.title = @"Save";
        self.doneButton.enabled = YES;
        
        if (!error && [placemarks count]) {
            
            CLPlacemark *placemark = placemarks[0];
            [self setPinWithLocation:placemark.location geocode:NO zoom:NO];
            self.selectedAnnotation.locationInformation = placemark;
            [self setMapZoomAndRegionIncludingUserLocation:NO];
            
        }
        else {
            
            // Alert with error location not found
            NSLog(@"Error: %@ UserInfo: %@", error, [error userInfo]);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable To Locate" message:[[error userInfo] valueForKey:NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
	// Dismiss the keyboard
	[theSearchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.doneButton.enabled = YES;
    [searchBar resignFirstResponder];
}

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    // Also enabled the location services button if it was disabled earlier
    self.moveToMyLocationButton.enabled = YES;
    
    if (!self.annotationAdded) {
        
        CLLocation *initialLocation = [[CLLocation alloc] initWithLatitude:self.mapView.userLocation.location.coordinate.latitude longitude:self.mapView.userLocation.location.coordinate.longitude];
        
        [self setPinWithLocation:initialLocation];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
    if (newState == MKAnnotationViewDragStateEnding) {
        self.selectedAnnotation.locationInformation = nil;
        [self.selectedAnnotation geocodeLocation];
    }
}

- (void)setMapZoomAndRegionIncludingUserLocation:(BOOL)included {
    
    CLLocation *selectedLocation = [[CLLocation alloc] initWithLatitude:self.selectedAnnotation.coordinate.latitude longitude:self.selectedAnnotation.coordinate.longitude];
    
    if (included && self.mapView.userLocation.location) {
        NSArray *coordinates = @[selectedLocation, self.mapView.userLocation.location];
        
        CLLocationCoordinate2D maxCoord = {-90.0f, -180.0f};
        CLLocationCoordinate2D minCoord = {90.0f, 180.0f};
        
        for(CLLocation *value in coordinates) {
            
            CLLocationCoordinate2D coord = value.coordinate;
            
            if (coord.latitude != 0 || coord.longitude != 0) {
                if(coord.longitude > maxCoord.longitude) {
                    maxCoord.longitude = coord.longitude;
                }
                
                if(coord.latitude > maxCoord.latitude) {
                    maxCoord.latitude = coord.latitude;
                }
                
                if(coord.longitude < minCoord.longitude) {
                    minCoord.longitude = coord.longitude;
                }
                
                if(coord.latitude < minCoord.latitude) {
                    minCoord.latitude = coord.latitude;
                }
            }
        }
        
        MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
        region.center.longitude = (minCoord.longitude + maxCoord.longitude) / 2.0;
        region.center.latitude = (minCoord.latitude + maxCoord.latitude) / 2.0;
        region.span.longitudeDelta = (maxCoord.longitude - minCoord.longitude) + 1;
        region.span.latitudeDelta = (maxCoord.latitude - minCoord.latitude) + 1;
        [self.mapView setRegion:region animated:YES];
    }
    else {
        MKCoordinateRegion region;
        region.center = selectedLocation.coordinate;
        MKCoordinateSpan span;
        span.latitudeDelta  = 1;
        span.longitudeDelta = 1;
        region.span = span;
        [self.mapView setRegion:region animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[OFXMapAnnotation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.draggable = YES;
        
        return annotationView;
    }
    
    return nil;
}

@end
