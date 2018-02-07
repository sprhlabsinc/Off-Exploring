//
//  BlogViewController.m
//  Off Exploring
//
//  Created by Off Exploring on 13/04/2010.
//  Copyright 2010 Off Exploring Ltd. All rights reserved.
//

#import "BlogViewController.h"
#import "User.h"
#import "BlogDetailTableViewCell.h"
#import "BlogHeaderTableViewCell.h"
#import "StringHelper.h"
#import "UIImage+Resize.h"
#import "PhotoViewController.h"
#import "Photo.h"
#import "GANTracker.h"
#import "MessageTextViewController.h"
#import "OFXComment.h"
#import "JRActivityObject.h"

#pragma mark -
#pragma mark BlogViewController Private Interface
/**
 @brief Private methods to provide ability to edit, save and load a Blog and its images
 
 This interface provides private methods used to edit a Blog, save a Blog and then re-load that Blog.
 Additionally, it provides utility methods for switching between edit and regular view mode, filesystem
 access, text manipulation and image manipulation
 */
@interface BlogViewController()<MessageTextViewControllerDelegate>
#pragma mark Private Method Declarations
/**
 Begins downloading Blog data from Off Exploring
 */
- (void)loadBlog;

/**
 Saves the changes made to a Blog that is being edited
 */
- (void)saveChanges;

/**
 Transmits Blog content to Off Exploring
 */
- (void)postBlog;

/**
 Switches from regular Blog display mode to editing mode
 @param autoPostBlog A flag to say upon display begin posting Blog immediately
 */
- (void)presentEditingView:(BOOL)autoPostBlog;

/**
 Strips HTML content from downloaded Blog data
 @param html The HTML to strip
 @returns The clean data
 */
- (NSString *)flattenHTML:(NSString *)html;

/**
 Returns a string path to the Blog objects PLIST draft file on the file system
 @returns The string path
 */
- (NSString *)pathForDataFile;

/**
 Transforms an image and appropriately rotates it.
 @param sourceImage The image to transform
 @param targetSize The size to transform to
 @returns The transformmed image
 */
- (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;

/**
 A method to call to concurrently save an image without locking the main thread
 @param image The image to save
 */
- (void)saveImage:(UIImage *)image;

/**
 A method to switch back to the main thread signalling the image was saved
 */
- (void)imageDidSave;

/**
 Displays the social sharing dialogue 
 */
- (void)showSocialShare:(Blog *)newBlog; 

@property (nonatomic, strong) OffexConnex *connex;
@property (nonatomic, strong) NSOperationQueue *saveImageQueue;
@property (nonatomic, strong) UIImage *tempThumb;
@property (nonatomic, strong) NSString *tempBody;
@property (nonatomic, strong) NSString *tempImageURI;
@property (nonatomic, strong) NSDictionary *tempState;
@property (nonatomic, strong) NSDictionary *tempArea;
@property (nonatomic, strong) NSDictionary *tempGeolocation;
@property (nonatomic, assign) int tempDate;
@property (nonatomic, strong) UIImagePickerController *pickerView;
@property (nonatomic, assign) BOOL saveToLibrary;
@property (nonatomic, assign) BOOL downloadedData;
@property (nonatomic, assign) BOOL postImage;
@property (nonatomic, strong) ImageLoader *imageLoader;
@property (nonatomic, strong) MessageTextViewController *messageTextViewController;
@property (nonatomic, strong) Blog *uploadedBlogEntry;

@end

#pragma mark -
#pragma mark BlogViewController Implementation

@implementation BlogViewController

@synthesize tableView;
@synthesize commentsButton;
@synthesize blog;
@synthesize connex;
@synthesize editing;
@synthesize save;
@synthesize cancel;
@synthesize edit;
@synthesize navBar;
@synthesize toolbar;
@synthesize delegate;
@synthesize allBlogs;
@synthesize deleteBlog;
@synthesize saveImageQueue;
@synthesize tempThumb;
@synthesize tempBody;
@synthesize tempState;
@synthesize tempArea;
@synthesize tempGeolocation;
@synthesize tempDate;
@synthesize tempImageURI;
@synthesize pickerView;
@synthesize saveToLibrary;
@synthesize autoSavedBlog;
@synthesize tempTrip;
@synthesize activityIndicator;
@synthesize downloadedData;
@synthesize topView;
@synthesize mainView;
@synthesize autoPost;
@synthesize postImage;
@synthesize imageLoader;
@synthesize messageTextViewController = _messageTextViewController;
@synthesize uploadedBlogEntry;

#pragma mark UIVIewController Methods

- (void)dealloc {
    imageLoader.delegate = nil;
	if (HUD != nil) {
		HUD.delegate = nil;
	}
	connex.delegate = nil;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		connex = [[OffexConnex alloc] init];
		connex.delegate = self;
		self.editing = NO;
		saveImageQueue = [[NSOperationQueue alloc] init];
		[saveImageQueue setMaxConcurrentOperationCount:1];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppClose:) name:UIApplicationWillTerminateNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppClose:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[self.view addSubview:mainView];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background2]]];
	tableView.backgroundColor = [UIColor clearColor];
    if ([UIColor tableViewSeperatorColor]) {
        tableView.separatorColor = [UIColor tableViewSeperatorColor];
    }
	mainView.backgroundColor = [UIColor clearColor];
	User *user = [User sharedUser];
	
	if (self.editing == NO) {
		self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString background]]];
		self.view.backgroundColor = [UIColor clearColor];
		self.navBar.hidden = YES;
		self.tableView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height - 44);
		self.navigationItem.rightBarButtonItem = edit;
		self.downloadedData = YES;
        
        self.toolbar.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
        [self.view addSubview:self.toolbar];
        
		if (blog.draft == NO) {
			self.deleteBlog.hidden = YES;
			self.downloadedData = NO;
            [self.commentsButton setEnabled:YES];
			[self loadBlog];
		}
		else if (user.globalDraft == NO) {
			[self.deleteBlog setBackgroundImage:[UIImage imageNamed:@"greenButton.png"] forState:UIControlStateNormal];
			self.deleteBlog.hidden = NO;
			[self.deleteBlog setTitle:@"Publish Blog" forState:UIControlStateNormal];
			[self.deleteBlog removeTarget:self action:@selector(deleteBlog) forControlEvents:UIControlEventTouchUpInside];
			[self.deleteBlog addTarget:self action:@selector(autoPublish) forControlEvents:UIControlEventTouchUpInside];
            [self.commentsButton setEnabled:NO];
		}
		else if (user.globalDraft == YES) {
			self.deleteBlog.hidden = YES;
            [self.commentsButton setEnabled:NO];
		}
	}
	else {
		[self.view addSubview:topView];
		
		self.tableView.frame = CGRectMake(0, 44, 320, self.view.frame.size.height - 44);
		
		NSDictionary *autoSave = [[NSUserDefaults standardUserDefaults] objectForKey:@"autoSavedBlog"];
		if (autoSave != nil) {
			user.autoSavedBlog = [NSMutableDictionary dictionaryWithDictionary:autoSave];
			
			if (autoSave[@"tempBody"]) {
				tempBody = autoSave[@"tempBody"];
			}
			
			NSString *autoSavedBody = [[NSUserDefaults standardUserDefaults] objectForKey:@"autoSavedBodyText"];
			if (autoSavedBody != nil && ![autoSavedBody isEqualToString:@""]) {
				tempBody = autoSavedBody;
				(user.autoSavedBlog)[@"tempBody"] = tempBody;
			}
			
			tempArea = autoSave[@"tempArea"];
			tempState = autoSave[@"tempState"];
			tempGeolocation = autoSave[@"tempGeolocation"];
			
			tempDate = [autoSave[@"tempDate"] intValue];
			
			NSDate *autoSavedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"autoSavedDate"];
			NSTimeInterval timestamp = [autoSavedDate timeIntervalSince1970];
			if (autoSavedDate != nil) {
				tempDate = timestamp;
				(user.autoSavedBlog)[@"tempDate"] = @(tempDate);
			}
			
			if (![autoSave[@"tempImageURI"] isKindOfClass:[NSNumber class]]) {
				tempImageURI = autoSave[@"tempImageURI"];
			}
			self.blog = [self.allBlogs getBlogUsingTimestamp:[autoSave[@"original_timestamp"] intValue] andState:tempState andArea:tempArea];
			
			if (self.blog == nil) {
                Blog *aBlog = [[Blog alloc] init];
                self.blog = aBlog;
				self.blog.body = @"Start typing your blog..";
				self.blog.timestamp = [autoSave[@"tempDate"] intValue];
				self.blog.original_timestamp = [autoSave[@"original_timestamp"] intValue];
				self.blog.trip = self.tempTrip;
			}
			
			if (tempBody == nil) {
				tempBody = self.blog.body;
			}
		}
		else {
			if (!tempBody) {
				tempBody = blog.body;
			}
			if (!tempState) {
				tempState = blog.state;
			}
			if (!tempArea) {
				tempArea = blog.area;
			}
			if (!tempGeolocation) {
				tempGeolocation = blog.geolocation;
			}
			if (!tempDate) {
				tempDate = blog.timestamp;
			}
			if (!tempImageURI) {
				tempImageURI = blog.imageURI;
			}
			if (!user.autoSavedBlog) {
				user.autoSavedBlog = [NSMutableDictionary dictionaryWithObjectsAndKeys:tempState, @"tempState", tempArea, @"tempArea", tempGeolocation, @"tempGeolocation", tempBody, @"tempBody", tempImageURI, @"tempImageURI", nil];
			}
		}
		
		UINavigationItem *navItem;
		
		if (self.blog.draft == YES || self.blog.blogid != nil) {
			navItem = [[UINavigationItem alloc] initWithTitle:@"Edit Blog"];
			self.deleteBlog.hidden = NO;
		}
		else {
			navItem = [[UINavigationItem alloc] initWithTitle:@"Add Blog"];
			self.deleteBlog.hidden = YES;
		}
		navItem.leftBarButtonItem = cancel;
		navItem.rightBarButtonItem = save;
		
		[self.navBar pushNavigationItem:navItem animated:false];
		
		if (self.autoPost == YES) {
			self.autoPost = NO;
			[self performSelector:@selector(beginPosting) withObject:nil afterDelay:0.5];
		}
	}
	[super viewDidLoad];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated {
	if (self.editing == NO) {
		User *user = [User sharedUser];
		if (blog.draft == NO) {
			self.deleteBlog.hidden = YES;
		}
		else if (user.globalDraft == NO) {
			[self.deleteBlog setBackgroundImage:[UIImage imageNamed:@"greenButton.png"] forState:UIControlStateNormal];
			self.deleteBlog.hidden = NO;
			[self.deleteBlog setTitle:@"Publish Blog" forState:UIControlStateNormal];
			[self.deleteBlog removeTarget:self action:@selector(deleteBlog) forControlEvents:UIControlEventTouchUpInside];
			[self.deleteBlog addTarget:self action:@selector(autoPublish) forControlEvents:UIControlEventTouchUpInside];
		}
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setCommentsButton:nil];
    [self setToolbar:nil];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.tableView = nil;
	self.save = nil;
	self.cancel = nil;
	self.edit = nil;
	self.navBar = nil;
	self.deleteBlog = nil;
}

