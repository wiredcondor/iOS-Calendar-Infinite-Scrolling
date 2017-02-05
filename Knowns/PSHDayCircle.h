//
//  PSHDayCircle.h
//  Knowns
//
//  Created by SANG HYUN PARK on 11/4/14.
//  Copyright (c) 2014 PARK SANG HYUN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSHDayCircle : UIView

@property (nonatomic) UIColor *circleColor;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)drawRect:(CGRect)rect;
- (void)setCircleColor:(UIColor *)circleColor;

@end
