//
//  PSHCalendarDayLabel.m
//  Knowns
//
//  Created by SANG HYUN PARK on 5/29/14.
//  Copyright (c) 2014 PARK SANG HYUN. All rights reserved.
//

#import "PSHCalendarDayLabel.h"

@implementation PSHCalendarDayLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        //self.backgroundColor = [UIColor grayColor];

        [self setFont:[UIFont fontWithName:@"OpenSans" size:(([UIScreen mainScreen].bounds.size.width)*18)/320]];

        //[self setFont:[UIFont fontWithName:@"Noteworthy-Light" size:18]];
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
