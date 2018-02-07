//
//  HostelSearchViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 24/08/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "HostelSearchViewController.h"
#import "BlogDetailTableViewCell.h"
#import "DB.h"
#import "User.h"
#import "Reachability.h"

#pragma mark -
#pragma mark HostelSearchViewController Implementation
@implementation HostelSearchViewController

@synthesize hostelDelegate;

#pragma mark UIViewController Methods
- (void)dealloc {
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
	}
	return self;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	if ([hostelDelegate respondsToSelector:@selector(cityForHostelSearchViewController:)]) {
		NSDictionary *respondsArea = [[NSDictionary alloc] initWithObjectsAndKeys:[hostelDelegate cityForHostelSearchViewController:self], @"name", nil];
		self.area = respondsArea;
		[respondsArea release];
	}
	if ([hostelDelegate respondsToSelector:@selector(countryForHostelSearchViewController:)]) {
		
		self.realCountryName = [hostelDelegate countryForHostelSearchViewController:self];
		
		for (NSString *countryISO in self.offexValid) {
			
			if ([[self.offexValid objectForKey:countryISO] isKindOfClass:[NSString class]]) {
				
				if ([[self.offexValid objectForKey:countryISO] isEqualToString:self.realCountryName]) {
					self.validState = YES;
					NSDictionary *theState = [[NSDictionary alloc] initWithObjectsAndKeys:self.realCountryName, @"name", nil];
					self.state = theState;
					[theState release];
					break;
				}
			}
			else {
				NSDictionary *theStates = [[[self.offexValid objectForKey:countryISO] allValues] objectAtIndex:0];
				
				NSString *aStateName;
				for (aStateName in theStates) {
					if ([[theStates objectForKey:aStateName] isEqualToString:self.realCountryName]) {
						NSDictionary *theState = [[NSDictionary alloc] initWithObjectsAndKeys:self.realCountryName, @"name", nil];
						self.state = theState;
						[theState release];
						self.realCountryName = [[[self.offexValid objectForKey:countryISO] allKeys] objectAtIndex:0];
					}
				}
			}
		}
	}
	
	showRatings = NO;
	
	User *user = [User sharedUser];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *hostelPreferences = [[prefs dictionaryForKey:[NSString stringWithFormat:@"latestHostelPreferences_%@",user.username]] retain];
	if (hostelPreferences != nil) {
		searchMode = [[hostelPreferences objectForKey:@"orderBy"] intValue];
		if (searchMode >= HOSTELS_ORDER_OVERALL) {
			showRatings = YES;
		}
	}
	if (searchMode == -1) {
		searchMode = 1;
	}
	[hostelPreferences release];
}

#pragma mark IBActions

