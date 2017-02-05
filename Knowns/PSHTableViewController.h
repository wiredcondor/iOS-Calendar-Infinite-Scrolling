//
//  PSHTableViewController.h
//  Knowns
//
//  Created by PARK SANG HYUN on 6/2/15.
//  Copyright (c) 2015 PARK SANG HYUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSHEventPickController.h"

@protocol  PSHTableViewControllerDelegate;

@interface PSHTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, PSHEventPickControllerDelegate>

@property (nonatomic, weak) id<PSHTableViewControllerDelegate> delegate;

@end

@protocol PSHTableViewControllerDelegate <NSObject>

- (void)pshTableViewController:(PSHTableViewController *)viewController isEventImageViewClicked:(NSInteger)value;

@end


