//
//  PSHDataStore.h
//  Knowns
//
//  Created by PARK SANG HYUN on 5/24/15.
//  Copyright (c) 2015 PARK SANG HYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSHDataStore : NSObject

+ (instancetype)sharedStore;

//현재 보이는 화면의 가로크기
@property CGFloat xSizeOfMainScreen;

//네비게이션바를 제외한 메인 UI 가 시작되는 Y축 좌표
@property CGFloat yStartingPosOfMainUI;

//PSHEventPickController의 뷰 사이즈(높이)를 저장
@property CGFloat PSHEventPickController_Height;

@property NSInteger isEventImageViewClicked;

// 이벤트 이미지의 크기 (가로, 세로 동일)
@property CGFloat sizeOfEventImage;

@end
