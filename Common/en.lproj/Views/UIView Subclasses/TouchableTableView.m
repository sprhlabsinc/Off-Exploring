//
//  TouchableTableView.m
//  Off Exploring
//
//  Created by Ian Outterside on 08/12/2011.
//  Copyright (c) 2011 Off Exploring Ltd. All rights reserved.
//

#import "TouchableTableView.h"

@implementation TouchableTableView

@synthesize touchDelegate = __delegate;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (__delegate && [__delegate respondsToSelector:@selector(tableView:wasTouchedWithTouches:andEvent:)]) {
        [__delegate tableView:self wasTouchedWithTouches:touches andEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

@end
