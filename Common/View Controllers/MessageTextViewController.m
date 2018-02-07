//
//  MessageTextViewController.m
//  Off Exploring
//
//  Created by Ian Outterside on 07/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import "MessageTextViewController.h"
#import "MessageTextTableViewCell.h"
#import "User.h"
#import "OffexConnex.h"
#import "OFXMessage.h"
#import "MBProgressHUD.h"
#import "MessageEntryView.h"
#import <QuartzCore/QuartzCore.h>

#define NAVBAR_TAG 99999

@interface MessageTextViewController() <OffexploringConnectionDelegate, MessageEntryViewDelegate, MBProgressHUDDelegate>
@property (nonatomic, strong) MessageEntryView *messageEntryView;
@property (nonatomic, strong) Trip *activeTrip;
@property (nonatomic, strong) MBProgressHUD *HUD;

- (void)sendMessage:(NSString *)message;
- (void)deleteMessage:(id <MessageTextMessage>)aMessage;
- (void)showSendingHUDMessage;
- (void)showDeleteingHUDMessage;
- (void)hideHUD;

@end

@implementation MessageTextViewController
@synthesize tableView = _tableView;
@synthesize messages = _messages;
@synthesize messageEntryView = _messageEntryView;
@synthesize activeTrip;
@synthesize HUD;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Messages";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // If not a navigation controller, add a nav bar
    if (!self.navigationController) {
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + 20, self.view.bounds.size.width, 44)];
        navBar.tag = NAVBAR_TAG;
        navBar.barStyle = UIBarStyleBlack;
        
        self.view.backgroundColor = [UIColor blackColor];
        //navBar.tintColor = [UIColor navBarColor];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed:)];
        self.navigationItem.leftBarButtonItem = backButton;
        
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Comments"];
        item.leftBarButtonItem = backButton;
        item.hidesBackButton = YES;
        [navBar pushNavigationItem:item animated:NO];
        
        [self.view addSubview:navBar];
        
        self.tableView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + 20 +navBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - 44 -  navBar.frame.size.height);
    }
    
    MessageEntryView *view = [[MessageEntryView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    view.delegate = self;
    [view.submitButton addTarget:self action:@selector(sendMessagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:view];
    self.messageEntryView = view;
}

- (void)viewDidUnload
{
    [[self.view viewWithTag:NAVBAR_TAG] removeFromSuperview];
    [self setMessageEntryView:nil];
    
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)backButtonPressed:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageTextViewControllerDidFinish:)]) {
        [self.delegate messageTextViewControllerDidFinish:self];
    }
    
}

- (void)sendMessagePressed:(id)sender {
    
    NSString *message = self.messageEntryView.textView.text;
    
    if ([message isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Empty Message" 
                                                             message:@"You have not entered any message text." 
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK" 
                                                   otherButtonTitles:nil];
        
        [alertView show];
    }
    else {
        self.messageEntryView.showsSubmitButton = NO;
        
        CGFloat minOffset;
        CGFloat maxHeight;
        if ([self.view viewWithTag:NAVBAR_TAG]) {
            minOffset = 44 + 20;
            maxHeight = 88 - 20;
        }
        else {
            minOffset = 0;
            maxHeight = 44 - 20;
        }
        
        [UIView beginAnimations:@"Resize" context:NULL];
        [UIView setAnimationDuration:0.25];
        self.messageEntryView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
        self.tableView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + minOffset, self.view.bounds.size.width, self.view.bounds.size.height - maxHeight);
        [self.messageEntryView.textView resignFirstResponder];
        [self.messageEntryView setNeedsDisplay];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        [UIView setAnimationDidStopSelector:@selector(showSendingHUDMessage)];
        [UIView setAnimationDelegate:self];
        [UIView commitAnimations];
        
        [self sendMessage:self.messageEntryView.textView.text];
    }
}

- (void)messageEntryViewWasTouched:(MessageEntryView *)messageEntryView {
    
    if (!self.messageEntryView.showsSubmitButton)  {
        self.messageEntryView.showsSubmitButton = YES;
        
        if (![self.messageEntryView.textView isFirstResponder]) {
            [self.messageEntryView.textView becomeFirstResponder];
        }
        
        [UIView beginAnimations:@"Resize" context:NULL];
        [UIView setAnimationDuration:0.25];
        
        if ([self.messageEntryView.textView.text isEqualToString:@"Write a reply..."] || [self.messageEntryView.textView.text isEqualToString:@"Write a message..."] || [self.messageEntryView.textView.text isEqualToString:@"Write a comment..."]) {
            self.messageEntryView.textView.text = @"";
            self.messageEntryView.textView.textColor = [UIColor darkGrayColor];
        }
        
        [self.messageEntryView resizeViewsForText];
        
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - 216);
        [UIView commitAnimations];
    }
}

