//
//  GeneralEditViewController.m
//  KILROY Blogs
//
//  Created by Off Exploring on 22/10/2010.
//  Copyright 2010 KILROY Blogs. All rights reserved.
//

#import "GeneralEditViewController.h"
#import "Constants.h"

@implementation GeneralEditViewController

@synthesize delegate;
@synthesize theTableView;
@synthesize cancelButton;
@synthesize saveButton;
@synthesize navBar;
@synthesize deleteButton;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.title = @"Edit";
		cells = 0;
		editingObject = nil;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *)newTitle cells:(NSUInteger)cellCount editingObject:(id)anObject {
	if (self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = newTitle;
		cells = cellCount;
		editingObject = anObject;
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *)newTitle cells:(NSUInteger)cellCount editingObject:(id)anObject delegate:(id)newDelegate {
	if (self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil title:newTitle cells:cellCount editingObject:anObject]) {
		self.delegate = newDelegate;
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	UINavigationItem *item = (self.navBar.items)[0];
	item.title = self.title;
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background2]]];
	self.theTableView.backgroundColor = [UIColor clearColor];
    if ([UIColor tableViewSeperatorColor]) {
        self.theTableView.separatorColor = [UIColor tableViewSeperatorColor];
    }
	
	if ([delegate respondsToSelector:@selector(deleteButtonShouldDisplayForGeneralEditViewController:editingObject:)]) {
		BOOL enabled = [delegate deleteButtonShouldDisplayForGeneralEditViewController:self editingObject:editingObject];
		
		if (enabled) {
			self.deleteButton.hidden = NO;
		}
		else {
			self.deleteButton.hidden = YES;
		}
	}
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.theTableView = nil;
	self.cancelButton = nil;
	self.saveButton = nil;
	self.navBar = nil;
	self.deleteButton = nil;
}

#pragma mark IBActions
- (IBAction)cancel {
	[delegate generalEditViewControllerDidCancel:self];
}

- (IBAction)save {
	if ([delegate respondsToSelector:@selector(generalEditViewController:canSaveEditingObject:)]) {
		BOOL dismissAble = [delegate generalEditViewController:self canSaveEditingObject:editingObject];
		if (dismissAble) {
			[delegate generalEditViewController:self didEditObject:editingObject];
		}
	}
	else {
		[delegate generalEditViewController:self didEditObject:editingObject];
	}
}

- (IBAction)deleteObject {
	UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:nil
														 delegate:self
												cancelButtonTitle:@"Cancel"
										   destructiveButtonTitle:@"Delete"
												otherButtonTitles:nil];
	[actions showInView:self.view];
	
}

#pragma mark UITableView Delegate and UITableView Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return cells;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellId = @"cellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
		cell.textLabel.textColor = [UIColor darkGrayColor];
	}
	
	if ([delegate respondsToSelector:@selector(labelForEditingObject:forCellAtIndexPath:)]) {
		cell.textLabel.text = [delegate labelForEditingObject:editingObject forCellAtIndexPath:indexPath];
	}
	
	if ([delegate respondsToSelector:@selector(keyForEditingObject:forCellAtIndexPath:)]) {
		NSString *key = [delegate keyForEditingObject:editingObject forCellAtIndexPath:indexPath];
		cell.detailTextLabel.text = [editingObject valueForKey:key];
	}
	
	return cell;	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	editingPath = indexPath;
	
	if ([delegate respondsToSelector:@selector(styleForEditingObject:forCellAtIndexPath:)]) {
		if ([delegate styleForEditingObject:editingObject forCellAtIndexPath:indexPath] == GeneralEditViewControllerPropertyEditingStyleSingle) {
			
			LocationTextViewController *ltvc = [[LocationTextViewController alloc]initWithNibName:nil bundle:nil];
			ltvc.delegate = self;
			
			if ([delegate respondsToSelector:@selector(labelForEditingObject:forCellAtIndexPath:)]) {
				ltvc.title = [delegate labelForEditingObject:editingObject forCellAtIndexPath:indexPath];
			}
			
			if ([delegate respondsToSelector:@selector(keyForEditingObject:forCellAtIndexPath:)]) {
				NSString *key = [delegate keyForEditingObject:editingObject forCellAtIndexPath:indexPath];
				ltvc.area = @{@"name": [editingObject valueForKey:key]};
			}
			
			[self presentViewController:ltvc animated:YES completion:nil];
			
		}
		else if ([delegate styleForEditingObject:editingObject forCellAtIndexPath:indexPath] == GeneralEditViewControllerPropertyEditingStyleBlock) {
			
			BodyTextViewController *btvc = [[BodyTextViewController alloc]initWithNibName:nil bundle:nil];
			btvc.delegate = self;
			
			if ([delegate respondsToSelector:@selector(keyForEditingObject:forCellAtIndexPath:)]) {
				NSString *key = [delegate keyForEditingObject:editingObject forCellAtIndexPath:indexPath];
				btvc.body = [editingObject valueForKey:key];
			}
			
			[self presentViewController:btvc animated:YES completion:nil];
			
		}
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (self.deleteButton.hidden == NO) {
		UIView *returnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
		self.deleteButton.frame = CGRectMake(14, 10, self.deleteButton.frame.size.width, self.deleteButton.frame.size.height);
		[returnView addSubview:self.deleteButton];
		return returnView;
	}
	else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (self.deleteButton.hidden == NO) {
		return 50;
	}
	else {
		return 0;
	}
}

#pragma mark LocationTextViewController Delegate Methods
- (void)locationTextViewController:(LocationTextViewController *)ltvc withTitle:(NSString *)title didFinishEditingLocation:(NSDictionary *)location {
	
	if ([delegate respondsToSelector:@selector(keyForEditingObject:forCellAtIndexPath:)]) {
		NSString *key = [delegate keyForEditingObject:editingObject forCellAtIndexPath:editingPath];
		[editingObject setValue:location[@"name"] forKey:key];
	}
	
	editingPath = nil;
	
	[self.theTableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationTextViewControllerDidCancel:(LocationTextViewController *)ltvc {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)labelForLocationTextViewController:(LocationTextViewController *)ltvc {
	if ([delegate respondsToSelector:@selector(labelForEditingObject:forCellAtIndexPath:)]) {
		return [delegate labelForEditingObject:editingObject forCellAtIndexPath:editingPath];
	}
	else {
		return nil;
	}
}

#pragma mark BodyTextViewController Delegate Methods
- (void)bodyTextViewController:(BodyTextViewController *)btvc didFinishEditingBody:(NSString *)bodyText {
	
	if ([delegate respondsToSelector:@selector(keyForEditingObject:forCellAtIndexPath:)]) {
		NSString *key = [delegate keyForEditingObject:editingObject forCellAtIndexPath:editingPath];
		[editingObject setValue:bodyText forKey:key];
	}
	
	editingPath = nil;
	
	[self.theTableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)bodyTextViewControllerDidCancel:(BodyTextViewController *)btvc {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)titleForBodyTextViewController:(BodyTextViewController *)btvc {
	if ([delegate respondsToSelector:@selector(labelForEditingObject:forCellAtIndexPath:)]) {
		return [delegate labelForEditingObject:editingObject forCellAtIndexPath:editingPath];
	}
	else {
		return nil;
	}
}

- (BOOL)bodyTextViewControllerShouldClearOnEdit:(BodyTextViewController *)btvc {
	return NO;
}

#pragma mark UIActionSheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[delegate generalEditViewController:self didDeleteObject:editingObject];
	}
}

@end