- (void)handleAppClose:(NSNotification *)notification {
	if (self.editing == YES) {	
		User *user = [User sharedUser];
		if ([tempBody isEqualToString:@""] || tempBody == nil) {
			(user.autoSavedBlog)[@"tempBody"] = @"Start typing your blog..";
		}
		(user.autoSavedBlog)[@"tempDate"] = @(tempDate);
		(user.autoSavedBlog)[@"draft"] = @(blog.draft);
		(user.autoSavedBlog)[@"original_timestamp"] = @(blog.original_timestamp);		
		[[NSUserDefaults standardUserDefaults] setObject:user.autoSavedBlog forKey:@"autoSavedBlog"];
	}
}

#pragma mark IBActions

- (IBAction)beginEditing {
	[self presentEditingView:NO];
}

- (IBAction)cancelButton {
	
	UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:@"Are you sure you wish to cancel? You will lose any unsaved changes!"
														 delegate:self
												cancelButtonTitle:@"Continue Editing"
										   destructiveButtonTitle:@"Cancel and Discard"
												otherButtonTitles:nil];
	
	[actions showInView:self.view];
	
}

- (IBAction)saveButton {
	if (tempArea[@"name"] != nil && tempState[@"name"] != nil  && ![tempArea[@"name"] isEqualToString:@""] && ![tempState[@"name"] isEqualToString:@""]) {
		User *user = [User sharedUser];
		UIActionSheet *actions;
		if (user.globalDraft == NO) {
			actions = [[UIActionSheet alloc] initWithTitle:@"Save blog as draft, or publish to your site?"
												  delegate:self
										 cancelButtonTitle:@"Cancel"
									destructiveButtonTitle:nil
										 otherButtonTitles:@"Save as Draft", @"Publish", nil];
		}
		else {
			actions = [[UIActionSheet alloc] initWithTitle:@"Save blog as draft?"
												  delegate:self
										 cancelButtonTitle:@"Cancel"
									destructiveButtonTitle:nil
										 otherButtonTitles:@"Save as Draft", nil];
		}
		
		[actions showInView:self.view];
		
	}
	else {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"To save this blog post, you must set a location."
								  message:nil
								  delegate:self
								  cancelButtonTitle:@"Set Location"
								  otherButtonTitles:@"Cancel", nil];
		charAlert.delegate = self;
		[charAlert show];
		
	}
}

- (IBAction)deleteBlogButton {
	UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:@"Confirm Blog Delete"
														 delegate:self
												cancelButtonTitle:@"Cancel"
										   destructiveButtonTitle:@"Delete Blog"
												otherButtonTitles:nil];
	[actions showInView:self.view];
	
}

#pragma mark Publishing Methods

- (void)autoPublish {
	[self presentEditingView:YES];
}