- (void)tableView:(UITableView *)tableView wasTouchedWithTouches:(NSSet *)touches andEvent:(UIEvent *)event {
    if ([self.messageEntryView.textView isFirstResponder]) {
        if ([self.messageEntryView.textView.text isEqualToString:@""]) {
            if ([self.messages count] > 0) {
                self.messageEntryView.textView.text = @"Write a reply...";
            }
            else if ([self.title isEqualToString:@"Messages"]) {
                self.messageEntryView.textView.text = @"Write a message...";
            }
            else {
                self.messageEntryView.textView.text = @"Write a comment...";
            }
            self.messageEntryView.textView.textColor = [UIColor lightGrayColor];
        }
        
        self.messageEntryView.showsSubmitButton = NO;
        self.messageEntryView.previousTextSize = CGSizeZero;
        [UIView beginAnimations:@"Resize" context:NULL];
        [UIView setAnimationDuration:0.25];
        [self.messageEntryView resizeViewsForText];
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height + 216);
        [UIView commitAnimations];
        [self.messageEntryView.textView resignFirstResponder];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.messages count] > 0) {
        self.messageEntryView.textView.text = @"Write a reply...";
        return [_messages count];
    }
    else if ([self.title isEqualToString:@"Messages"]) {
        self.messageEntryView.textView.text = @"Write a message...";
        return 1;
    }
    else {
        self.messageEntryView.textView.text = @"Write a comment...";
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.messages count] > 0) {
        
        id <MessageTextMessage> message = _messages[indexPath.row];
        
        CGSize bodySize = [[message body] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(320 - 52 - 60, CGFLOAT_MAX)];
        
        if ((30 + bodySize.height) >= 61) {
            return (bodySize.height + 30);
        }
        else {
            return 61;
        }
        
    }
    else {
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"messageCell";
    
    if ([self.messages count] > 0) {
        MessageTextTableViewCell *cell = (MessageTextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[MessageTextTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell setMessage:_messages[indexPath.row]];
        
        return cell;
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        
        if ([self.title isEqualToString:@"Messages"]) {
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, cell.contentView.bounds.size.width - 75, 60)];
            label.text = @"Use this screen to view & reply to any messages posted on your blog";
            label.textColor = [UIColor lightGrayColor];
            label.font = [UIFont systemFontOfSize:14];
            label.numberOfLines = 0;
            //label.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:label];
        }
        else {
            cell.detailTextLabel.text = @"There are no comments for this yet...";
        }
        
        cell.imageView.image = [UIImage imageNamed:@"exclamation.png"];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.messages count] > 0) {
        id <MessageTextMessage> aMessage = _messages[indexPath.row];
        [self showDeleteingHUDMessage];
        [self deleteMessage:aMessage];
    }
}

- (void)loadMessagesForTrip:(Trip *)trip {
    self.activeTrip = trip;
    User *user = [User sharedUser];
	OffexConnex *connex = [[OffexConnex alloc] init];
	connex.delegate = self;
	NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/trip/%@/message", user.username, trip.urlSlug]];
	[connex beginLoadingOffexploringDataFromURL:url];
}

- (void)sendMessage:(NSString *)message {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendMessage:)]) {
        [self.delegate sendMessage:message];
    }
    else {
        User *user = [User sharedUser];
        NSDictionary *dict = @{@"guestname": user.username, @"body": message, @"email": @""};
        
        OffexConnex *connex = [[OffexConnex alloc] init];
        connex.delegate = self;
        NSData *bodyText = [connex paramaterBodyForDictionary:dict];
        NSString *contentMode = @"application/x-www-form-urlencoded";
        NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/trip/%@/message",user.username, activeTrip.urlSlug]];
        [connex postOffexploringData:bodyText withContentMode:contentMode toURL:url];
    }
}

- (void)deleteMessage:(id <MessageTextMessage>)aMessage {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteMessage:)]) {
        [self.delegate deleteMessage:aMessage];
    }
    else {
        OffexConnex *connex = [[OffexConnex alloc] init];
        connex.delegate = self;
        
        User *user = [User sharedUser];
        NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/trip/%@/message/%@", user.username, activeTrip.urlSlug, aMessage.messageId]];
        [connex deleteOffexploringDataAtUrl:url];
    }
}