- (IBAction)cancel {
	
	[hostelDelegate hostelSearchViewControllerDidCancel:self];
	
}
- (IBAction)search {
	
	Reachability *r = [Reachability reachabilityWithHostName:@"www.offexploring.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	if (internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN) {
		if ([[self.area objectForKey:@"name"] isEqualToString:@""] || [self.area objectForKey:@"name"] == nil || [self.realCountryName isEqualToString:@""]|| self.realCountryName == nil) {
			UIAlertView *charAlert = [[UIAlertView alloc]
									  initWithTitle:@"Please Enter Location and Country!"
									  message:@"To search for hostels, please enter a location and select a country from the list."
									  delegate:nil
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
			[charAlert show];
			
		}
		else {
			DB *db = [DB sharedDB];
			[db emptyHostelsDB];
			
			User *user = [User sharedUser];
			NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
			
			NSDate *expires = [NSDate dateWithTimeIntervalSinceNow:3600];
			
			NSDictionary *newHostelPreferences = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:HOSTELS_LOOKUP_SEARCH],@"lookupType",[NSNumber numberWithInt:searchMode],@"orderBy", expires, @"expiry", nil];
			[prefs setObject:newHostelPreferences forKey:[NSString stringWithFormat:@"latestHostelPreferences_%@", user.username]];
			[prefs synchronize];
			[newHostelPreferences release];
			
			hostelLoad = [[Hostels alloc] init];
			hostelLoad.delegate = self;
			
			if ([self.geolocation objectForKey:@"latitude"] && [self.geolocation objectForKey:@"longitude"]) {
				[hostelLoad loadHostelsForArea:[self.area objectForKey:@"name"] country:self.realCountryName latitide:[self.geolocation objectForKey:@"latitude"] longitude:[self.geolocation objectForKey:@"longitude"] within:[NSNumber numberWithDouble:2.5] page:[NSNumber numberWithInt:0] orderedBy:[NSNumber numberWithInt:HOSTELS_ORDER_DEFAULT]];
			}
			else {
				[hostelLoad loadHostelsForArea:[self.area objectForKey:@"name"] country:self.realCountryName within:[NSNumber numberWithDouble:2.5] page:[NSNumber numberWithInt:0] orderedBy:[NSNumber numberWithInt:HOSTELS_ORDER_DEFAULT]];
			}
			
			HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
			[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
			HUD.delegate = self;
			HUD.labelText = @"Searching For Hostels...";
			[HUD show:YES];
		}
	}
	else {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Unable to Search For Hostels"
								  message:@"We were unable to connect to Off Exploring to search for hostels. Please try again!"
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
}

#pragma mark HostelLoader Delegate Methods
- (void)hostelLoader:(Hostels *)hostelLoader didLoadHostelsforCity:(NSString *)city country:(NSString *)country latitude:(double)latitude longitude:(double)longitude range:(double)range page:(int)page {
	[HUD hide:YES];
	[hostelLoad release];
	[self performSelector:@selector(hostelsLoaded) withObject:nil afterDelay:0.5];
}

- (void)hostelLoader:(Hostels *)hostelLoader failedToLoadHostelsforCity:(NSString *)city country:(NSString *)country latitude:(double)latitude longitude:(double)longitude range:(double)range page:(int)page {
	if (range < 20) {
		double currentDistance = range * 2;
		[hostelLoad loadHostelsForArea:city country:country latitide:[NSNumber numberWithDouble:latitude] longitude:[NSNumber numberWithDouble:longitude] within:[NSNumber numberWithDouble:currentDistance]  page:[NSNumber numberWithInt:page] orderedBy:[NSNumber numberWithInt:HOSTELS_ORDER_DEFAULT]];
	}
	else {
		[HUD hide:YES];
		[hostelLoad release];
		UIAlertView *charAlert = [[[UIAlertView alloc]
								   initWithTitle:@"No Hostels"
								   message:@"There are no hostels near this location!"
								   delegate:nil
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil] autorelease];
		[charAlert show];
	}
}

- (void)noConnectionforHostelLoader:(Hostels *)hostelLoader {
	[HUD hide:YES];
	[hostelLoad release];
	UIAlertView *charAlert = [[UIAlertView alloc]
							  initWithTitle:@"Unable to Search For Hostels"
							  message:@"We were unable to connect to Off Exploring to search for hostels. Please try again!"
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	[charAlert show];
	
	
}

- (void)hostelsLoaded {
	[hostelDelegate hostelSearchViewController:self didLoadHostelsForCountry:self.realCountryName withArea:[self.area objectForKey:@"name"]];
}

#pragma mark MapViewController Delegate Method
/**
	MapViewController Delegate Method over-ridden to set appropraite fields for search
	@param mvc The MapViewController used for search
	@param xords The returned Co-ordinates
 */
- (void)mapViewController:(MapViewController *)mvc didFinishWithXords:(NSDictionary *)xords {
	[super mapViewController:mvc didFinishWithXords:xords];
}

#pragma mark UITableView Delegate and Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 1 && !showRatings) {
		return 4;
	}
	else if (section == 1 && showRatings) {
		return 13;
	}
	else {
		return 1;
	}
}

// Set the header hight for the page
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 1) {
		return 40.0;
	}
	else {
		return 0;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 0) {
		return 30.0;
	}
	else {
		return 0;
	}
}