- (void)beginPosting {
	NSString *pngPath = [self.blog getImageFilePath];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:pngPath] == NO && tempImageURI == nil  && [[NSFileManager defaultManager] fileExistsAtPath:[self.blog getTempImageFilePath]] == NO) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"To publish this blog post, you must select a blog image."
								  message:nil
								  delegate:nil
								  cancelButtonTitle:@"Ok"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
	else if (tempBody == nil || [tempBody isEqualToString:@""] || [tempBody isEqualToString:@"Start typing your blog.."]) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"To publish this blog post, you must enter some blog text."
								  message:nil
								  delegate:nil
								  cancelButtonTitle:@"Ok"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
	else if (tempArea == nil || [tempArea[@"name"] isEqualToString:@""] || tempState == nil || [tempState[@"name"] isEqualToString:@""]) {
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"To publish this blog post, you must set a blog location."
								  message:nil
								  delegate:nil
								  cancelButtonTitle:@"Ok"
								  otherButtonTitles:nil];
		[charAlert show];
		
	}
	
	else {
		
		HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
		[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = @"Publishing...";
		[HUD show:YES];
		
		[self saveChanges];
		NSString *prepath = [[NSString alloc] initWithFormat:@"%d.blog",blog.original_timestamp]; 
		NSString *filePath = [[self pathForDataFile] stringByAppendingPathComponent:prepath];
		[NSKeyedArchiver archiveRootObject:self.blog toFile:filePath];
		[self.allBlogs addBlog:blog];
		
		if (blog.imageURI == nil || self.postImage == YES) {
			
			UIImage *image = [UIImage imageWithContentsOfFile:pngPath];
			
			NSDate *date = [NSDate dateWithTimeIntervalSince1970:blog.timestamp];
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
			[dateFormatter setDateStyle:NSDateFormatterLongStyle];
			NSString *imgDate = [dateFormatter stringFromDate:date];
			
			NSDictionary *dict = @{@"albumname": @"Mobile Uploads", @"caption": imgDate, @"blog_image": @YES};
			NSString *boundary = @"---------------------------14737809831466499882746641449";
			NSString *contentMode = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary]; 
			
			int timestamp = [[NSDate date] timeIntervalSince1970];
			NSString *filename = [NSString stringWithFormat:@"%d-iphone-photo.jpg", timestamp];
			
			NSData *bodyText = [connex parameterBodyForImage:image andBoundary:boundary andFilename:filename andDictionary:dict];
			
			User *user = [User sharedUser];
			NSString *url = [connex buildOffexRequestStringWithURI:[[[[[[@"user/" stringByAppendingString:user.username]
																		stringByAppendingString:@"/trip/"]
																	   stringByAppendingString:(blog.trip)[@"urlSlug"]]
																	  stringByAppendingString:@"/album/"]
																	 stringByAppendingString:@"mobile-uploads"]
																	stringByAppendingString:@"/photo"]];
			
			[connex postOffexploringData:bodyText withContentMode:contentMode toURL:url];
		}
		else {
			[self postBlog];
		}
	}
}

- (void)showPhoto {
	Photo *photo = nil;
	if (self.blog.draft == YES || self.editing == YES) {
		
		NSString *tmpPath = [self.blog getTempImageFilePath];
		NSString *pngPath = [self.blog getImageFilePath];
		if ([[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
			photo = [[Photo alloc] init];
			photo.theImage = [UIImage imageWithContentsOfFile:tmpPath];
		}
		else if ([[NSFileManager defaultManager] fileExistsAtPath:pngPath]) {
			photo = [[Photo alloc] init];
			photo.theImage = [UIImage imageWithContentsOfFile:pngPath];
		}
		else if (self.blog.imageURI == nil) {
			UIAlertView *charAlert = [[UIAlertView alloc]
									  initWithTitle:@"No Photo Set"
									  message:@"You have not set a photo for this blog post yet."
									  delegate:nil
									  cancelButtonTitle:@"Ok"
									  otherButtonTitles:nil];
			[charAlert show];
			
			return;
		}
	}
	
	if (!photo) {
		photo = [[Photo alloc] init];
		photo.imageURI = blog.imageURI;
	}
	
	if (self.editing == NO) {
		photo.caption = [NSString stringWithFormat:@"%@, %@",(self.blog.area)[@"name"], (self.blog.state)[@"name"]];
	}
	else {
		if (tempArea[@"name"] != nil && tempState[@"name"] != nil && ![tempArea[@"name"] isEqualToString:@""] && ![tempState[@"name"] isEqualToString:@""]) {
			photo.caption = [NSString stringWithFormat:@"%@, %@",tempArea[@"name"], tempState[@"name"]];
		}
		else if (tempArea[@"name"] != nil && ![tempArea[@"name"] isEqualToString:@""]) {
			photo.caption = [NSString stringWithFormat:@"%@",tempArea[@"name"]];
		}
		else if (tempState[@"name"] != nil && ![tempState[@"name"] isEqualToString:@""]) {
			photo.caption = [NSString stringWithFormat:@"%@",tempArea[@"name"]];
		}
	}
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/photo/" withError:nil];
	PhotoViewController *photoView = [[PhotoViewController alloc] initWithNibName:nil bundle:nil];
	photoView.viewBlogPhoto = YES;
	photoView.photos = @[photo];
	if (self.editing == YES) {
		photoView.currentlyEditingPhoto = YES;
		[self presentViewController:photoView animated:YES completion:nil];
	}
	else {
		[self.navigationController pushViewController:photoView animated:YES];
	}
	
}

#pragma mark Private Methods

- (void)loadBlog {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blogDidLoad:) name:@"blogDidLoad" object:nil];
	User *user = [User sharedUser];
	
	NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/trip/%@/blog/%@", user.username, (blog.trip)[@"urlSlug"], blog.blogid]];
	
	[connex beginLoadingOffexploringDataFromURL:url];
}

- (void)saveChanges {
	if (self.editing == YES) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"autoSavedBlog"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"autoSavedBodyText"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"autoSavedDate"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:[self.blog getTempImageFilePath]] || [fileManager fileExistsAtPath:[self.blog getTempThumbImageFilePath]]) {
			
			[fileManager removeItemAtPath:[self.blog getImageFilePath] error:nil];
			[fileManager removeItemAtPath:[self.blog getThumbImageFilePath] error:nil];
			
			if ([fileManager fileExistsAtPath:[self.blog getTempImageFilePath]]) {
				NSError *error;
				[fileManager moveItemAtPath:[self.blog getTempImageFilePath] toPath:[self.blog getImageFilePath] error:&error];
			}
			else {
				[fileManager removeItemAtPath:[self.blog getImageFilePath] error:nil];
			}
			
			if ([fileManager fileExistsAtPath:[self.blog getTempThumbImageFilePath]]) {
				NSError *error;
				[fileManager moveItemAtPath:[self.blog getTempThumbImageFilePath] toPath:[self.blog getThumbImageFilePath] error:&error];
			}
			else {
				[fileManager removeItemAtPath:[self.blog getThumbImageFilePath] error:nil];
			}
		}
        
        blog.body = tempBody;
        blog.state = tempState;
        blog.area = tempArea;
        blog.geolocation = tempGeolocation;
        blog.timestamp = tempDate;
        blog.imageURI = tempImageURI;
        blog.draft = YES;
		
		User *user = [User sharedUser];
		user.autoSavedBlog = nil;
	}
}

- (void)postBlog {
	
	User *user = [User sharedUser];
	NSMutableDictionary *dict;
	NSString *url;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"dd-MM-yyyy"];
	NSString *theDate = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:blog.timestamp]];
	
	if (blog.blogid == nil) {
		dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:blog.body, @"body", blog.imageURI, @"image", (blog.state)[@"name"], @"state", 
				(blog.area)[@"name"],@"area",theDate, @"date",nil]; 
		if (blog.geolocation != nil) {
			NSString *latitude = [NSString stringWithFormat:@"%f",[(blog.geolocation)[@"latitude"] doubleValue]];
			NSString *longitude = [NSString stringWithFormat:@"%f",[(blog.geolocation)[@"longitude"] doubleValue]];
			
			dict[@"latitude"] = latitude;
			dict[@"longitude"] = longitude;
		}
		url = [connex buildOffexRequestStringWithURI:[[[[@"user/" stringByAppendingString:user.username] stringByAppendingString:@"/trip/"] stringByAppendingString:(blog.trip)[@"urlSlug"]] stringByAppendingString:@"/blog"]];
	}
	else {
		dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:blog.body, @"body", blog.imageURI, @"image", theDate, @"date",nil]; 
		
		url = [connex buildOffexRequestStringWithURI:[[[[[@"user/" 
														  stringByAppendingString:user.username] 
														 stringByAppendingString:@"/trip/"] 
														stringByAppendingString:(blog.trip)[@"urlSlug"]]
													   stringByAppendingString:@"/blog/"]
													  stringByAppendingString:blog.blogid]];
	}
	
	NSData *dataString = [connex paramaterBodyForDictionary:dict];
	[connex postOffexploringData:dataString withContentMode:@"application/x-www-form-urlencoded" toURL:url];
}

