//
//  PSHEventPickController.h
//  Knowns
//
//  Created by PARK SANG HYUN on 6/4/15.
//  Copyright (c) 2015 PARK SANG HYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSHEventPickControllerDelegate;

@interface PSHEventPickController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) id<PSHEventPickControllerDelegate> delegate;

@end

@protocol PSHEventPickControllerDelegate <NSObject>

- (void)pshEventPickController:(PSHEventPickController *)viewController isEventImageViewClicked:(NSInteger)value;

@end