// Build the header label for the page
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == 1) {
		
		UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
		
		UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 300, 50)];
		headerLabel.text = @"Sort By";
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.textAlignment = NSTextAlignmentLeft;
		headerLabel.textColor = [UIColor colorWithRed: 124/255.0 green: 107/255.0 blue: 77/255.0 alpha:1.0];
		headerLabel.font = [ UIFont boldSystemFontOfSize: 14];
		headerLabel.shadowColor = [UIColor whiteColor];
		headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		
		[customView addSubview: headerLabel];
		
		return customView;
	}
	else {
		return nil;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 0) {
		UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
		
		UILabel *locationTitleLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 150, 50)];
		locationTitleLabel.text = @"Selected Location:";
		locationTitleLabel.backgroundColor = [UIColor clearColor];
		locationTitleLabel.font = [UIFont systemFontOfSize:14];
		locationTitleLabel.textColor = [UIColor darkGrayColor];
		[customView addSubview:locationTitleLabel];

		UILabel *locationLabel = [[UILabel alloc] initWithFrame: CGRectMake(140, 0, 160, 50)];
		locationLabel.text = [self.area objectForKey:@"name"];
		locationLabel.backgroundColor = [UIColor clearColor];
		locationLabel.font = [UIFont boldSystemFontOfSize:14];
		locationLabel.textColor = [UIColor darkGrayColor];
		//locationLabel.textAlignment = NSTextAlignmentRight;
		[customView addSubview:locationLabel];
		
		return customView;
	}
	else {
		return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 1) {
		BlogDetailTableViewCell *cell = (BlogDetailTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
		if (cell == nil) {
			NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogDetailTableViewCell" owner:nil options:nil];
			for (id currentObject in nibObjects) {
				if ([currentObject isKindOfClass:[BlogDetailTableViewCell class]]) {
					cell = (BlogDetailTableViewCell *)currentObject;
				}
			}
		}
        
        if (cell.detail) {
            cell.detail.text = @"";
        }
        
        if (cell.label) {
            cell.label.frame = CGRectMake(cell.label.frame.origin.x, cell.label.frame.origin.y, 200, cell.label.frame.size.height);
            
            if (indexPath.row == HOSTELS_ORDER_SHAREDPRICE) {
                cell.label.text = @"Shared Price";
                if (searchMode == HOSTELS_ORDER_SHAREDPRICE) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.label.textColor = [UIColor colorWithRed: 50.0/255.0 green:79.0/255.0 blue:133.0/255.0 alpha:1.0];
                }
            }
            else if (indexPath.row == HOSTELS_ORDER_PRIVATEPRICE) {
                cell.label.text = @"Private Price";
                if (searchMode == HOSTELS_ORDER_PRIVATEPRICE) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.label.textColor = [UIColor colorWithRed: 50.0/255.0 green:79.0/255.0 blue:133.0/255.0 alpha:1.0];
                }
            }
            else if (indexPath.row == HOSTELS_ORDER_DISTANCE) {
                cell.label.text = @"Distance";
                if (searchMode == HOSTELS_ORDER_DISTANCE) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.label.textColor = [UIColor colorWithRed: 50.0/255.0 green:79.0/255.0 blue:133.0/255.0 alpha:1.0];
                }
            }
            else if (indexPath.row == HOSTELS_ORDER_OVERALL) {
                cell.label.text = @"Rating";
                if (searchMode >= HOSTELS_ORDER_OVERALL) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.label.textColor = [UIColor colorWithRed: 50.0/255.0 green:79.0/255.0 blue:133.0/255.0 alpha:1.0];
                }
            }
            else if (indexPath.row == HOSTELS_ORDER_OVERALL + 1) {
                cell.label.text = @"Overall";
                cell.label.frame = CGRectMake(40, 10, cell.label.frame.size.width, cell.label.frame.size.height);
                cell.label.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                cell.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                if (searchMode == HOSTELS_ORDER_OVERALL) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            else if (indexPath.row == HOSTELS_ORDER_ATMOSPHERE + 1) {
                cell.label.text = @"Atmosphere";
                cell.label.frame = CGRectMake(40, 10, cell.label.frame.size.width, cell.label.frame.size.height);
                cell.label.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                cell.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                if (searchMode == HOSTELS_ORDER_ATMOSPHERE) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            else if (indexPath.row == HOSTELS_ORDER_STAFF + 1) {
                cell.label.text = @"Staff";
                cell.label.frame = CGRectMake(40, 10, cell.label.frame.size.width, cell.label.frame.size.height);
                cell.label.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                cell.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                if (searchMode == HOSTELS_ORDER_STAFF) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            else if (indexPath.row == HOSTELS_ORDER_LOCATION + 1) {
                cell.label.text = @"Location";
                cell.label.frame = CGRectMake(40, 10, cell.label.frame.size.width, cell.label.frame.size.height);
                cell.label.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                cell.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                if (searchMode == HOSTELS_ORDER_LOCATION) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            else if (indexPath.row == HOSTELS_ORDER_CLEANLINESS + 1) {
                cell.label.text = @"Cleanliness";
                cell.label.frame = CGRectMake(40, 10, cell.label.frame.size.width, cell.label.frame.size.height);
                cell.label.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                cell.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                if (searchMode == HOSTELS_ORDER_CLEANLINESS) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            else if (indexPath.row == HOSTELS_ORDER_FACILITIES + 1) {
                cell.label.text = @"Facilities";
                cell.label.frame = CGRectMake(40, 10, cell.label.frame.size.width, cell.label.frame.size.height);
                cell.label.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                cell.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                if (searchMode == HOSTELS_ORDER_FACILITIES) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            else if (indexPath.row == HOSTELS_ORDER_SAFETY + 1) {
                cell.label.text = @"Safety";
                cell.label.frame = CGRectMake(40, 10, cell.label.frame.size.width, cell.label.frame.size.height);
                cell.label.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                cell.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                if (searchMode == HOSTELS_ORDER_SAFETY) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            else if (indexPath.row == HOSTELS_ORDER_FUN + 1) {
                cell.label.text = @"Fun";
                cell.label.frame = CGRectMake(40, 10, cell.label.frame.size.width, cell.label.frame.size.height);
                cell.label.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                cell.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                if (searchMode == HOSTELS_ORDER_FUN) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            else if (indexPath.row == HOSTELS_ORDER_VALUE + 1) {
                cell.label.text = @"Value";
                cell.label.frame = CGRectMake(40, 10, cell.label.frame.size.width, cell.label.frame.size.height);
                cell.label.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                cell.backgroundColor = [UIColor colorWithRed: 250/255.0 green:245.0/255.0 blue:232.0/255.0 alpha:1.0];
                if (searchMode == HOSTELS_ORDER_VALUE) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }

        }
				
		return cell;
	}
	else {
		return [super tableView:self.tableView cellForRowAtIndexPath:indexPath];
	}
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 1) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		for (int i=0; i<13;i++) {
			if (i != indexPath.row) {
				NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:1];
				BlogDetailTableViewCell *cell = (BlogDetailTableViewCell *)[self.tableView cellForRowAtIndexPath:newIndexPath];
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.label.textColor = [UIColor colorWithRed: 63.0/255.0 green:63.0/255.0 blue:63.0/255.0 alpha:1.0];
			}
		}
		
		if (indexPath.row > HOSTELS_ORDER_OVERALL) {
			searchMode = indexPath.row - 1;
			BlogDetailTableViewCell *cell = (BlogDetailTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:HOSTELS_ORDER_OVERALL inSection:indexPath.section]];
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			cell.label.textColor = [UIColor colorWithRed: 50.0/255.0 green:79.0/255.0 blue:133.0/255.0 alpha:1.0];
		} 
		else {
			searchMode = indexPath.row;
		}
		
		BlogDetailTableViewCell *cell = (BlogDetailTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.label.textColor = [UIColor colorWithRed: 50.0/255.0 green:79.0/255.0 blue:133.0/255.0 alpha:1.0];
		
		if (indexPath.row == HOSTELS_ORDER_OVERALL && showRatings == NO) {
			showRatings = YES;
			NSArray *array = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:HOSTELS_ORDER_OVERALL + 1 inSection:1],
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_ATMOSPHERE + 1 inSection:1], 
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_STAFF + 1 inSection:1], 
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_LOCATION + 1 inSection:1],
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_CLEANLINESS + 1 inSection:1],
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_FACILITIES + 1 inSection:1],
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_SAFETY + 1 inSection:1],
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_FUN + 1 inSection:1],
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_VALUE + 1 inSection:1],
							  nil];
			[self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationBottom];
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:HOSTELS_ORDER_VALUE + 1 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
		}
		else if (indexPath.row < HOSTELS_ORDER_OVERALL && showRatings == YES){
			showRatings = NO;
			NSArray *array = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:HOSTELS_ORDER_OVERALL + 1 inSection:1],
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_ATMOSPHERE + 1 inSection:1], 
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_STAFF + 1 inSection:1], 
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_LOCATION + 1 inSection:1],
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_CLEANLINESS + 1 inSection:1],
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_FACILITIES + 1 inSection:1],
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_SAFETY + 1 inSection:1],
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_FUN + 1 inSection:1],
							  [NSIndexPath indexPathForRow:HOSTELS_ORDER_VALUE + 1 inSection:1],
							  nil];
			[self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
		}
	}
	else {
		return [super tableView:self.tableView didSelectRowAtIndexPath:indexPath];
	}
}

#pragma mark MBProgressHUD Delegate Method
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
}

@end
