//
//  PSHCalendarView.m
//  Knowns
//
//  Created by SANG HYUN PARK on 5/29/14.
//  Copyright (c) 2014 PARK SANG HYUN. All rights reserved.
//

#import "PSHCalendarView.h"


@implementation PSHCalendarView

- (instancetype)initWithFrame:(CGRect)frame backGroundColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // Initialization code
        self.backgroundColor = color;

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
