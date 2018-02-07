//
//  AboutUsViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 30/09/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "AboutUsViewController.h"
#import "StringHelper.h"
#import "DB.h"
#import "SystemMessage.h"

#pragma mark -
#pragma mark AboutUsViewController Private Interface
/**
	@brief Private interface providing message array field used to build array and methods to access Messages from DB
 
	This private interface provides accessors to the messageArray that is used to display the system information 
	downloaded from Off Exploring. It provides methods to write to and access from the DB
 */
@interface AboutUsViewController()
#pragma mark Private Method Declarations
/**
	Returns an auto-released array of messages from the database
	@returns The message array
 */
- (NSArray *)loadMessagesFromDB;

@property (nonatomic, strong) NSArray *messageArray;

@end

#pragma mark -
#pragma mark AboutUsViewController Implementation
@implementation AboutUsViewController

@synthesize messageArray;
@synthesize theTableView;

#pragma mark UIViewController Methods

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.title = @"About Us";
		connex = [[OffexConnex alloc] init];
		connex.delegate = self;
		NSString *remoteURI = [connex buildOffexRequestStringWithURI:@"system"];
		[connex beginLoadingOffexploringDataFromURL:remoteURI];
		
		self.messageArray = [self loadMessagesFromDB];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background]]];
	self.theTableView.backgroundColor = [UIColor clearColor];
    if ([UIColor tableViewSeperatorColor]) {
        self.theTableView.separatorColor = [UIColor tableViewSeperatorColor];
    }
	[super viewDidLoad];
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
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark Private Methods
- (NSArray *)loadMessagesFromDB {

	DB *db = [DB sharedDB];
	sqlite3_stmt *select_statement = nil;
	
	NSArray *returnArray = nil;
	
	if (select_statement == nil) {
		const char *sql = "SELECT * FROM system_messages ORDER BY id DESC";
		if (sqlite3_prepare_v2(db.database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
			select_statement = nil;
			//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
		}
	}
	
	if (select_statement != nil) {
		
		NSMutableArray *messages = [[NSMutableArray alloc] init];
		
		while (sqlite3_step(select_statement) == SQLITE_ROW) {
		
			int messageID = sqlite3_column_int(select_statement, 0);
			NSString *messageTitle = @((char *) sqlite3_column_text(select_statement, 1));
			NSString *messageDescription = @((char *) sqlite3_column_text(select_statement, 2));
			NSString *messageLink = @((char *) sqlite3_column_text(select_statement, 3));
			NSDate *messageTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_int(select_statement, 4)];
			
			SystemMessage *message = [[SystemMessage alloc] initWithDBID:messageID title:messageTitle description:messageDescription
																	link:messageLink timestamp:messageTime];
			
			[messages addObject:message];
			
		}
		
		returnArray = [[NSArray alloc] initWithArray:messages];
	}
	
	return returnArray;
}

#pragma mark UITableView Delegate and Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([messageArray count] == 0) {
		return 2;
	}
	return ([messageArray count] +1);
}

// Set the header hight for the page
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
	
	UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 300, 50)];
	
	if ([messageArray count] == 0 && section == 0) {
		headerLabel.text = @"No Messages";
	}
	else if (([messageArray count] == 0 && section == 1) || (section == [messageArray count] && [messageArray count] > 0)) {
		headerLabel.text = @"System Information";
	}
	else {
		SystemMessage *message = messageArray[section];
		headerLabel.text = message.title;
	}
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.textAlignment = NSTextAlignmentLeft;
	headerLabel.textColor = [UIColor headerLabelTextColor];
	headerLabel.font = [ UIFont boldSystemFontOfSize: 14];
	headerLabel.shadowColor = [UIColor headerLabelShadowColor];
	headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	
	[customView addSubview: headerLabel];
	
	return customView;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([messageArray count] == 0 && indexPath.section == 0) {
		return 60;
	}
	else if (([messageArray count] == 0 && indexPath.section == 1) || (indexPath.section == [messageArray count] && [messageArray count] > 0)) {
		return 40;
	}
	else {
		SystemMessage *message = messageArray[indexPath.section];
		return [message.description RAD_textHeightForSystemFontOfSize:15.0] + 20.0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	if ((indexPath.section < [messageArray count]) && [messageArray count] > 0) {
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"generalCell"];
	
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"generalCell"];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		for (UIView *aView in cell.contentView.subviews) {
			[aView removeFromSuperview];
		}
		
		cell.textLabel.text = @"";
		SystemMessage *message = messageArray[indexPath.section];
		UILabel *cellLabel = [message.description RAD_newSizedCellLabelWithSystemFontOfSize:15.0];
		[cell.contentView addSubview:cellLabel];
		
		return cell;
	}
	else {
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"generalCell"];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.textColor = [UIColor darkGrayColor];
		cell.textLabel.text = @"";
		
		if ([messageArray count] == 0 && indexPath.section == 0) {
			
			UILabel *cellLabel = [@"A data connection is required to view this content" RAD_newSizedCellLabelWithSystemFontOfSize:15.0];
			[cell.contentView addSubview:cellLabel];
			return cell;
		}
		else {
						
			NSString *display = [NSString stringWithFormat:@"App Version: %@, Device Version: %@ - %@", 
								 [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"], 
								 [[UIDevice currentDevice] systemName], 
								 [[UIDevice currentDevice] systemVersion]];
			
			cell.textLabel.text = display;
			cell.textLabel.font = [UIFont boldSystemFontOfSize:11];
			
			return cell;
		}
	}
}

#pragma mark Offexploring Connection Delegate Methods

- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {

	if (results[@"response"][@"feed"] != [NSNull null]) {
	
		DB *db = [DB sharedDB];
		sqlite3_exec(db.database, "DELETE FROM system_messages", NULL, NULL, NULL);
		sqlite3_stmt *init_statement = nil;
		const char *sql = "REPLACE INTO system_messages (id, title, description, link, timestamp, imageUrl, imageTitle, imageLink) VALUES (?,?,?,?,?,?,?,?)";
		
		if (sqlite3_prepare_v2(db.database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
			//NSLog (@"PROBLEM - %s", sqlite3_errmsg(db.database));
		}
		
		for (NSDictionary *messageInfo in results[@"response"][@"feed"][@"channel"][@"item"]) {
			
			sqlite3_bind_int(init_statement, 1, [messageInfo[@"id"] intValue]);
			sqlite3_bind_text(init_statement, 2,[messageInfo[@"title"] UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(init_statement, 3,[messageInfo[@"description"] UTF8String], -1, SQLITE_TRANSIENT);
			
			if (messageInfo[@"link"] == [NSNull null]) {
				sqlite3_bind_text(init_statement, 4,[@"NULL" UTF8String], -1, SQLITE_TRANSIENT);
			}
			else {
				sqlite3_bind_text(init_statement, 4,[messageInfo[@"link"] UTF8String], -1, SQLITE_TRANSIENT);
			}
			sqlite3_bind_int(init_statement, 5, [messageInfo[@"pubDate"] intValue]);
			sqlite3_bind_text(init_statement, 6,[@"NULL" UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(init_statement, 7,[@"NULL" UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(init_statement, 8,[@"NULL" UTF8String], -1, SQLITE_TRANSIENT);
			
			
			if (sqlite3_step(init_statement) != SQLITE_DONE) {
				//NSLog(@"Unable to insert message for %d - %s", [[messageInfo objectForKey:@"id"] intValue], sqlite3_errmsg(db.database));
			}
			
			sqlite3_reset(init_statement);
		}
	}
	
	self.messageArray = [self loadMessagesFromDB];
	[self.theTableView reloadData];
}

@end
