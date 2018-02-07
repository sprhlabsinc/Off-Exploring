//
//  BodyTextViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 29/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "BodyTextViewController.h"
#import "User.h"

#pragma mark -
#pragma mark BodyTextViewController Implementation

@implementation BodyTextViewController

@synthesize body;
@synthesize delegate;
@synthesize textView;
@synthesize navBar;

#pragma mark UIVIewController Methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppClose:) name:UIApplicationWillTerminateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppClose:) name: UIApplicationDidEnterBackgroundNotification object:nil];
    
	if ([delegate respondsToSelector:@selector(titleForBodyTextViewController:)]) {
		self.navBar.topItem.title = [delegate titleForBodyTextViewController:self];
	}
	
    [super viewDidLoad];
	self.textView.text = self.body;
	[self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.textView = nil;
	self.navBar = nil;
}

- (void)handleAppClose:(NSNotification *)notification {
	User *user = [User sharedUser];
	if (user.editingBlog == YES) {	
		[[NSUserDefaults standardUserDefaults] setObject:self.textView.text forKey:@"autoSavedBodyText"];
	}
}

#pragma mark IBActions
- (IBAction)cancel {
	BOOL display = NO;
	if ([delegate respondsToSelector:@selector(bodyTextViewControllerShouldDisplayCancelWarning:)]) {
		display = [delegate bodyTextViewControllerShouldDisplayCancelWarning:self];
	}
	
	if (display == YES) {
		UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:@"Are you sure you wish to cancel? You will lose any unsaved changes!"
															 delegate:self
													cancelButtonTitle:@"Continue Editing"
											   destructiveButtonTitle:@"Cancel and Discard"
													otherButtonTitles:nil];
		
		[actions showInView:self.view];
		
	}
	else {
		[delegate bodyTextViewControllerDidCancel:self];
	}
}

- (IBAction)save {
	self.body = self.textView.text;
	
	[delegate bodyTextViewController:self didFinishEditingBody:self.body];
}

#pragma mark UITextView Delegate Method
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	if ([self.textView.text isEqualToString:@"Start typing your blog.."]) {
		self.textView.text = @"";
	}
	else if ([delegate respondsToSelector:@selector(bodyTextViewControllerShouldClearOnEdit:)]) {
		if ([delegate bodyTextViewControllerShouldClearOnEdit:self] == YES) {
			self.textView.text = @"";
		}
	}
	return YES;
}

#pragma mark UIActionSheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[delegate bodyTextViewControllerDidCancel:self];
	}
}

@end