- (void)presentEditingView:(BOOL)autoPostBlog {
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
	BlogViewController *addView = [[BlogViewController alloc] initWithNibName:nil bundle:nil];
	addView.blog = self.blog;
	addView.editing = YES;
	addView.delegate = self;
	addView.allBlogs = allBlogs;
	[addView setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	if (autoPostBlog == YES) {
		addView.autoPost = YES;
	}
	[self presentViewController:addView animated:YES completion:nil];
}

- (NSString *)flattenHTML:(NSString *)html {
	
    NSScanner *theScanner;
    NSString *text = nil;
	
    theScanner = [NSScanner scannerWithString:html];
	
    while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
				[ NSString stringWithFormat:@"%@>", text]
											   withString:@""];
		
    } // while //
    return html;	
}

- (NSString *)pathForDataFile { 
	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	User *user = [User sharedUser];
	NSString *folder = [NSString stringWithFormat:@"~/Library/Application Support/Offexploring/Blog_Draft/%@", user.username]; 
	folder = [folder stringByExpandingTildeInPath];
	if ([fileManager fileExistsAtPath: folder] == NO) { 
		[fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
	} 
	return folder;	
} 

- (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize
{  
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
		
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }     
	
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
	
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
	
    CGContextRef bitmap;
	
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
		
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
		
    }   
	
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
		
		CGContextRotateCTM (bitmap, (90 * (3.1415927/180.0)));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
		
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
		
        CGContextRotateCTM (bitmap, (-90 * (3.1415927/180.0)));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
		
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, (-180 * (3.1415927/180.0)));
    }
	
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
	
    CGContextRelease(bitmap);
    CGImageRelease(ref);
	
    return newImage; 
}

- (void)saveImage:(UIImage *)image {
	NSInvocationOperation *saveImage = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadTheNeedle:) object:image];
	[self.saveImageQueue cancelAllOperations];
	[self.saveImageQueue addOperation:saveImage];
}

- (void)imageDidSave {
	self.postImage = YES;
	tempImageURI = nil;
	[HUD hide:NO];
	[self.tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)blogDidLoad:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"blogDidLoad" object:nil];
	self.downloadedData = YES;
	[self.tableView reloadData];
}

- (void)threadTheNeedle:(UIImage *)image {
	
	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	NSString *pngPath = [self.blog getTempThumbImageFilePath];
	[fileManager removeItemAtPath:pngPath error:nil];
	pngPath = [self.blog getTempImageFilePath];
	[fileManager removeItemAtPath:pngPath error:nil];
	
	if (self.saveToLibrary == YES) {
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
	}
	
	CGFloat width = image.size.width; 
	CGFloat height = image.size.height;
	
	CGSize theSize;
	if (width > height) {
		//theSize = CGSizeMake(800, 600);
		theSize = CGSizeMake(720, 540);
	}
	else {
		//theSize = CGSizeMake(600, 800);
		theSize = CGSizeMake(540, 720);
	}
	
	UIImage *full = [image resizedImage:theSize interpolationQuality:kCGInterpolationHigh];
	pngPath = [self.blog getTempImageFilePath];
	[UIImageJPEGRepresentation(full, 1.0) writeToFile:pngPath atomically:YES];
	image = nil;
	
	UIImage *thumb = [self imageWithImage:full scaledToSizeWithSameAspectRatio:CGSizeMake(65, 60)];
	pngPath = [self.blog getTempThumbImageFilePath];
	[UIImageJPEGRepresentation(thumb, 1.0) writeToFile:pngPath atomically:YES];
	thumb = nil;
	full = nil;
	
	User *user = [User sharedUser];
	(user.autoSavedBlog)[@"tempImageURI"] = @NO;
	
	[self performSelectorOnMainThread:@selector(imageDidSave) withObject:nil waitUntilDone:NO];
}


#pragma mark Comments
- (IBAction)commentsButtonPressed:(id)sender {
    User *user = [User sharedUser];
    connex.delegate = self;
    NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/comments", user.username]];
	[connex beginLoadingOffexploringDataFromURL:[NSString stringWithFormat:@"%@&contentType=blog&contentId=%@", url, blog.blogid]];
}

- (void)messageTextViewControllerDidFinish:(MessageTextViewController *)messageTextViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendMessage:(NSString *)message {
    User *user = [User sharedUser];
    NSDictionary *dict = @{@"name": user.username, @"comment": message, @"username": user.username, @"email": @"", @"contentId": blog.blogid, @"contentType": @"blog"};
    
    connex.delegate = self;
    NSData *bodyText = [connex paramaterBodyForDictionary:dict];
    NSString *contentMode = @"application/x-www-form-urlencoded";
    NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/comment",user.username]];
    [connex postOffexploringData:bodyText withContentMode:contentMode toURL:url];
}

- (void)deleteMessage:(id <MessageTextMessage>)aMessage {
    connex.delegate = self;
    User *user = [User sharedUser];
    NSString *url = [connex buildOffexRequestStringWithURI:[NSString stringWithFormat:@"user/%@/comment", user.username]];
    [connex deleteOffexploringDataAtUrl:[NSString stringWithFormat:@"%@&contentType=blog&id=%@", url, aMessage.messageId]];
}


#pragma mark Social Sharing Methods
- (void)showSocialShare:(Blog *)newBlog {
    
    [JREngage setEngageAppId:TARGET_PARTNER_JANRAIN_APP_ID
                    tokenUrl:nil
                 andDelegate:self];
    
	User *user = [User sharedUser];
	
	NSString *theDate = newBlog.entryDate;
    
    theDate = [connex urlEncodeValue:theDate];
	
	NSString *socialAddress		= [NSString stringWithFormat:@"http://%@/%@/blog/%@/%@/%@", [NSString partnerWebsite],
								   user.username,(newBlog.state)[@"urlSlug"],(newBlog.area)[@"urlSlug"],theDate];
	NSString *socialIntroText	= nil;
	
	if ([socialIntroText length] > 99) {
		socialIntroText			= [newBlog.body substringWithRange:NSMakeRange(0, 100)];
	}
	else {
		socialIntroText			= newBlog.body;
	}
	
	NSMutableArray *theImageURIComponents       = [[blog.imageURI componentsSeparatedByString:@"/"] mutableCopy];
    NSString *basename = [theImageURIComponents lastObject];
    basename = [connex urlEncodeValue:basename];
    [theImageURIComponents replaceObjectAtIndex:([theImageURIComponents count] - 1) withObject:basename];
    NSString *imageURL = [theImageURIComponents componentsJoinedByString:@"/"];
	
	NSString *blogImage			= [NSString stringWithFormat:@"%@%@", S3_IMAGE_ADDRESS, imageURL];
	
	JRImageMediaObject *image	= [[JRImageMediaObject alloc] initWithSrc:blogImage
																andHref:socialAddress];
	
	JRActivityObject *activity = [[JRActivityObject alloc]
								   initWithAction:@"posted a new blog entry"
								   andUrl:socialAddress];
	
	
    [activity setMedia:[NSMutableArray arrayWithArray:@[image]]];
	
	[JREngage showSharingDialogWithActivity:activity];
    
}

