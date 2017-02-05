//
//  PSHDataStore.m
//  Knowns
//
//  Created by PARK SANG HYUN on 5/24/15.
//  Copyright (c) 2015 PARK SANG HYUN. All rights reserved.
//

#import "PSHDataStore.h"

@interface PSHDataStore ()

@end

@implementation PSHDataStore

+ (instancetype)sharedStore
{
    
    static PSHDataStore *sharedStore = nil;
    // Do I need to create a sharedStore?
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
}

- (instancetype)initPrivate
{
    self = [super init];
    
    //각 고정변수의 값을 초기화
    self.yStartingPosOfMainUI = [UIScreen mainScreen].bounds.size.height - 64.0;
    self.xSizeOfMainScreen = [UIScreen mainScreen].bounds.size.width;
    
    
    return self;
}

@end
