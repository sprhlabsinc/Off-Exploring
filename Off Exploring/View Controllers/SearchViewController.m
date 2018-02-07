//
//  SearchViewController.m
//  Off Exploring
//
//  Created by Ian Outterside on 26/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "Constants.h"
#import "OFXWebViewController.h"
#import "OFXNavigationBar.h"
#import "OffexConnex.h"

@interface SearchViewController()

- (void)searchButtonPressed:(UIButton *)aButton;

@end

@implementation SearchViewController

@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background]]];
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor tableViewSeperatorColor];
}

- (void)viewDidUnload
{
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 300, 50)];
    headerLabel.text = @"Search for...";
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
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 2) {
        return 140.0;    
    }
    else {
        return  44.0;  
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"SearchCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    
    // Reset cell;
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    cell.textLabel.text = @"";
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0 || indexPath.row == 1) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 22)];
        label.textColor = [UIColor darkTextColor];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0, 1);
        label.font = [UIFont systemFontOfSize:17];
        label.backgroundColor = [UIColor clearColor];
        
        if (indexPath.row == 0) {
            label.text = @"Blogs from:";
        }
        else {
            label.text = @"A blogger:";
        }
        
        [cell.contentView addSubview:label];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 42, 280, 31)];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.backgroundColor = [UIColor colorWithRed:241.0f/255.0f green:241.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
        textField.tag = indexPath.row;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.delegate = self;
        
        if (indexPath.row == 0) {
            textField.placeholder = @"e.g. Paris";
        }
        else {
            textField.placeholder = @"e.g. joebloggs or Joe Bloggs";
        }
        
        [cell.contentView addSubview:textField];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"greenButton.png"] forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 83, 300, 53);
        [button setTitle:@"Search" forState:UIControlStateNormal];
        button.titleLabel.shadowColor = [UIColor headerLabelShadowColor];
        button.titleLabel.shadowOffset = CGSizeMake(0, 1);
        button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        button.tag = indexPath.row;
        [button addTarget:self action:@selector(searchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"Browse all blogs";
        cell.textLabel.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        // remove constant
        NSURL *url = [NSURL URLWithString:@"http://www.offexploring.com/search/browse"];
        OFXWebViewController *controller = [[OFXWebViewController alloc] initWithNibName:nil bundle:nil requestURL:url];
        OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigationController.navigationBar;
        [navBar setLogoHidden:NO];
        [self.navigationController pushViewController:controller animated:YES];
        
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    float height = IS_WIDESCREEN ? 288 : 200;
    
    if (self.tableView.frame.size.height != height) {
        
        NSLog(@"size: %.f", self.tableView.frame.size.height);
        
        [UIView beginAnimations:[NSString stringWithFormat:@"%d", textField.tag] context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, height);
        [UIView commitAnimations];
        
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    int row = [animationID intValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]];
    
    UIButton *button = nil;
    
    for (UIView *aView in cell.contentView.subviews) {
        if ([aView isKindOfClass:[UIButton class]]) {
            button = (UIButton *)aView;
        }
    }
    
    [self searchButtonPressed:button];
    
    return YES;
}

- (void)searchButtonPressed:(UIButton *)aButton {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:aButton.tag inSection:0]];
    
    UITextField *textField = nil;
    
    for (UIView *aView in cell.contentView.subviews) {
        if ([aView isKindOfClass:[UITextField class]]) {
            textField = (UITextField *)aView;
        }
    }
    
    NSString *searchText = textField.text;
    
    OffexConnex *connex = [[OffexConnex alloc] init];
    NSString *escapedText = [connex urlEncodeValue:searchText];
    
    NSURL *url = nil;
    
    if (aButton.tag == 0) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.offexploring.com/search/place/%@", escapedText]];
    }
    else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.offexploring.com/search/name/%@", escapedText]];
    }
    
    OFXWebViewController *controller = [[OFXWebViewController alloc] initWithNibName:nil bundle:nil requestURL:url];
    OFXNavigationBar *navBar = (OFXNavigationBar *)self.navigationController.navigationBar;
    [navBar setLogoHidden:NO];
    [self.navigationController pushViewController:controller animated:YES];
    
}


@end
