//
//  TouchableTableView.h
//  Off Exploring
//
//  Created by Ian Outterside on 08/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TouchableTableViewDelegate <NSObject>

- (void)tableView:(UITableView *)tableView wasTouchedWithTouches:(NSSet *)touches andEvent:(UIEvent *)event;

@end

@interface TouchableTableView : UITableView

@property (nonatomic, weak) IBOutlet id <TouchableTableViewDelegate> touchDelegate;

@end