- (void)showSendingHUDMessage {
    HUD = [[MBProgressHUD alloc] initWithView:self.tableView];
	[self.tableView addSubview:HUD];
    HUD.delegate = self;
	HUD.labelText = @"Sending...";
	[HUD show:YES];
}

- (void)showDeleteingHUDMessage {
    HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
    [[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Deleting...";
    [HUD show:YES];
}

- (void)hideHUDMessage {
    
    if (!HUD) {
        [self performSelector:@selector(hideHUD) withObject:nil afterDelay:0.5];
    }
    else {
        [self hideHUD];
    }
    
}

- (void)hideHUD {
    [HUD hide:YES];
}

#pragma mark OffexploringConnection Delegate
- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
    
    if (([results[@"request"][@"method"] isEqualToString:@"DELETE"])  && results[@"response"][@"success"] && [results[@"response"][@"success"] isEqualToString:@"true"]) {
        
        [HUD hide:YES];
        
        NSNumber *messageId = @([results[@"request"][@"params"][@"param"][2] intValue]);
        
        if ([self.messages count] == 1) {
            self.messages = @[];
            [self.tableView reloadData];
        }
        else {
            
            [self.tableView beginUpdates];
            
            NSMutableArray *messageArray = [self.messages mutableCopy];
            
            int count = 0;
            for (id <MessageTextMessage> aMessage in messageArray) {
                if ([aMessage.messageId isEqualToNumber:messageId]) {
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                    [messageArray removeObject:aMessage];
                    break;
                }
                count++;
            }
            
            self.messages = messageArray;
            
            [self.tableView endUpdates];
            
        }
    }
    // Sending a message
    else if (results[@"response"][@"message"]) {
        [HUD hide:YES];
        
        // Animate adding the message
        OFXMessage *newMessage = [[OFXMessage alloc] initWithDictionary:results[@"response"][@"message"][0]];
        
        if ([self.messages count] == 0) {
            self.messages = @[newMessage];
            [self.tableView reloadData];
        }
        else {
        
            [self.tableView beginUpdates];
            
            NSMutableArray *messagesArray = [self.messages mutableCopy];
            [messagesArray insertObject:newMessage atIndex:0];
            self.messages = messagesArray;
            
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            
            [self.tableView endUpdates];
            
        }
        [self resetView];
    }
    // Downloading messages
    else {
        // exit early if no messages;
        if ([results[@"response"][@"messages"] isEqual:[NSNull null]]) {
            return;
        }
        
        NSMutableArray *downloadedMessages = [[NSMutableArray alloc] initWithCapacity:[results[@"response"][@"messages"][@"message"] count]];
        
        for (NSDictionary *data in results[@"response"][@"messages"][@"message"]) {
            OFXMessage *aMessage = [[OFXMessage alloc] initWithDictionary:data];
            [downloadedMessages addObject:aMessage];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor];
        self.messages = [downloadedMessages sortedArrayUsingDescriptors:sortDescriptors];
        [self.tableView reloadData];
    }
}

- (void)resetView {
    if ([self.messages count] > 0) {
        self.messageEntryView.textView.text = @"Write a reply...";
    }
    else if ([self.title isEqualToString:@"Messages"]) {
        self.messageEntryView.textView.text = @"Write a message...";
    }
    else {
        self.messageEntryView.textView.text = @"Write a comment...";
    }
    self.messageEntryView.textView.textColor = [UIColor lightGrayColor];
    [self.messageEntryView resizeViewsForText];
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *)error {
    [HUD hide:YES];
	
	UIAlertView *charAlert = nil;
	
	if ([[error userInfo][@"results"][@"status"][@"errormessage"] isEqualToString:@"site_read_only_enabled"]) {
		
		charAlert = [[UIAlertView alloc]
					 initWithTitle:@"Error Communicating With Off Exploring, please retry"
					 message:[error localizedDescription]
					 delegate:nil
					 cancelButtonTitle:@"OK"
					 otherButtonTitles:nil];
		
	}
	else {
        
		charAlert = [[UIAlertView alloc]
					 initWithTitle:@"Off Exploring Connection Error"
					 message:@"An error has occured sending to Off Exploring. Please retry."
					 delegate:nil
					 cancelButtonTitle:@"OK"
					 otherButtonTitles:nil];
		
	}
    
    [charAlert show];
    
}

#pragma mark MBProgressHUD Delegate Methods
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
	HUD = nil;
}

@end
