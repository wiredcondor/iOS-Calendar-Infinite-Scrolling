//
//  PSHWeekdayLabel.m
//  Knowns
//
//  Created by SANG HYUN PARK on 5/31/14.
//  Copyright (c) 2014 PARK SANG HYUN. All rights reserved.
//

#import "PSHWeekDayLabel.h"

@implementation PSHWeekDayLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textAlignment = NSTextAlignmentCenter;
        self.textColor = [UIColor lightGrayColor];
        //self.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor whiteColor];
        [self setFont:[UIFont fontWithName:@"OpenSans-Bold" size:([UIScreen mainScreen].bounds.size.width*12)/320]];
        //[self setFont:[UIFont fontWithName:@"Noteworthy-Bold" size:12]];
        //Noteworthy-Bold
        //([UIScreen mainScreen].bounds.size.width*12)/320

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
