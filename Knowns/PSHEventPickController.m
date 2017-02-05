//
//  PSHEventPickController.m
//  Knowns
//
//  Created by PARK SANG HYUN on 6/4/15.
//  Copyright (c) 2015 PARK SANG HYUN. All rights reserved.
//

// 원하는 이벤트 이미지 아이콘을 선택하는 최상단의 뷰

#import "PSHEventPickController.h"
#import "PSHDataStore.h"

@interface PSHEventPickController ()

@property PSHDataStore *pshDataStore;

// 제목뷰, 이미지 선택뷰, 스크롤뷰를 포함하는 최상위 뷰
@property UIView *eventView;

// 페이지 컨트롤을 포함할 스크롤뷰
@property (nonatomic)UIScrollView *scrollView;
// 페이지 컨트롤
@property (nonatomic)UIPageControl *pageControl;

// 상단에 아이콘의 카테고리 제목뷰
@property UILabel *titleOfCategory;

// 이벤트 이미지 및 이미지뷰 선언
@property UIImage *eventImage;
@property UIImageView *eventImageView;

// 이벤트 이미지 크기
@property CGFloat sizeOfImage;
// 이벤트 이미지 사이의 간격
@property CGFloat gapOfImage;

// eventImageView 의 클릭전 : 0, 클릭수 : 1
@property NSInteger isEventImageViewClicked;

@end

@implementation PSHEventPickController