- (void)sharingDidNotComplete {
    
    [JREngage removeDelegate:self];
    
	//if (!HUD) {
		HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
		[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = @"Saving...";
		[HUD show:YES];
		[self performSelector:@selector(dismissEditingView) withObject:nil afterDelay:1.2];
	//}
}

- (void)sharingDidComplete {
    
    [JREngage removeDelegate:self];
    
	//if (!HUD) {
		HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
		[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = @"Saving...";
		[HUD show:YES];
		[self performSelector:@selector(dismissEditingView) withObject:nil afterDelay:1.2];
	//}
}

- (void)dismissEditingView {
    [HUD hide:YES];
	HUD = nil;
	[delegate blogViewController:self didFinishEditingBlog:self.uploadedBlogEntry];
}

#pragma mark UINavigationBar Delegate Methods

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
	return YES;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
	return YES;
}

#pragma mark OffexploringConnection Delegate Methods

- (void)offexploringConnection:(OffexConnex *)offex resultSet:(NSDictionary *)results {
    
    if (self.editing) {
        
        if ([results[@"response"][@"success"] isEqualToString:@"true"] && results[@"response"][@"photo"] != nil) {
            blog.imageURI = results[@"response"][@"photo"][@"photo"][@"image"];
            self.postImage = NO;
            [self postBlog];
        }
        else if ([results[@"request"][@"method"] isEqualToString:@"DELETE"]) {
            [HUD hide:YES];
            if ([results[@"response"][@"success"] isEqualToString:@"true"]){
                [self.allBlogs deleteBlog:self.blog];
                [delegate blogViewControllerDidDeleteBlog:self];
            }
            else {
                UIAlertView *charAlert = [[UIAlertView alloc]
                                          initWithTitle:[NSString stringWithFormat:@"%@ Error",[NSString partnerDisplayName]]
                                          message:[NSString stringWithFormat:@"An error has occured deleting from %@. Please retry.",[NSString partnerDisplayName]]
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [charAlert show];
                
            }
        }
        else if (results[@"response"][@"id"]) {
            Blog *newBlog = [[Blog alloc] initFromDictionary:results[@"response"]];
            [newBlog setFromDictionary:results[@"response"]];
            newBlog.trip = self.blog.trip;
            
            NSDictionary *stateDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:results[@"response"][@"state"][@"state"], @"name", results[@"response"][@"state"][@"slug"], @"urlSlug", nil];
            newBlog.state = stateDictionary;
            
            NSMutableDictionary *areaDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:results[@"response"][@"area"][@"area"], @"name", results[@"response"][@"area"][@"slug"], @"urlSlug", @NO, @"drafts", nil];
            newBlog.area = areaDictionary;
            
            [self.blog deleteBlog];
            newBlog.original_timestamp = self.blog.original_timestamp;
            newBlog.timestamp = self.blog.timestamp;
            self.uploadedBlogEntry = newBlog;
            [HUD hide:YES];
            [self showSocialShare:self.uploadedBlogEntry];
        }
        else {	
            NSArray *blogs = results[@"response"][@"blogs"][@"blog"];
            [blog setFromDictionary:blogs[0]];
        }
        
    }
    else {
        
        if (([results[@"request"][@"method"] isEqualToString:@"DELETE"])  && results[@"response"][@"success"] && [results[@"response"][@"success"] isEqualToString:@"true"]) {
            
            [self.messageTextViewController hideHUDMessage];
            
            NSNumber *messageId = @([results[@"request"][@"getVars"][@"id"] intValue]);
            
            if ([self.messageTextViewController.messages count] == 1) {
                self.messageTextViewController.messages = @[];
                [self.messageTextViewController.tableView reloadData];
            }
            else {
                [self.messageTextViewController.tableView beginUpdates];
                
                NSMutableArray *messageArray = [self.messageTextViewController.messages mutableCopy];
                
                int count = 0;
                for (id <MessageTextMessage> aMessage in messageArray) {
                    if ([aMessage.messageId isEqualToNumber:messageId]) {
                        [self.messageTextViewController.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                        [messageArray removeObject:aMessage];
                        break;
                    }
                    count++;
                }
                
                self.messageTextViewController.messages = messageArray;
                
                [self.messageTextViewController.tableView endUpdates];
            }
        }
        else if (results[@"response"][@"comment"]) {
            [self.messageTextViewController hideHUDMessage];
            
            // Animate adding the message
            OFXComment *newMessage = [[OFXComment alloc] initWithDictionary:results[@"response"][@"comment"]];
            
            if ([self.messageTextViewController.messages count] == 0) {
                self.messageTextViewController.messages = @[newMessage];
                [self.messageTextViewController.tableView reloadData];
            }
            else {
                
                [self.messageTextViewController.tableView beginUpdates];
                
                NSMutableArray *messagesArray = [self.messageTextViewController.messages mutableCopy];
                [messagesArray insertObject:newMessage atIndex:0];
                self.messageTextViewController.messages = messagesArray;
                
                [self.messageTextViewController.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
                
                [self.messageTextViewController.tableView endUpdates];
            }
            
            [self.messageTextViewController resetView];
        }
        else if (results[@"response"][@"comments"][@"comment"]){
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dict in results[@"response"][@"comments"][@"comment"]) {
                OFXComment *aComment = [[OFXComment alloc] initWithDictionary:dict];
                [messages addObject:aComment];
            }
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
            NSArray *sortDescriptors = @[sortDescriptor];
            
            MessageTextViewController *messageTextViewController = [[MessageTextViewController alloc] initWithNibName:nil bundle:nil];
            self.messageTextViewController = messageTextViewController;
            self.messageTextViewController.delegate = self;
            self.messageTextViewController.messages = [messages sortedArrayUsingDescriptors:sortDescriptors];
            self.messageTextViewController.title = @"Comments";
            [self.navigationController pushViewController:self.messageTextViewController animated:YES];
        }
        else {	
            NSArray *blogs = results[@"response"][@"blogs"][@"blog"];
            [blog setFromDictionary:blogs[0]];
        }
    }
}

- (void)offexploringConnection:(OffexConnex *)offex didFireError:(NSError *) error {
	[HUD hide:YES];
	
	if ([[error userInfo][@"results"][@"status"][@"errormessage"] isEqualToString:@"blog update id not set"]) {
        
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Update Failed"
								  message:[NSString stringWithFormat:@"The original blog entry no longer exists on %@, would you like to publish it again?", [NSString partnerDisplayName]]
								  delegate:self
								  cancelButtonTitle:@"NO"
								  otherButtonTitles:@"YES", nil];
		[charAlert show];
		
        
	}
	else if ([[error userInfo][@"results"][@"status"][@"errormessage"] isEqualToString:@"CRC Failed"]) {
		
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"Publishing Failed"
								  message:@"A problem was encountered during the upload of this blog post. Would you like to retry?"
								  delegate:self
								  cancelButtonTitle:@"NO"
								  otherButtonTitles:@"YES", nil];
		[charAlert show];
		
		
	}
	else {
        
		UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:[NSString stringWithFormat:@"Error Communicating With %@, please retry", [NSString partnerDisplayName]]
                                  message:[error localizedDescription]
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[charAlert show];
		
        
	}
}

