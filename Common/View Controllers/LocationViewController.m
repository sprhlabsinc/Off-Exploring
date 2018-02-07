//
//  LocationViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 28/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "LocationViewController.h"
#import "BlogDetailTableViewCell.h"
#import "MapViewController.h"
#import "GANTracker.h"
#import "Constants.h"

#pragma mark -
#pragma mark LocationViewController Implementation
@implementation LocationViewController

@synthesize tableView;
@synthesize state;
@synthesize area;
@synthesize geolocation;
@synthesize delegate;
@synthesize offexValid;
@synthesize realCountryName;
@synthesize validState;

#pragma mark UIViewController Methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background2]]];
	self.tableView.backgroundColor = [UIColor clearColor];
    if ([UIColor tableViewSeperatorColor]) {
        self.tableView.separatorColor = [UIColor tableViewSeperatorColor];
    }
	
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"states" ofType:@"plist"];
	offexValid = [NSDictionary dictionaryWithContentsOfFile:plistPath];
	
	if (self.state) {
		for (id aState in [self.offexValid allValues]) {
			if ([aState isKindOfClass:[NSString class]] && [aState isEqualToString:(self.state)[@"name"]]) {
				self.realCountryName = (self.state)[@"name"];
			}
			else if ([aState isKindOfClass:[NSDictionary class]]) {
				NSArray *theStates = [[aState allValues][0] allValues];
				
				NSString *aStateName;
				for (aStateName in theStates) {
					if ([aStateName isEqualToString:(self.state)[@"name"]]) {
						self.realCountryName = [aState allKeys][0];
					}
				}
			}
		}
	}
	
	self.validState = YES;
	
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.tableView = nil;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark IBActions
- (IBAction)done {
	NSString *message = nil;
	
	if ([delegate respondsToSelector:@selector(locationViewControllerMustHaveCompleteLocationDetails:)]) {
		BOOL required = [delegate locationViewControllerMustHaveCompleteLocationDetails:self];
		
		if (required == YES) {
			if (self.state != nil && (self.state)[@"name"] != nil && ![(self.state)[@"name"] isEqualToString:@""]) {
				if (self.area == nil || (self.area)[@"name"] == nil || [(self.area)[@"name"] isEqualToString:@""]) {
					message = @"Please Set A Location!";
				}
			}
			else if (self.area != nil && (self.area)[@"name"] != nil && ![(self.area)[@"name"] isEqualToString:@""]) {
				if (self.state == nil || (self.state)[@"name"] == nil || [(self.state)[@"name"] isEqualToString:@""]) {
					message = @"Please Select A State!";
				}
			}
		}
	}
	
	if (self.validState == NO) {
		message = @"Please Select A State!";
	}
	
	if (message) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:message
								  message:nil
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
	else {
		[delegate locationViewController:self didFinishWithState:self.state withArea:self.area withGeolocation:self.geolocation];
	}
}

#pragma mark UITableView Delegate and Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 1) {
		if (realCountryName != nil && ![realCountryName isEqualToString:@""] && ![realCountryName isEqualToString:(self.state)[@"name"]]) {
			return 3;
		}
		else {
			return 2;
		}
	}
	else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	BlogDetailTableViewCell *cell = (BlogDetailTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
	if (cell == nil) {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogDetailTableViewCell" owner:nil options:nil];
		for (id currentObject in nibObjects) {
			if ([currentObject isKindOfClass:[BlogDetailTableViewCell class]]) {
				cell = (BlogDetailTableViewCell *)currentObject;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}
	}
	if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			cell.label.text = @"Location";
			cell.detail.text = (self.area)[@"name"];
		}
		else if (indexPath.row == 1) {
			cell.label.text = @"Country";
			cell.detail.text = realCountryName;
		}
		
		else {
			cell.label.text = @"State";
			if ([(self.state)[@"name"] isKindOfClass:[NSString class]]) {
				cell.detail.text = (self.state)[@"name"];
			}
			else {
				cell.detail.text = @"";
			}
			
		}
	}
	else {
        if (cell.label) {
            cell.label.frame = CGRectMake(cell.label.frame.origin.x, cell.label.frame.origin.y, 200, cell.label.frame.size.height);
            cell.label.text = @"Set location on map";
        }
        
        if (cell.detail) {
            cell.detail.text = @"";
        }
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0) {
		[[GANTracker sharedTracker] trackPageview:@"/location/edit/map/" withError:nil];
		MapViewController *map = nil;
		if (self.geolocation && (self.geolocation)[@"latitude"] != nil && (self.geolocation)[@"longitude"] != nil) {
			CLLocation *location = [[CLLocation alloc] initWithLatitude:[(self.geolocation)[@"latitude"] doubleValue] longitude:[(self.geolocation)[@"longitude"] doubleValue]];
			map = [[MapViewController alloc] initWithNibName:nil bundle:nil presetLocation:location];
		}
		else {
			map = [[MapViewController alloc] initWithNibName:nil bundle:nil];
		}
		map.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		map.delegate = self;
		[self presentViewController:map animated:YES completion:nil];
	}
	else {
		if (indexPath.row == 0) {
			[[GANTracker sharedTracker] trackPageview:@"/location/edit/area/" withError:nil];
			LocationTextViewController *ltvc = [[LocationTextViewController alloc]initWithNibName:nil bundle:nil];
			ltvc.delegate = self;
			ltvc.area = self.area;
			[self presentViewController:ltvc animated:YES completion:nil];
		}
		else if (indexPath.row == 1) {
			[[GANTracker sharedTracker] trackPageview:@"/location/edit/state/" withError:nil];
			StateSelectionViewController *stateSelector = [[StateSelectionViewController alloc]initWithNibName:nil bundle:nil];
			stateSelector.delegate = self;
			[self presentViewController:stateSelector animated:YES completion:nil];
		}
		else if (indexPath.row == 2) {
			NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"states" ofType:@"plist"];
			NSDictionary *stateList = [NSDictionary dictionaryWithContentsOfFile:plistPath];
			
			NSArray *dictionaryKeys = [stateList allValues];
			
			for (id dict in dictionaryKeys) {
				if ([dict isKindOfClass:[NSDictionary class]]) {
					NSDictionary *country = (NSDictionary *)dict;
					if ([[country allKeys][0] isEqualToString:self.realCountryName]) {
						NSDictionary *theDict = [country allValues][0];
						[[GANTracker sharedTracker] trackPageview:@"/location/edit/state/" withError:nil];
						StateSelectionViewController *stateSelector = [[StateSelectionViewController alloc]initWithNibName:nil bundle:nil];
						stateSelector.delegate = self;
						stateSelector.stateList = theDict;
						stateSelector.preLoaded = YES;
						[self presentViewController:stateSelector animated:YES completion:nil];
					}
				}
			}
		}
	}
}