- (void)loadView
{
    
    self.isEventImageViewClicked = 0;
    
    // PSHDataStore 초기화
    self.pshDataStore = [PSHDataStore sharedStore];
 
    // 이미지 사이의 간격
    //self.gapOfImage = (self.pshDataStore.xSizeOfMainScreen - (6.0 * self.sizeOfImage)) / 7.0;
    self.gapOfImage = 10.0;
    
    // |O|O|O|O|O|O|O| O|O|O|O|
    
    // 이벤트 이미지 크기
    //self.sizeOfImage = self.pshDataStore.xSizeOfMainScreen / 7.0;
    // 이미지 개수를 한줄에 5개
    self.sizeOfImage = (self.pshDataStore.xSizeOfMainScreen - (self.gapOfImage * 6.0)) / 5.0;
    self.pshDataStore.sizeOfEventImage = self.sizeOfImage;
    
    // eventView 의 크기
    CGFloat eventView_Height = 20.0 + (self.sizeOfImage * 2.0) + (self.gapOfImage * 2.0) + 10.0;
    CGFloat eventView_Width = self.pshDataStore.xSizeOfMainScreen * 3.0;
    
    // Debug
    //NSLog(@"PSHEventPickController:eventView_Height:%f", eventView_Height);    
    
    // 제목뷰 간격 + 이미지 2개 + 이미지 간격 3개 + 페이지컨트롤 간격 + 위아래라인뷰
    self.eventView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.pshDataStore.xSizeOfMainScreen, eventView_Height)];
    
    // 스크롤뷰 초기화 및 속성지정
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.eventView.frame.origin.y, self.pshDataStore.xSizeOfMainScreen, eventView_Height - 10.0)];
    self.scrollView.contentSize = CGSizeMake(eventView_Width, eventView_Height - 10.0);
    //self.scrollView.showsHorizontalScrollIndicator = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    [self.scrollView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];    
    self.scrollView.delegate = self;
    
    // 이벤트 이미지 카테고리 제목뷰
    self.titleOfCategory = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.0, self.pshDataStore.xSizeOfMainScreen, 20.0)];
    [self.titleOfCategory setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [self.titleOfCategory setTextColor:[UIColor colorWithRed:0.6465 green:0.6505 blue:0.6643 alpha:1.0]];
    //[self.titleOfCategory setFont:[UIFont fontWithName:@"OpenSans-Bold" size:([UIScreen mainScreen].bounds.size.width*12)/320]];
    [self.titleOfCategory setFont:[UIFont fontWithName:@"OpenSans-Bold" size:13.0]];
    [self.titleOfCategory setText:[NSString stringWithFormat:@"    ACTIVITY"]];//5칸
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // 우선 테스트를 위해 추가하는 것임
    // 2페이지 이벤트 이미지 카테고리 제목뷰
    UILabel *titleOfCategory_2P = [[UILabel alloc] initWithFrame:CGRectMake(self.pshDataStore.xSizeOfMainScreen, 0.0, self.pshDataStore.xSizeOfMainScreen, 20.0)];
    [titleOfCategory_2P setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [titleOfCategory_2P setTextColor:[UIColor colorWithRed:0.6465 green:0.6505 blue:0.6643 alpha:1.0]];
    [titleOfCategory_2P setFont:[UIFont fontWithName:@"OpenSans-Bold" size:13.0]];
    [titleOfCategory_2P setText:[NSString stringWithFormat:@"    FOOD & DRINK"]];//5칸
    
    
    // 3페이지 이벤트 이미지 카테고리 제목뷰
    UILabel *titleOfCategory_3P = [[UILabel alloc] initWithFrame:CGRectMake((self.pshDataStore.xSizeOfMainScreen * 2), 0.0, self.pshDataStore.xSizeOfMainScreen, 20.0)];
    [titleOfCategory_3P setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [titleOfCategory_3P setTextColor:[UIColor colorWithRed:0.6465 green:0.6505 blue:0.6643 alpha:1.0]];
    [titleOfCategory_3P setFont:[UIFont fontWithName:@"OpenSans-Bold" size:13.0]];
    [titleOfCategory_3P setText:[NSString stringWithFormat:@"    SOCIAL"]];//5칸
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    // 이미지 및 이미지뷰 선언
    NSString *eventImageName = @"Sports-21.png";
    self.eventImage = [UIImage imageNamed:eventImageName];
    self.eventImageView = [[UIImageView alloc] initWithImage:self.eventImage];    
    //[self.eventImageView setFrame:CGRectMake(self.gapOfImage, 20.0 + self.gapOfImage, self.sizeOfImage, self.sizeOfImage)];
    [self.eventImageView setFrame:CGRectMake(self.gapOfImage, 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    
    [self.eventImageView setUserInteractionEnabled:YES];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // 우선 테스트를 위해 추가하는 것임 - 추가한 것들은 우선 어떻게 보일지 살펴보기 위함이므로 코드가 지저분함
    
    // 1페이지 1행 1열~5열
    NSString *eventImageName_1_2 = @"Nature-03.png";
    UIImage *eventImage_1_2 = [UIImage imageNamed:eventImageName_1_2];
    UIImageView *eventImageView_1_2 = [[UIImageView alloc] initWithImage:eventImage_1_2];
    [eventImageView_1_2 setFrame:CGRectMake(self.eventImageView.bounds.size.width + (2 * self.gapOfImage), 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_1_3 = @"Sports-03.png";
    UIImage *eventImage_1_3 = [UIImage imageNamed:eventImageName_1_3];
    UIImageView *eventImageView_1_3 = [[UIImageView alloc] initWithImage:eventImage_1_3];
    [eventImageView_1_3 setFrame:CGRectMake((self.eventImageView.bounds.size.width * 2) + (3 * self.gapOfImage), 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_1_4 = @"Sports-11.png";
    UIImage *eventImage_1_4 = [UIImage imageNamed:eventImageName_1_4];
    UIImageView *eventImageView_1_4 = [[UIImageView alloc] initWithImage:eventImage_1_4];
    [eventImageView_1_4 setFrame:CGRectMake((self.eventImageView.bounds.size.width * 3) + (4 * self.gapOfImage), 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_1_5 = @"Travel-and-Transportation-17.png";
    UIImage *eventImage_1_5 = [UIImage imageNamed:eventImageName_1_5];
    UIImageView *eventImageView_1_5 = [[UIImageView alloc] initWithImage:eventImage_1_5];
    [eventImageView_1_5 setFrame:CGRectMake((self.eventImageView.bounds.size.width * 4) + (5 * self.gapOfImage), 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    //1페이지 2행 1열~5열
    NSString *eventImageName_2_1 = @"Travel-and-Transportation-01.png";
    UIImage *eventImage_2_1 = [UIImage imageNamed:eventImageName_2_1];
    UIImageView *eventImageView_2_1 = [[UIImageView alloc] initWithImage:eventImage_2_1];
    [eventImageView_2_1 setFrame:CGRectMake(self.gapOfImage, 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_2_2 = @"Travel-and-Transportation-20.png";
    UIImage *eventImage_2_2 = [UIImage imageNamed:eventImageName_2_2];
    UIImageView *eventImageView_2_2 = [[UIImageView alloc] initWithImage:eventImage_2_2];
    [eventImageView_2_2 setFrame:CGRectMake(self.eventImageView.bounds.size.width + (2 * self.gapOfImage), 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_2_3 = @"shopping-18.png";
    UIImage *eventImage_2_3 = [UIImage imageNamed:eventImageName_2_3];
    UIImageView *eventImageView_2_3 = [[UIImageView alloc] initWithImage:eventImage_2_3];
    [eventImageView_2_3 setFrame:CGRectMake((self.eventImageView.bounds.size.width * 2) + (3 * self.gapOfImage), 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_2_4 = @"Party-17.png";
    UIImage *eventImage_2_4 = [UIImage imageNamed:eventImageName_2_4];
    UIImageView *eventImageView_2_4 = [[UIImageView alloc] initWithImage:eventImage_2_4];
    [eventImageView_2_4 setFrame:CGRectMake((self.eventImageView.bounds.size.width * 3) + (4 * self.gapOfImage), 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_2_5 = @"Party-19.png";
    UIImage *eventImage_2_5 = [UIImage imageNamed:eventImageName_2_5];
    UIImageView *eventImageView_2_5 = [[UIImageView alloc] initWithImage:eventImage_2_5];
    [eventImageView_2_5 setFrame:CGRectMake((self.eventImageView.bounds.size.width * 4) + (5 * self.gapOfImage), 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    //2페이지 1행 1열~5열
    NSString *eventImageName_2P_1_1 = @"Food-15.png";
    UIImage *eventImage_2P_1_1 = [UIImage imageNamed:eventImageName_2P_1_1];
    UIImageView *eventImageView_2P_1_1 = [[UIImageView alloc] initWithImage:eventImage_2P_1_1];
    [eventImageView_2P_1_1 setFrame:CGRectMake(self.pshDataStore.xSizeOfMainScreen + self.gapOfImage, 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_2P_1_2 = @"Food-02.png";
    UIImage *eventImage_2P_1_2 = [UIImage imageNamed:eventImageName_2P_1_2];
    UIImageView *eventImageView_2P_1_2 = [[UIImageView alloc] initWithImage:eventImage_2P_1_2];
    [eventImageView_2P_1_2 setFrame:CGRectMake(self.pshDataStore.xSizeOfMainScreen + (self.eventImageView.bounds.size.width) + (2 * self.gapOfImage), 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_2P_1_3 = @"Food-06.png";
    UIImage *eventImage_2P_1_3 = [UIImage imageNamed:eventImageName_2P_1_3];
    UIImageView *eventImageView_2P_1_3 = [[UIImageView alloc] initWithImage:eventImage_2P_1_3];
    [eventImageView_2P_1_3 setFrame:CGRectMake(self.pshDataStore.xSizeOfMainScreen + (self.eventImageView.bounds.size.width * 2) + (3 * self.gapOfImage), 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_2P_1_4 = @"Food-10.png";
    UIImage *eventImage_2P_1_4 = [UIImage imageNamed:eventImageName_2P_1_4];
    UIImageView *eventImageView_2P_1_4 = [[UIImageView alloc] initWithImage:eventImage_2P_1_4];
    [eventImageView_2P_1_4 setFrame:CGRectMake(self.pshDataStore.xSizeOfMainScreen + (self.eventImageView.bounds.size.width * 3) + (4 * self.gapOfImage), 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_2P_1_5 = @"Food-16.png";
    UIImage *eventImage_2P_1_5 = [UIImage imageNamed:eventImageName_2P_1_5];
    UIImageView *eventImageView_2P_1_5 = [[UIImageView alloc] initWithImage:eventImage_2P_1_5];
    [eventImageView_2P_1_5 setFrame:CGRectMake(self.pshDataStore.xSizeOfMainScreen + (self.eventImageView.bounds.size.width * 4) + (5 * self.gapOfImage), 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    //2페이지 2행 1열~5열
    NSString *eventImageName_2P_2_1 = @"Food-17.png";
    UIImage *eventImage_2P_2_1 = [UIImage imageNamed:eventImageName_2P_2_1];
    UIImageView *eventImageView_2P_2_1 = [[UIImageView alloc] initWithImage:eventImage_2P_2_1];
    [eventImageView_2P_2_1 setFrame:CGRectMake(self.pshDataStore.xSizeOfMainScreen + self.gapOfImage, 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_2P_2_2 = @"Food-19.png";
    UIImage *eventImage_2P_2_2 = [UIImage imageNamed:eventImageName_2P_2_2];
    UIImageView *eventImageView_2P_2_2 = [[UIImageView alloc] initWithImage:eventImage_2P_2_2];
    [eventImageView_2P_2_2 setFrame:CGRectMake(self.pshDataStore.xSizeOfMainScreen + (self.eventImageView.bounds.size.width) + (2 * self.gapOfImage), 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_2P_2_3 = @"Food-20.png";
    UIImage *eventImage_2P_2_3 = [UIImage imageNamed:eventImageName_2P_2_3];
    UIImageView *eventImageView_2P_2_3 = [[UIImageView alloc] initWithImage:eventImage_2P_2_3];
    [eventImageView_2P_2_3 setFrame:CGRectMake(self.pshDataStore.xSizeOfMainScreen + (self.eventImageView.bounds.size.width * 2) + (3 * self.gapOfImage), 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_2P_2_4 = @"Food-28.png";
    UIImage *eventImage_2P_2_4 = [UIImage imageNamed:eventImageName_2P_2_4];
    UIImageView *eventImageView_2P_2_4 = [[UIImageView alloc] initWithImage:eventImage_2P_2_4];
    [eventImageView_2P_2_4 setFrame:CGRectMake(self.pshDataStore.xSizeOfMainScreen + (self.eventImageView.bounds.size.width * 3) + (4 * self.gapOfImage), 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_2P_2_5 = @"Food-30.png";
    UIImage *eventImage_2P_2_5 = [UIImage imageNamed:eventImageName_2P_2_5];
    UIImageView *eventImageView_2P_2_5 = [[UIImageView alloc] initWithImage:eventImage_2P_2_5];
    [eventImageView_2P_2_5 setFrame:CGRectMake(self.pshDataStore.xSizeOfMainScreen + (self.eventImageView.bounds.size.width * 4) + (5 * self.gapOfImage), 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    //3페이지 1행 1열~5열
    NSString *eventImageName_3P_1_1 = @"social-media-04.png";
    UIImage *eventImage_3P_1_1 = [UIImage imageNamed:eventImageName_3P_1_1];
    UIImageView *eventImageView_3P_1_1 = [[UIImageView alloc] initWithImage:eventImage_3P_1_1];
    [eventImageView_3P_1_1 setFrame:CGRectMake((self.pshDataStore.xSizeOfMainScreen * 2) + self.gapOfImage, 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_3P_1_2 = @"social-media-07.png";
    UIImage *eventImage_3P_1_2 = [UIImage imageNamed:eventImageName_3P_1_2];
    UIImageView *eventImageView_3P_1_2 = [[UIImageView alloc] initWithImage:eventImage_3P_1_2];
    [eventImageView_3P_1_2 setFrame:CGRectMake((self.pshDataStore.xSizeOfMainScreen * 2) + (self.eventImageView.bounds.size.width) + (2 * self.gapOfImage), 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_3P_1_3 = @"social-media-09.png";
    UIImage *eventImage_3P_1_3 = [UIImage imageNamed:eventImageName_3P_1_3];
    UIImageView *eventImageView_3P_1_3 = [[UIImageView alloc] initWithImage:eventImage_3P_1_3];
    [eventImageView_3P_1_3 setFrame:CGRectMake((self.pshDataStore.xSizeOfMainScreen * 2) + (self.eventImageView.bounds.size.width * 2) + (3 * self.gapOfImage), 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_3P_1_4 = @"social-media-12.png";
    UIImage *eventImage_3P_1_4 = [UIImage imageNamed:eventImageName_3P_1_4];
    UIImageView *eventImageView_3P_1_4 = [[UIImageView alloc] initWithImage:eventImage_3P_1_4];
    [eventImageView_3P_1_4 setFrame:CGRectMake((self.pshDataStore.xSizeOfMainScreen * 2) + (self.eventImageView.bounds.size.width * 3) + (4 * self.gapOfImage), 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_3P_1_5 = @"social-media-13.png";
    UIImage *eventImage_3P_1_5 = [UIImage imageNamed:eventImageName_3P_1_5];
    UIImageView *eventImageView_3P_1_5 = [[UIImageView alloc] initWithImage:eventImage_3P_1_5];
    [eventImageView_3P_1_5 setFrame:CGRectMake((self.pshDataStore.xSizeOfMainScreen * 2) + (self.eventImageView.bounds.size.width * 4) + (5 * self.gapOfImage), 20.0 + 5.0, self.sizeOfImage, self.sizeOfImage)];
    
    //3페이지 2행 1열~5열
    NSString *eventImageName_3P_2_1 = @"social-media-16.png";
    UIImage *eventImage_3P_2_1 = [UIImage imageNamed:eventImageName_3P_2_1];
    UIImageView *eventImageView_3P_2_1 = [[UIImageView alloc] initWithImage:eventImage_3P_2_1];
    [eventImageView_3P_2_1 setFrame:CGRectMake((self.pshDataStore.xSizeOfMainScreen * 2) + self.gapOfImage, 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_3P_2_2 = @"social-media-21.png";
    UIImage *eventImage_3P_2_2 = [UIImage imageNamed:eventImageName_3P_2_2];
    UIImageView *eventImageView_3P_2_2 = [[UIImageView alloc] initWithImage:eventImage_3P_2_2];
    [eventImageView_3P_2_2 setFrame:CGRectMake((self.pshDataStore.xSizeOfMainScreen * 2) + (self.eventImageView.bounds.size.width) + (2 * self.gapOfImage), 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_3P_2_3 = @"social-media-22.png";
    UIImage *eventImage_3P_2_3 = [UIImage imageNamed:eventImageName_3P_2_3];
    UIImageView *eventImageView_3P_2_3 = [[UIImageView alloc] initWithImage:eventImage_3P_2_3];
    [eventImageView_3P_2_3 setFrame:CGRectMake((self.pshDataStore.xSizeOfMainScreen * 2) + (self.eventImageView.bounds.size.width * 2) + (3 * self.gapOfImage), 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_3P_2_4 = @"social-media-27.png";
    UIImage *eventImage_3P_2_4 = [UIImage imageNamed:eventImageName_3P_2_4];
    UIImageView *eventImageView_3P_2_4 = [[UIImageView alloc] initWithImage:eventImage_3P_2_4];
    [eventImageView_3P_2_4 setFrame:CGRectMake((self.pshDataStore.xSizeOfMainScreen * 2) + (self.eventImageView.bounds.size.width * 3) + (4 * self.gapOfImage), 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];
    
    NSString *eventImageName_3P_2_5 = @"social-media-30.png";
    UIImage *eventImage_3P_2_5 = [UIImage imageNamed:eventImageName_3P_2_5];
    UIImageView *eventImageView_3P_2_5 = [[UIImageView alloc] initWithImage:eventImage_3P_2_5];
    [eventImageView_3P_2_5 setFrame:CGRectMake((self.pshDataStore.xSizeOfMainScreen * 2) + (self.eventImageView.bounds.size.width * 4) + (5 * self.gapOfImage), 20.0 + 5.0 + self.gapOfImage + self.sizeOfImage, self.sizeOfImage, self.sizeOfImage)];

    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    // 이벤트 이미지를 탭할때
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [self.eventImageView addGestureRecognizer:tapGesture];
    
    // 페이지 컨트롤 선언 및 속성지정
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.origin.y + self.scrollView.frame.size.height, self.pshDataStore.xSizeOfMainScreen, 10.0)];
    self.pageControl.numberOfPages = 3;
    self.pageControl.currentPage = 0;
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.287 green:0.3291 blue:0.3833 alpha:1.0];
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.6884 green:0.7066 blue:0.7303 alpha:1.0];
    [self.pageControl setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];

    // Add Views
    
    [self.scrollView addSubview:self.titleOfCategory];
    [self.scrollView addSubview:self.eventImageView];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // 우선 테스트를 위한 추가한 것임
    [self.scrollView addSubview:eventImageView_1_2];
    [self.scrollView addSubview:eventImageView_1_3];
    [self.scrollView addSubview:eventImageView_1_4];
    [self.scrollView addSubview:eventImageView_1_5];
    
    [self.scrollView addSubview:eventImageView_2_1];
    [self.scrollView addSubview:eventImageView_2_2];
    [self.scrollView addSubview:eventImageView_2_3];
    [self.scrollView addSubview:eventImageView_2_4];
    [self.scrollView addSubview:eventImageView_2_5];
    
    [self.scrollView addSubview:titleOfCategory_2P];
    
    [self.scrollView addSubview:eventImageView_2P_1_1];
    [self.scrollView addSubview:eventImageView_2P_1_2];
    [self.scrollView addSubview:eventImageView_2P_1_3];
    [self.scrollView addSubview:eventImageView_2P_1_4];
    [self.scrollView addSubview:eventImageView_2P_1_5];
    
    [self.scrollView addSubview:eventImageView_2P_2_1];
    [self.scrollView addSubview:eventImageView_2P_2_2];
    [self.scrollView addSubview:eventImageView_2P_2_3];
    [self.scrollView addSubview:eventImageView_2P_2_4];
    [self.scrollView addSubview:eventImageView_2P_2_5];
    
    [self.scrollView addSubview:titleOfCategory_3P];
    
    [self.scrollView addSubview:eventImageView_3P_1_1];
    [self.scrollView addSubview:eventImageView_3P_1_2];
    [self.scrollView addSubview:eventImageView_3P_1_3];
    [self.scrollView addSubview:eventImageView_3P_1_4];
    [self.scrollView addSubview:eventImageView_3P_1_5];
    
    [self.scrollView addSubview:eventImageView_3P_2_1];
    [self.scrollView addSubview:eventImageView_3P_2_2];
    [self.scrollView addSubview:eventImageView_3P_2_3];
    [self.scrollView addSubview:eventImageView_3P_2_4];
    [self.scrollView addSubview:eventImageView_3P_2_5];

    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    [self.eventView addSubview:self.scrollView];
    [self.eventView addSubview:self.pageControl];
    
    // PSHDataStore 에 eventView 의 크기를 저장
    self.pshDataStore.PSHEventPickController_Height = self.eventView.frame.size.height;    
    
    //self View
    self.view = self.eventView;
}

// 이벤트 이미지를 탭할때
- (void)tapHandler:(UITapGestureRecognizer *)tap
{
    NSLog(@" ");
    NSLog(@"PSHEventPickController:tapHandler:");
    
    // 우선 여기까지
    self.isEventImageViewClicked = 1;
    self.pshDataStore.isEventImageViewClicked = self.isEventImageViewClicked;
    
    // 작동할려나 모르겠다, 작동한다, 잘 보이지는 않는듯..
    [self.eventImageView setAlpha:0.5];
    
    // 여기부터 다시,
    // 현재뷰가 포함된 테이블 뷰상에서 선택된 이미지뷰와 텍스트입력화면, UISwitch 뷰등이 포함된 뷰로 대체하는 구현
    
    // 우선 먼저 구현할것은
    
    // 1. PSHEventPickController 상에서 이벤트 이미지를 클릭했을때 선택된 이벤트 관련정보가 들어갈 뷰를 나타나게 하는것
    //    - 나타날 방향은 왼쪽에서 오른쪽?, 위쪽에서 아래쪽?
    //
    
    id<PSHEventPickControllerDelegate> strongDelegate = self.delegate;
    
    if([strongDelegate respondsToSelector:@selector(pshEventPickController:isEventImageViewClicked:)]) {
        [strongDelegate pshEventPickController:self isEventImageViewClicked:self.isEventImageViewClicked];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"PSHEventSelectionController : scroll");
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    
    if (contentOffsetX == self.pshDataStore.xSizeOfMainScreen) {
        
        NSLog(@"PSHEventSelectionController : 2ND page");
        
        self.pageControl.currentPage = 1;
        
    } else if (contentOffsetX == self.pshDataStore.xSizeOfMainScreen * 2.0) {
        
        NSLog(@"PSHEventSelectionController : 3RD page");
        
        self.pageControl.currentPage = 2;
        
    } else if (contentOffsetX == 0) {
        
        self.pageControl.currentPage = 0;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end