//
//  SearchViewController.h
//  Off Exploring
//
//  Created by Ian Outterside on 26/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>


@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end