#pragma mark MapViewController Delegate Methods
- (void)mapViewController:(MapViewController *)mvc didFinishWithXords:(NSDictionary *)xords {
	if (xords != nil) {
        NSDictionary *geoLocationDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:xords[@"latitude"], @"latitude", xords[@"longitude"], @"longitude", nil];
		self.geolocation = geoLocationDictionary;
		
		NSString *areaName;
		if (xords[@"addressDetails"][@"City"] && (![xords[@"addressDetails"][@"City"] isEqualToString:xords[@"addressDetails"][@"State"]])) {
			areaName = [NSString stringWithFormat:@"%@",xords[@"addressDetails"][@"City"]];
		}
		else {
			areaName = xords[@"addressDetails"][@"State"];
		}
        NSDictionary *areaDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:areaName, @"name", nil];
		self.area = areaDictionary;
		
		NSString *theCountry = xords[@"addressDetails"][@"CountryCode"];
		
		if ((self.offexValid)[theCountry] != nil && [(self.offexValid)[theCountry] isKindOfClass:[NSString class]]) {
            NSDictionary *stateDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:(self.offexValid)[theCountry], @"name", nil];
			self.state = stateDictionary;
			self.realCountryName = (self.state)[@"name"];
		}
		else if ((self.offexValid)[theCountry] != nil && [(self.offexValid)[theCountry] isKindOfClass:[NSDictionary class]]){
			NSString *theState = xords[@"addressDetails"][@"State"];
			NSArray *theStates = [[(self.offexValid)[theCountry] allValues][0] allValues];
			
			NSString *aStateName;
			self.realCountryName = [(self.offexValid)[theCountry] allKeys][0];
			for (aStateName in theStates) {
				if ([aStateName isEqualToString:theState]) {
                    NSDictionary *stateDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:aStateName, @"name", nil];
					self.state = stateDictionary;
				}
			}
		}
		[self.tableView reloadData];
	}
	[[GANTracker sharedTracker] trackPageview:@"/location/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mapViewControllerDidCancel:(MapViewController *)mvc {
	[[GANTracker sharedTracker] trackPageview:@"/location/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark StateSelectionViewController Delegate Methods
- (NSString *)titleForStateSelectionViewController:(StateSelectionViewController *)ssvc wasPreloaded:(BOOL)status {
	if(status == YES) {
		return @"Select State";
	}
	else {
		return @"Select Country";
	}
}

- (void)stateSelectionViewController:(StateSelectionViewController *)ssvc didFinishSelectingState:(NSDictionary *)stateDict {
	if ([stateDict[@"preLoaded"] boolValue] == NO) {
	
		NSString *isoCode;
		
		if ([[stateDict allKeys][0] length] <= 3) {
			isoCode = [stateDict allKeys][0];
		}
		else {
			isoCode = [stateDict allKeys][1];
		}
		if ([(self.offexValid)[isoCode] isKindOfClass:[NSString class]]) {
            NSDictionary *stateDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:(self.offexValid)[isoCode], @"name", nil];
			self.state = stateDictionary;
			self.realCountryName = (self.offexValid)[isoCode];
		}
		else {
            NSDictionary *stateDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:(self.offexValid)[isoCode], @"name", nil];
			self.state = stateDictionary;
			self.realCountryName = [stateDict[isoCode] allKeys][0];
			self.validState = NO;
		}
	}
	else {
		if ([[stateDict allKeys][0] length] <= 3) {
            NSDictionary *stateDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[stateDict allValues][0], @"name", nil];
			self.state = stateDictionary;
		}
		else {
            NSDictionary *stateDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[stateDict allValues][1], @"name", nil];
			self.state = stateDictionary;
		}
		self.validState = YES;
	}
	
	[self.tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/location/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)stateSelectionViewControllerDidCancel:(StateSelectionViewController *)ssvc {
	[[GANTracker sharedTracker] trackPageview:@"/location/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark LocationTextViewController Delegate Methods
- (void)locationTextViewController:(LocationTextViewController *)ltvc withTitle:(NSString *)title didFinishEditingLocation:(NSDictionary *)location {
	self.area = location; 
	[tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/location/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationTextViewControllerDidCancel:(LocationTextViewController *)ltvc {
	[[GANTracker sharedTracker] trackPageview:@"/location/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
