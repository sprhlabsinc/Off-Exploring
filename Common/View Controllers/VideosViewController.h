//
//  VideosViewController.h
//  Off Exploring
//
//  Created by Ian Outterside on 06/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Trip.h"
#import "Video.h"
#import "OffexConnex.h"
#import "ImageLoader.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VideoViewController.h"
#import "MBProgressHUD.h"

@interface VideosViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, OffexploringConnectionDelegate, ImageLoaderDelegate, UIScrollViewDelegate, VideoViewControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate> {

    OffexConnex *connex;

    /**
     A repositry of active image downloads to stop double image requests
	 */
	NSMutableDictionary *activeDownloads;
    
    /**
     A UIImagePickerController object used to pick videos from a users video library, or to access the camera
	 */
	UIImagePickerController *pickerView;
    
    /**
     A utility loading view to display whilst making remote requests
	 */
	MBProgressHUD *HUD;
    
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) Trip *activeTrip;
@property (nonatomic, assign) BOOL downloadedData;
@property (nonatomic, strong) UIImagePickerController *pickerView;

- (void)downloadVideos;

@end
