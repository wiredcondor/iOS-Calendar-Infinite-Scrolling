//
//  PSHDayCircle.m
//  Knowns
//
//  Created by SANG HYUN PARK on 11/4/14.
//  Copyright (c) 2014 PARK SANG HYUN. All rights reserved.
//

#import "PSHDayCircle.h"

@implementation PSHDayCircle

- (instancetype)initWithFrame:(CGRect)frame;
{   
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        //self.circleColor = _circleColor;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //// Color Declarations

    //UIColor* color = [UIColor colorWithRed:0.755 green:0.844 blue:0.988 alpha:1];

    UIColor *color = self.circleColor;
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(rect.origin.x + 2.0, rect.origin.y + 2.0, rect.size.width - 4.0, rect.size.height - 4.0)];
    //UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
    
    [color setFill];
    [ovalPath fill];
    
}

- (void)setCircleColor:(UIColor *)circleColor
{
    _circleColor = circleColor;
    [self setNeedsDisplay];
}



@end