#pragma mark UITableView Delegate and Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (blog.blogid != nil || self.editing == YES || blog.draft == YES) {
		return 3;
	}
	else {
		return 0;
	}
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if (section == 1 && ([(blog.trip)[@"urlSlug"] isEqualToString:@"default"] || [(blog.trip)[@"urlSlug"] isEqualToString:@"draft"])) {
		return 2;
	}
	else if (section == 1 && (![(blog.trip)[@"urlSlug"] isEqualToString:@"default"] && ![(blog.trip)[@"urlSlug"] isEqualToString:@"draft"])) {
		return 3;
	}
	else {
		return 1;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 81.0;
	}
	else if (indexPath.section == 2) {
		if (self.editing == YES) {
			self.tempBody = [self flattenHTML:self.tempBody];
			return [self.tempBody RAD_textHeightForSystemFontOfSize:15.0] + 20.0;
		}
		if (self.editing == NO && self.downloadedData == YES) {
			blog.body = [self flattenHTML:blog.body];
			return [blog.body RAD_textHeightForSystemFontOfSize:15.0] + 20.0;
		}
		else {
			return 40.0;
		}
	}
	else {
		return 40.0;
	}
}

// Build the header label for the page
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == 2) {
        
		UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
		
		UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 300, 50)];
		headerLabel.text = @"Blog Text";
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.textAlignment = NSTextAlignmentLeft;
		headerLabel.textColor = [UIColor headerLabelTextColor];
		headerLabel.font = [ UIFont boldSystemFontOfSize: 14];
		headerLabel.shadowColor = [UIColor headerLabelShadowColor];
		headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		
		[customView addSubview: headerLabel];
		
		return customView;
	}
	else {
		return nil;
	}
}

