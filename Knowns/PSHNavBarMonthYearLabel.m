//
//  PSHNavBarMonthYearLabel.m
//  Knowns
//
//  Created by SANG HYUN PARK on 10/7/14.
//  Copyright (c) 2014 PARK SANG HYUN. All rights reserved.
//

#import "PSHNavBarMonthYearLabel.h"

@implementation PSHNavBarMonthYearLabel

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.textAlignment = NSTextAlignmentCenter;
        //self.backgroundColor = [UIColor clearColor];
        //self.backgroundColor = [UIColor colorWithRed:227.0 green:35.0 blue:37.0 alpha:1.0];
        //rgba(227, 35, 37, 1)
        //[self setFont:[UIFont fontWithName:@"Avenir-Medium" size:21]];
//        [self setFont:[UIFont fontWithName:@"Avenir-Medium" size:([UIScreen mainScreen].bounds.size.width*18)/320]];
//        [self setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:([UIScreen mainScreen].bounds.size.width*18)/320]];
        

        [self setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:([UIScreen mainScreen].bounds.size.width*18)/320]];
        //[self setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:20.0]];
        //[self setFont:[UIFont boldSystemFontOfSize:18]];

        
    }
    
    return self;
}

@end
