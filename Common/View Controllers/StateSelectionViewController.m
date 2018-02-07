//
//  StateSelectionViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 29/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#pragma mark -
#pragma mark NSObject (CategorySort) Implementation
/**
	Category provides a custom sort function for listing countries
*/
@implementation NSObject (CategorySort)

- (NSComparisonResult)compareAccordingToValue:(id)anObject
{
	if ([self isKindOfClass:[NSString class]]) {
		NSString *string = (NSString *)self;
		
		if ([anObject isKindOfClass:[NSString class]]) {
			return [string caseInsensitiveCompare:anObject];
		}
		else if ([anObject isKindOfClass:[NSDictionary class]]) {
			return [string caseInsensitiveCompare:[anObject allKeys][0]];
		}
	}
	else if ([self isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dict = (NSDictionary *)self;
		NSString *string = [dict allKeys][0];
		
		if ([anObject isKindOfClass:[NSString class]]) {
			return [string caseInsensitiveCompare:anObject];
		}
		else if ([anObject isKindOfClass:[NSDictionary class]]) {
			return [string caseInsensitiveCompare:[anObject allKeys][0]];
		}
	}
	
	return NSOrderedSame;
}

@end

#import "StateSelectionViewController.h"
#import "Constants.h"

#pragma mark -
#pragma mark StateSelectionViewController Private Interface
/**
 @brief Private accessors used to for accessing UITableViewCells and the states they encapuslate
 
 This interface provides private accessors used to for accessing UITableViewCells and the states 
 they encapuslate
 */
@interface StateSelectionViewController()

@property (nonatomic, strong) NSArray *dictionaryKeys;
@property (nonatomic, strong) NSString *stateName;

@end

#pragma mark -
#pragma mark StateSelectionViewController Implementation
@implementation StateSelectionViewController

@synthesize stateList;
@synthesize stateName;
@synthesize delegate;
@synthesize preLoaded;
@synthesize navBar;
@synthesize dictionaryKeys;

#pragma mark UIViewController Methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	if ([delegate respondsToSelector:@selector(titleForStateSelectionViewController:wasPreloaded:)] == YES) {
		self.navBar.topItem.title = [delegate titleForStateSelectionViewController:self wasPreloaded:self.preLoaded];
	}
	
	if (stateList == nil) {
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"states" ofType:@"plist"];
		stateList = [NSDictionary dictionaryWithContentsOfFile:plistPath];
		self.preLoaded = NO;
	}
	else {
		self.preLoaded = YES;
	}
	
	dictionaryKeys = [stateList keysSortedByValueUsingSelector:@selector(compareAccordingToValue:)];
	
	NSMutableSet *setOfSectionIndexTitles = [[NSMutableSet alloc] init];
	
	NSString *aPlaceCode;
	
	for (aPlaceCode in dictionaryKeys) {
		if ([stateList[aPlaceCode] isKindOfClass:[NSString class]]) {
			NSString *indexTitle = stateList[aPlaceCode];
			NSString *firstLetter = [indexTitle substringToIndex:1]; 
			[setOfSectionIndexTitles addObject:firstLetter];
		}
		else {
			NSString *indexTitle = [stateList[aPlaceCode] allKeys][0];
			NSString *firstLetter = [indexTitle substringToIndex:1]; 
			[setOfSectionIndexTitles addObject:firstLetter];
		}
	}
	NSArray *unsortedTitles = [[NSArray alloc] initWithArray:[setOfSectionIndexTitles allObjects]];
	sectionIndexTitles = [unsortedTitles sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	rowNumbers = [[NSMutableDictionary alloc] init];
	
	[super viewDidLoad];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.navBar = nil;
}

#pragma mark IBActions
- (IBAction)cancel {
	[delegate stateSelectionViewControllerDidCancel:self];
}

#pragma mark UITableView Delegate and Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sectionIndexTitles count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 22.0)];
	header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"divider.png"]];
	UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 0, 300, 20)];
	headerLabel.text = sectionIndexTitles[section];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.textAlignment = NSTextAlignmentLeft;
	headerLabel.font = [UIFont boldSystemFontOfSize: 13];
	headerLabel.textColor = [UIColor headerLabelTextColorPlainStyle];
	headerLabel.shadowColor = [UIColor headerLabelShadowColorPlainStyle];
	headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	[header addSubview: headerLabel];
	return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *theFirstLetter = sectionIndexTitles[section];
	
	NSString *aPlaceCode;
	int arrayindex = 0;
	int count = 0;
	runningTotal = 0;
	BOOL found = NO;
	for (aPlaceCode in dictionaryKeys) {
		if ([stateList[aPlaceCode] isKindOfClass:[NSString class]]) {
			NSString *indexTitle = stateList[aPlaceCode];
			NSString *firstLetter = [indexTitle substringToIndex:1]; 
			if ([firstLetter isEqualToString:theFirstLetter]) {
				count = count +1;
				found = YES;
			}
			if (found == NO) {
				runningTotal = runningTotal +1;
			}
			arrayindex = arrayindex +1;
		}
		else {
			NSString *indexTitle = [stateList[aPlaceCode] allKeys][0];
			NSString *firstLetter = [indexTitle substringToIndex:1]; 
			if ([firstLetter isEqualToString:theFirstLetter]) {
				count = count +1;
				found = YES;
			}
			if (found == NO) {
				runningTotal = runningTotal +1;
			}
			arrayindex = arrayindex +1;
		}
	}
	rowNumbers[theFirstLetter] = @(runningTotal);
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *reuseIdentifier = @"generalCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	}
	
	NSString *theFirstLetter = sectionIndexTitles[indexPath.section];
	int theTotalToLoop = [rowNumbers[theFirstLetter] intValue];
	
	NSString *key = dictionaryKeys[(theTotalToLoop + indexPath.row)];
	
	if ([stateList[key] isKindOfClass:[NSString class]]) {
		cell.textLabel.text = stateList[key];
	}
	else {
		cell.textLabel.text = [stateList[key] allKeys][0];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *theFirstLetter = sectionIndexTitles[indexPath.section];
	int theTotalToLoop = [rowNumbers[theFirstLetter] intValue];
	
	NSString *key = dictionaryKeys[(theTotalToLoop + indexPath.row)];
	stateName = stateList[key];
	NSDictionary *returnDict = [[NSDictionary alloc] initWithObjectsAndKeys:stateName, key, @(self.preLoaded), @"preLoaded", nil];
	
	[delegate stateSelectionViewController:self didFinishSelectingState:returnDict];
}

@end