// Set the header hight for the page
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 2) {
		return 40.0;
        
	}
	else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"generalCell";
	
	if (indexPath.section == 2) {
		UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										   reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		if (self.editing == YES) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
		
		if ([[cell.contentView subviews] count] > 0) {
			UIView *labelToClear = [cell.contentView subviews][0];
			[labelToClear removeFromSuperview];
		}
		
		if (self.editing == YES) {
			UILabel *cellLabel = [self.tempBody RAD_newSizedCellLabelWithSystemFontOfSize:15.0];
			[cell.contentView addSubview:cellLabel];
		}
		else if (self.editing == NO && self.downloadedData == YES) {
			UILabel *cellLabel = [blog.body RAD_newSizedCellLabelWithSystemFontOfSize:15.0];
			[cell.contentView addSubview:cellLabel];
		}
		else {
            UIActivityIndicatorView *anActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			self.activityIndicator = anActivityIndicator;
			self.activityIndicator.frame = CGRectMake(138, 10, 20, 20);
			[self.activityIndicator hidesWhenStopped];
			[self.activityIndicator startAnimating];
			[cell.contentView addSubview:self.activityIndicator];
		}
		return cell;
	}
    
	else if (indexPath.section == 1) {
		
		BlogDetailTableViewCell *cell = (BlogDetailTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
		if (cell == nil) {
			NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogDetailTableViewCell" owner:nil options:nil];
			for (id currentObject in nibObjects) {
				if ([currentObject isKindOfClass:[BlogDetailTableViewCell class]]) {
					cell = (BlogDetailTableViewCell *)currentObject;
				}
			}
		}
		if (self.editing == YES) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		if(indexPath.row == 0) {
			NSDate *date;
			if (blog.timestamp > 0 && self.editing == NO) {
				NSTimeInterval timestamp = blog.timestamp;
				date = [NSDate dateWithTimeIntervalSince1970:timestamp];
			}
			else if (tempDate > 0 && self.editing == YES) {
				NSTimeInterval timestamp = tempDate;
				date = [NSDate dateWithTimeIntervalSince1970:timestamp];
			}
			else {
				date = [NSDate date];
			}
			
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			
			[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
			[dateFormatter setDateStyle:NSDateFormatterLongStyle];
			
			cell.label.text = @"Date";
			cell.detail.text = [dateFormatter stringFromDate:date];
			
			if (self.editing == NO) {
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
            
		}
		else if(indexPath.row == 1) {
			cell.label.text = @"Location";
			if (self.editing == NO) {
				if (blog.area != nil && ![(blog.area)[@"name"] isEqualToString:@""]) {
					cell.detail.text = [NSString stringWithFormat:@"%@, %@",(blog.area)[@"name"], (blog.state)[@"name"]];
				}
				else if (blog.state != nil && ![(blog.state)[@"name"] isEqualToString:@""]) {
					cell.detail.text = (blog.state)[@"name"];
				}
				else {
					cell.detail.text = @"";
				}
			}
			else {
				if (tempArea[@"name"] != nil && tempState[@"name"] != nil && ![tempArea[@"name"] isEqualToString:@""] && ![tempState[@"name"] isEqualToString:@""]) {
					cell.detail.text = [NSString stringWithFormat:@"%@, %@",tempArea[@"name"], tempState[@"name"]];
				}
				else if (tempArea[@"name"] != nil && ![tempArea[@"name"] isEqualToString:@""]) {
					cell.detail.text = tempArea[@"name"];
				}
				else if (tempState[@"name"] != nil && ![tempState[@"name"] isEqualToString:@""]) {
					cell.detail.text = tempState[@"name"];
				}
				else {
					cell.detail.text = @"";
				}
			}
			
			if (self.editing == NO || (blog.blogid != nil && self.editing == YES)) {
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
		else if(indexPath.row == 2) {
			cell.label.text = @"Trip";
			cell.detail.text = (blog.trip)[@"name"];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		return cell;
	}
	else if (indexPath.section == 0) {
		BlogHeaderTableViewCell *cell = (BlogHeaderTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"customCell"];
		if (cell == nil) {
			NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlogHeaderTableViewCell" owner:nil options:nil];
			for (id currentObject in nibObjects) {
				if ([currentObject isKindOfClass:[BlogHeaderTableViewCell class]]) {
					cell = (BlogHeaderTableViewCell *)currentObject;
				}
			}
		}
		if (self.editing == YES) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else {
			cell.accessoryType = UITableViewCellAccessoryNone;	
		}
		
		[cell.blogThumbButton addTarget:self action:@selector(showPhoto) forControlEvents:UIControlEventTouchUpInside];
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:[blog getTempThumbImageFilePath]] == YES) {
			[cell.blogThumbButton setBackgroundImage:[UIImage imageWithContentsOfFile:[blog getTempThumbImageFilePath]] forState:UIControlStateNormal];
		}
		else if ([[NSFileManager defaultManager] fileExistsAtPath:[blog getTempImageFilePath]] == YES) {
			[cell.blogThumbButton setBackgroundImage:[UIImage imageWithContentsOfFile:[blog getTempImageFilePath]] forState:UIControlStateNormal];
		}
		else if ([[NSFileManager defaultManager] fileExistsAtPath:[blog getThumbImageFilePath]] == YES) {
			[cell.blogThumbButton setBackgroundImage:[UIImage imageWithContentsOfFile:[blog getThumbImageFilePath]] forState:UIControlStateNormal];
		}
		else if ([[NSFileManager defaultManager] fileExistsAtPath:[blog getImageFilePath]] == YES) {
			[cell.blogThumbButton setBackgroundImage:[UIImage imageWithContentsOfFile:[blog getImageFilePath]] forState:UIControlStateNormal];
		}
		else {
			if (blog.thumbURI != nil) {
				ImageLoader *imageLoaderObj = [[ImageLoader alloc] init];
				imageLoaderObj.delegate = self;
				[imageLoaderObj startDownloadForURL:[blog getThumbImageFullRemotePath]];
                self.imageLoader = imageLoaderObj;
				
				UIActivityIndicatorView *indication = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                if (cell.blogThumbButton) {
                    indication.center = cell.blogThumbButton.center;
                }
				indication.hidesWhenStopped = YES;
				[indication startAnimating];
				[cell addSubview:indication];
			}
		}
		if (self.editing == NO) {
			if (blog.entryTitle && ![blog.entryTitle isEqualToString:@""]) {
				cell.textLabel.text = blog.entryTitle;
			}
			else {
				cell.textLabel.text = [NSString stringWithFormat:@"%@, %@",(blog.area)[@"name"], (blog.state)[@"name"]];
			}
		}
		else if (self.editing == YES && tempArea != nil) {
			cell.textLabel.text = @"Change cover image...";
		}
		else {
			cell.textLabel.text = @"Add cover image...";
		}
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (self.editing == YES) {
		if (indexPath.section == 0) {
			UIActionSheet *actions;
			User *user = [User sharedUser];
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && user.globalDraft == NO) {
				
				actions = [[UIActionSheet alloc] initWithTitle:@"Select Photo Source"
													  delegate:self
											 cancelButtonTitle:@"Cancel"
										destructiveButtonTitle:nil
											 otherButtonTitles:@"Take Photo", @"Camera Roll", @"My Albums", @"Library", nil];
				
			}
			else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && user.globalDraft == YES) {
				
				actions = [[UIActionSheet alloc] initWithTitle:@"Select Photo Source"
													  delegate:self
											 cancelButtonTitle:@"Cancel"
										destructiveButtonTitle:nil
											 otherButtonTitles:@"Take Photo", @"Camera Roll", nil];
				
			}
			else if (user.globalDraft == NO) {
				actions = [[UIActionSheet alloc] initWithTitle:@"Select Photo Source"
													  delegate:self
											 cancelButtonTitle:@"Cancel"
										destructiveButtonTitle:nil
											 otherButtonTitles:@"Camera Roll", @"My Albums", @"Library", nil];
			}
			else {
				actions = [[UIActionSheet alloc] initWithTitle:@"Select Photo Source"
													  delegate:self
											 cancelButtonTitle:@"Cancel"
										destructiveButtonTitle:nil
											 otherButtonTitles:@"Camera Roll", nil];
			}
			
			[actions showInView:self.view];
			
		}
		else if (indexPath.section == 1 && indexPath.row == 0) {
			DateViewController *dvc = [[DateViewController alloc] initWithNibName:nil bundle:nil];
			[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/date/" withError:nil];
			NSTimeInterval timestamp = tempDate;
			NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
			dvc.theDate = date;
			dvc.delegate = self;
			User *user = [User sharedUser];
			user.editingBlog = YES;
			[self presentViewController:dvc animated:YES completion:nil];
		}
		else if (indexPath.section == 1 && indexPath.row == 1 && blog.blogid == nil) {
			[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/location/" withError:nil];
			LocationViewController *lvc = [[LocationViewController alloc]initWithNibName:nil bundle:nil];
			lvc.state = tempState;
			lvc.area = tempArea;
			lvc.geolocation = tempGeolocation;
			lvc.delegate = self;
			User *user = [User sharedUser];
			user.editingBlog = YES;
			[self presentViewController:lvc animated:YES completion:nil];
		}
		else if (indexPath.section == 2 && indexPath.row == 0) {
			[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/body/" withError:nil];
			BodyTextViewController *btvc = [[BodyTextViewController alloc] initWithNibName:nil bundle:nil];
			btvc.delegate = self;
			btvc.body = tempBody;
			User *user = [User sharedUser];
			user.editingBlog = YES;
			[self presentViewController:btvc animated:YES completion:nil];
		}
	}
	else {
		if (indexPath.section == 0) {
			[self showPhoto];
		}
	}
}

#pragma mark UIActionSheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([actionSheet.title isEqualToString:@"Select Photo Source"]) {
		User *user = [User sharedUser];
		if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			if (pickerView == nil) {
				pickerView = [[UIImagePickerController alloc] init];
                pickerView.navigationBar.barStyle = UIBarStyleBlack;
                pickerView.navigationBar.translucent = true;
				pickerView.delegate = self;
			}
			pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
			[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/photo/camera/" withError:nil];
			[self presentViewController:pickerView animated:YES completion:nil];
		}
		else if ((buttonIndex == 0 && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) || (buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])) {
			if (pickerView == nil) {
				pickerView = [[UIImagePickerController alloc] init];
                pickerView.navigationBar.barStyle = UIBarStyleBlack;
                pickerView.navigationBar.translucent = true;
				pickerView.delegate = self;
			}
			[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/photo/photo_library/" withError:nil];
			pickerView.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentViewController:pickerView animated:YES completion:nil];
		}
		else if ((buttonIndex == 1 && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && user.globalDraft == NO) || (buttonIndex == 2 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && user.globalDraft == NO)) {
			RegionImagePickerViewController *regionPickerView = [[RegionImagePickerViewController alloc] init];
			regionPickerView.regionImages = NO;
			regionPickerView.title = @"My Albums";
			regionPickerView.delegate = self;
			[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/photo/user_photo/" withError:nil];
			[self presentViewController:regionPickerView animated:YES completion:nil];
		}
		else if (((buttonIndex == 2 && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) && user.globalDraft == NO) || (buttonIndex == 3 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])) {
			RegionImagePickerViewController *regionPickerView = [[RegionImagePickerViewController alloc] init];
			regionPickerView.regionImages = YES;
			if (tempState[@"name"] != nil) {
				regionPickerView.stateSubdivider = tempState[@"name"];
			}
			regionPickerView.delegate = self;
			[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/photo/web_library/" withError:nil];
			[self presentViewController:regionPickerView animated:YES completion:nil];
		}
		
	}
	else if ([actionSheet.title isEqualToString:@"Confirm Blog Delete"]) {
		if (self.editing == YES && buttonIndex == 0) {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"autoSavedBlog"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			if (self.blog.draft == YES) {
				[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/delete/draft/" withError:nil];
				[self.allBlogs deleteBlog:self.blog];
				[delegate blogViewControllerDidDeleteBlog:self];
			}
			else {
				[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/delete/" withError:nil];
				User *user = [User sharedUser];
				NSString *url = [connex buildOffexRequestStringWithURI:[[[[[@"user/" stringByAppendingString:user.username] 
																		   stringByAppendingString:@"/trip/"] 
																		  stringByAppendingString:(blog.trip)[@"urlSlug"]] 
																		 stringByAppendingString:@"/blog/"] 
																		stringByAppendingString:blog.blogid]];
				[connex deleteOffexploringDataAtUrl:url];
				HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
				[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
				HUD.delegate = self;
				HUD.labelText = @"Deleting...";
				[HUD show:YES];
			}
			User *user = [User sharedUser];
			user.autoSavedBlog = nil;
		}
	}
	else if ([actionSheet.title isEqualToString:@"Are you sure you wish to cancel? You will lose any unsaved changes!"]) {
		if (buttonIndex == 0) {
			NSFileManager *fileManager = [NSFileManager defaultManager]; 
			NSString *pngPath = [self.blog getTempImageFilePath];
			[fileManager removeItemAtPath:pngPath error:nil];
			pngPath = [self.blog getTempThumbImageFilePath];
			[fileManager removeItemAtPath:pngPath error:nil];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"autoSavedBlog"];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"autoSavedBodyText"];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"autoSavedDate"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			User *user = [User sharedUser];
			user.autoSavedBlog = nil;
			[delegate blogViewControllerDidDiscardChanges:self];
		}
	}
	else {
		User *user = [User sharedUser];
		
		if (self.editing == YES && buttonIndex == 0) {
			[self saveChanges];
			NSString *prepath = [[NSString alloc] initWithFormat:@"%d.blog",blog.original_timestamp]; 
			NSString *filePath = [[self pathForDataFile] stringByAppendingPathComponent:prepath];
			[NSKeyedArchiver archiveRootObject:self.blog toFile:filePath];
			[delegate blogViewController:self didFinishEditingBlog:self.blog];
		}
		else if (self.editing == YES && buttonIndex == 1 && user.globalDraft == NO) {
			[self beginPosting];
		}
	}
}

#pragma mark RegionImagePickerViewController Delegate Methods

- (void)regionImagePickerViewController:(RegionImagePickerViewController *)rigvc didSelectPhoto:(Photo *)photo andImage:(UIImage *)image andThumbnail:(UIImage *)thumb{	
	
	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	NSString *pngPath = [self.blog getTempImageFilePath];
	[fileManager removeItemAtPath:pngPath error:nil];   
	pngPath = [self.blog getTempThumbImageFilePath];
	[fileManager removeItemAtPath:pngPath error:nil];
	
	if (image != nil) {
		
		NSString *pngPath = [self.blog getTempImageFilePath];
		[UIImageJPEGRepresentation(image, 1.0) writeToFile:pngPath atomically:YES];
		pngPath = [self.blog getTempThumbImageFilePath];
		[UIImageJPEGRepresentation(thumb, 0.75) writeToFile:pngPath atomically:YES];
	}
	
	tempImageURI = photo.imageURI;	
	User *user = [User sharedUser];
	(user.autoSavedBlog)[@"tempImageURI"] = tempImageURI;
	[self.tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) regionImagePickerViewControllerDidCancel:(RegionImagePickerViewController *)rigvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *thePhoto = info[UIImagePickerControllerOriginalImage];
    
	HUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
	[[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = @"Saving...";
	HUD.detailsLabelText = @"Please do not close the application!";
	[HUD show:YES];
	
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		self.saveToLibrary = YES;
	}
	else {
		self.saveToLibrary = NO;
	}
	
	[self saveImage:thePhoto];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark DateViewController Delegate Methods

- (void)dateViewController:(DateViewController *)dvc didSaveWithDate:(NSDate *)date {
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
	NSTimeInterval timestamp = [date timeIntervalSince1970];
	tempDate = timestamp;
	User *user = [User sharedUser];
	(user.autoSavedBlog)[@"tempDate"] = @(tempDate);
	user.editingBlog = NO;
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"autoSavedDate"];
	[tableView reloadData];
}

- (void)dateViewControllerDidCancel:(DateViewController *)dvc {
	User *user = [User sharedUser];
	user.editingBlog = NO;
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark LocationViewController Delegate Method
- (void)locationViewController:(LocationViewController *)dvc 
            didFinishWithState:(NSDictionary *)state 
                      withArea:(NSDictionary *)area
               withGeolocation:(NSDictionary *)geolocation {
	
    self.tempState = state;
	self.tempArea = area;
	self.tempGeolocation = geolocation;
	User *user = [User sharedUser];
	if (tempArea) {
		(user.autoSavedBlog)[@"tempArea"] = tempArea;
	}
	if (tempState) {
		(user.autoSavedBlog)[@"tempState"] = tempState;
	}
	if (tempGeolocation) {
		(user.autoSavedBlog)[@"tempGeolocation"] = tempGeolocation;
	}
	user.editingBlog = NO;
	[self.tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark BodyTextViewController Delegate Methods

- (void)bodyTextViewController:(BodyTextViewController *)btvc didFinishEditingBody:(NSString *)bodyText {
	User *user = [User sharedUser];
	user.editingBlog = NO;
	if ([bodyText isEqualToString:@""]) {
		tempBody = @"Start typing your blog..";
	}
	else {
		tempBody = bodyText;
		(user.autoSavedBlog)[@"tempBody"] = tempBody;
	}	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"autoSavedBodyText"];
	[self.tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)bodyTextViewControllerShouldDisplayCancelWarning:(BodyTextViewController *)btvc {
	return YES;
}

- (void)bodyTextViewControllerDidCancel:(BodyTextViewController *)btvc {
	User *user = [User sharedUser];
	user.editingBlog = NO;
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ImageLoader Delegate Method

- (void)imageLoader:(ImageLoader *)loader didLoadImage:(UIImage *)image forURI:(NSString *)uri {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	BlogHeaderTableViewCell *cell = (BlogHeaderTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	[cell.blogThumbButton setBackgroundImage:image forState:UIControlStateNormal];
	NSString *pngPath = [self.blog getThumbImageFilePath];
	[UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
	for (id anObject in cell.subviews) {
		if ([anObject isKindOfClass:[UIActivityIndicatorView class]]) {
			UIActivityIndicatorView *indication = (UIActivityIndicatorView *)anObject;
			[indication stopAnimating];
		}
	}
}

#pragma mark UIAlertView Delegate Method

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([alertView.title isEqualToString:@"Update Failed"]) {
		if (buttonIndex == 1) {
			self.blog.blogid = nil;
			[self performSelectorOnMainThread:@selector(beginPosting) withObject:nil waitUntilDone:NO];
		}
	}
	else if ([alertView.title isEqualToString:@"Publishing Failed"]) {
		if (buttonIndex == 1) {
			[self performSelectorOnMainThread:@selector(beginPosting) withObject:nil waitUntilDone:NO];
		}
	}
	else {
		if (buttonIndex == 0) {
			[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/edit/location/" withError:nil];
			LocationViewController *lvc = [[LocationViewController alloc]initWithNibName:nil bundle:nil];
			lvc.state = tempState;
			lvc.area = tempArea;
			lvc.geolocation = tempGeolocation;
			lvc.delegate = self;
			[self presentViewController:lvc animated:YES completion:nil];
		}
	}
}

#pragma mark BlogViewController Delegate Methods

- (void)blogViewController:(BlogViewController *)bvc didFinishEditingBlog:(Blog *)editedBlog {
	[self.allBlogs addBlog:editedBlog];
	self.blog = editedBlog;
    if (!self.blog.draft) {
        [self.commentsButton setEnabled:YES];
    }
    else {
        [self.commentsButton setEnabled:NO];
    }
    [self.tableView reloadData];
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)blogViewControllerDidDiscardChanges:(BlogViewController *)bvc {
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/" withError:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)blogViewControllerDidDeleteBlog:(BlogViewController *)bvc {
	[self dismissViewControllerAnimated:YES completion:nil];
	[[GANTracker sharedTracker] trackPageview:@"/home/blogs/entries/blog/" withError:nil];
	[self.navigationController popViewControllerAnimated:NO];
}

#pragma mark MBProgressHUD Delegate Method

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
	HUD = nil;
}

@end
