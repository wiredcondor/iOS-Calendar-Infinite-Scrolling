//
//  PSHCalendarViewController.m
//  Knowns
//
//  Created by SANG HYUN PARK on 1/20/17.
//  Copyright (c) 2017 PARK SANG HYUN. All rights reserved.
//

// Fantastical 캘린더 앱에서 사용하는 기본적인 달력 스크롤 및 터치 동작을 자체적으로 유사하게 구현, 보유함으로써
// 추후 다른 곳에 유용하게 활용하기 위해서 만들었습니다.

// 메인 캘린더를 위해 세개의 뷰만을 사용합니다. (이전달(첫번째뷰), 이번달(두번째뷰), 다음달(세번째뷰))

// 사용자가 달력을 스크롤하여 이전달 혹은 다음달로 이동하지만
// 실제 화면상에 보이는 뷰는 항상 두번째 뷰입니다.

// 사용자가 어디로 스크롤 하던지 항상 두번째 뷰로 다시 자동으로 돌아오도록 구현하고
// 두번째 뷰의 달력 정보만을 이전 월 혹은 다음 월 또는 현재의 월로 변경합니다.
// 사용자에게는 달력이 끊임없이 스크롤 되는 것으로 보이게 하며 일관된 성능을 위한 일종의 속임수라고 할 수 있습니다.

// 사용자가 미래의 달력 뷰를 보고 있을 때 네비게이션바 혹은 상단 상태바를 터치했을때 위로 스크롤되어 현재의 달로 이동하게 하고
// 사용자가 과거의 달력 뷰를 보고 있을 때 네비게이션바 혹은 상단 상태바를 터치했을때 아래로 스크롤되어 현재의 달로 이동하게 합니다.

// 현재 기본적인 달력의 컴포넌트는 완성된 상태입니다.

// 모든 레이아웃, 폰트 크기 등은 절대 사이즈가 아니며 구동되는 아이폰 화면 사이즈에 따라
// 상대적인 크기를 갖도록 구현되었습니다.

// 디버깅을 위한 출력부분은 주석처리 하지 않았습니다.

// Xcode 8.2 에서 최종 빌드
// iOS Deployment target 을 10.2로 세팅

#import "PSHCalendarViewController.h"
#import "PSHCalendarView.h"
#import "PSHCalendarDayLabel.h"
#import "PSHWeekDayLabel.h"
#import "PSHNavBarMonthYearLabel.h"

#import "PSHDayCircle.h"

// 이벤트 추가 버튼 클릭시 하단에서 상단으로 나타날 아이콘 선택창임
#import "PSHEventViewController.h"

@interface PSHCalendarViewController ()

@property (nonatomic) UIScrollView *scrollView;

@property CGFloat bNbW; // below Nav Bar Width
@property CGFloat bNbH; // below Nav Bar Heigh

// 화면크기에 따른 날짜 레이블 폰트 사이즈
@property CGFloat dayLabelFontSize;

// 날짜를 표시할 레이블
@property PSHCalendarDayLabel *dayLabel;

// dayCircle 을 올릴 뷰
@property PSHCalendarDayLabel *dayLabelFocus;

// 오늘날짜에 해당하는 레이블 뷰를
// 임시로 저장해 놓고 추후 달력 이동시 사용하기 위한 선언
// 현재 선언이후 사용안함
//@property UILabel *currentTodayLabel;

// String Array of Week of day
@property NSArray *dayOfWeeks;
@property NSArray *monthOfYear;

// 날짜를 표기하는 UILabel(dayLabel)을 구분하기 위한 태그
@property NSInteger labelTag;

// 두번째 달력에서 오늘날짜에 해당하는 labelTag (고정값)
@property NSInteger todayLabelTag;

// 두번째 달력에서 오늘날짜에 해당하는 labelTag 가변값
@property NSInteger changedTodayTag;

// 현재 두번째 달력에 오늘날짜가 존재하느냐 (BOOL)
@property BOOL changeTodayHere;

// 오늘 날짜가 이번달 달력에 있느냐? (BOOL)
@property BOOL todayIsThisMonth;

// 현재 보이는 달력은 몇월인가
@property NSString *currentViewingMonthStr;
@property NSInteger currentViewingMonthInt;

// 이번달의 첫번째 1일의 Interger 값의 태그를 따로 저장
@property NSInteger thisMonthFirstOneDayInt;

// 날짜에 포커스를 주기 위한 dayCircle을 구분하기 위한 태그
@property NSInteger circleTag;

// 날짜에 포커스를 주기 위한 dayCircle을 구분하기 위한 태그
@property NSInteger todaycircleTag;

// 현재 선택된 Tap으로 선택된 날짜의 태그를 저장
@property NSInteger selectedDayTag;
@property NSDate *selectedDate;
@property NSString *selectedDateStr;

// 이전에 Tap 되었던 날짜의 태그를 저장
@property NSInteger previousSelectedDateTag;

// 이전에 선택된 날짜의 Date
@property NSDate *previousSelectedDate;

// 달력 이동에 따른 날짜 변화를 위한 선언들

// 첫번째 달력의 첫번째 일요일 (태그는 1)
@property NSDate *firstCalFirstSun;

// 두번째 달력의 첫번째 일요일 (태그는 43)
@property NSDate *secondCalFirstSun;

// 세번째 달력의 첫번째 일요일 (태그는 85)
@property NSDate *thirdCalFirstSun;

// 세번째 달력의 마지막 토요일 (태그는 126)
@property NSDate *thirdCalLastSat;

// 두번째 달력의 dayLabel 클릭시 현재 날짜를 알기 위한 NSDate
// 두번째 달력의 첫번째 일요일을 별도록 저장 (TAG:43)
@property NSDate *firstDayOfSecondCal;

// 상단바 클릭시 현재시점 달력으로 복귀하기 위한 여러 데이터 저장
@property NSDate *InitFirstCalFirstSun;
@property NSDate *InitSecondCalFirstSun;
@property NSDate *InitThirdCalFirstSun;
@property NSDate *InitThirdCalLastSat;
@property NSString *InitNavBarMonthYearStr;

// 현재 시점 달력을 기준으로 1~126 번까지의 날짜뷰의 스트링을 저장
@property NSMutableArray *AllDateStrings;

// PSHCalendarView 선언
@property PSHCalendarView *calendarView;

// 각 부분의 캘린터뷰 따로 선언 (이유는 까먹음)
@property PSHCalendarView *firstCalView;
@property PSHCalendarView *secondCalView;
@property PSHCalendarView *thirdCalView;

// 네비게이션 바의 레이블
@property PSHNavBarMonthYearLabel *navBarMonthYearLabel;

// 네비게이션 바에 출력할 현재 보이는 두번째 달력의 월, 년를 저장할 String
@property NSString *navBarMonthYearStr;

// 현재 스크롤바가 현재시점에서 과거인지 미래인지 구별하기 위함
// 현재는 0, 미래는 양수, 과거는 음수
@property NSInteger currentScrollState;

// 상단 상태바가 클릭되었느냐?
@property NSInteger statusBarClicked;

// 날짜 서클
@property PSHDayCircle *dayCircle;

@end

@implementation PSHCalendarViewController

- (void)loadView
{
    // 네비이게이션 바에 + 버튼 추가
    //UINavigationItem *navItem = self.navigationItem;
    //UIBarButtonItem *addItembbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewEvent)];
    //navItem.rightBarButtonItem = addItembbi;
    // + 버튼 색
    //navItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    
    // AllDateStr NSArray 초기화
    self.AllDateStrings = [[NSMutableArray alloc] init];
    
    // Days related
    self.dayOfWeeks = @[@"", @"SUN", @"MON", @"TUE",@"WED", @"THU", @"FRI", @"SAT"];
    
    self.monthOfYear = @[@"", @"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    
    //320, 375, 414
    self.bNbW = [UIScreen mainScreen].bounds.size.width;
    
    //504 (568-64)
    self.bNbH = [UIScreen mainScreen].bounds.size.height - 64.0;
    
    // dayLabel 폰트 사이즈
    self.dayLabelFontSize = (self.bNbW * 18) / 320;
    
    NSLog(@"screenWidth = %f", self.bNbW);
//    NSLog(@"screenHeight = %f", bNbH);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bNbW, self.bNbH)];
    
    self.scrollView.contentSize = CGSizeMake(self.bNbW, self.bNbH * 3);
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollEnabled = YES;
    //self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.showsVerticalScrollIndicator = NO; //추후 NO로 바꿀예정
    
    [self.scrollView setDelegate:self];
    
    // 두번째 달력
    // 오늘 날짜의 NSDate
    NSDate *today = [NSDate date];
    
    // 현재 달력의 첫번째 일요일에 해당하는 NSDate 가져오기
    NSDate *currentDate = [self getMostClosedPastSunday:today];
    
    // 첫번째 달력
    // 두번째 달력 1일의 1일전(이전달)에 해당하는 해당하는 날짜로 사용하여 달력 날짜 연산에 사용할 NSDate
    NSDate *previousDate = [self getDateByAddingOneDayBefore:currentDate];
    
    // 첫번째 달력의 첫번째 일요일에 해당하는 NSDate
    previousDate = [self getMostClosedPastSunday:previousDate];
    
    // 세번째 달력
    // 두번째 달력의 마지막 날짜에 해당하는 NSDate
    NSDate *futureDate = [[NSDate alloc] init];
    
    // labelTag 초기화
    self.labelTag = 1;
    
    // circleTag 초기화
    self.circleTag = -1;
    
    // 달력이동에 따라 변화되는 NSDate 초기화
    self.firstCalFirstSun = [[NSDate alloc] init];
    self.secondCalFirstSun = [[NSDate alloc] init];
    self.thirdCalFirstSun = [[NSDate alloc] init];
    self.thirdCalLastSat = [[NSDate alloc] init];
    
    // 상태바 클릭을 위해
    self.InitFirstCalFirstSun = [[NSDate alloc] init];
    self.InitSecondCalFirstSun = [[NSDate alloc] init];
    self.InitThirdCalFirstSun = [[NSDate alloc] init];
    self.InitThirdCalLastSat = [[NSDate alloc] init];
    
    // Views
    // For loop to make Views
    // 몇번째 달력인가
    for (int i = 0; i < 3; i++) {
        
        self.calendarView = [[PSHCalendarView alloc] initWithFrame:CGRectMake(0, i * self.bNbH, self.bNbW, self.bNbH) backGroundColor:[UIColor whiteColor]];
        
        for (int z = 0; z < 7; z++) {
            
            // 확인이 필요하다는데..
            // 요일 부분 선언 및 addSubView
            PSHWeekDayLabel *weekDayLabel = [[PSHWeekDayLabel alloc] initWithFrame:CGRectMake(z * self.bNbW/7, 0.0, self.bNbW/7, 16.0)];
            [weekDayLabel setText:[NSString stringWithFormat:@"%@",[self.dayOfWeeks objectAtIndex:(z+1)]]];
            [self.calendarView addSubview:weekDayLabel];
        }
        
        // 몇번째 주차인가
        for (int j = 0 ; j < 6; j++) {
            
             // 무슨 요일인가
            for (int k = 0; k < 7; k++) {
                
#pragma mark - //날짜 레이블 선언
                
                // 날짜 레이블 선언
                self.dayLabel = [[PSHCalendarDayLabel alloc] initWithFrame:CGRectMake(k*self.bNbW/7, j*((self.bNbH-16.0)/6) + 16.0 , self.bNbW/7, (self.bNbH-16.0)/6)];

                // dayLabel이 이벤트에 반응하도록 (필요한가?):필요하다...
                [self.dayLabel setUserInteractionEnabled:YES];
                UITapGestureRecognizer *dayLabeltapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dayLabelTapHandler:)];
                [self.dayLabel addGestureRecognizer:dayLabeltapGestureRecognizer];
                
                // dayCircle을 올릴 뷰
                self.dayLabelFocus = [[PSHCalendarDayLabel alloc] initWithFrame:CGRectMake(k*self.bNbW/7, j*((self.bNbH-16.0)/6) + 16.0 , self.bNbW/7, (self.bNbH-16.0)/6)];
                
                //DEBUG
                //NSLog(@"DEBUG:%ld", self.circleTag);
                
                // 첫번째 달력
                if (i == 0) {

                    [self.dayLabel setText:[self getCurrentDayLabelStr:previousDate]];
                    
                    // 추후 상태바 클릭시 사용을 위해 배열에 날짜 저장
                    [self.AllDateStrings addObject:[self getCurrentDayLabelStr:previousDate]];
                    
                    // 날짜 Label에 태그를 붙이자
                    [self.dayLabel setTag:self.labelTag];
                    
                    // 첫번째 달력의 첫번째 일요일에 해당하는 NSDate 가져오기
                    if (self.labelTag == 1) {
                        self.firstCalFirstSun = previousDate;
                        
                        //상단바 클릭시 대비
                        self.InitFirstCalFirstSun = previousDate;
                    }
                    
                    self.labelTag = self.labelTag + 1;
                    
                    // 색 테스팅
                    if (j == 0 && [[self getCurrentDayLabelStr:previousDate] intValue] > 15) {
                        
                        [self.dayLabel setTextColor:[UIColor lightGrayColor]];
                    }
                    
                    if (j == 4 || j == 5) {
                        
                        if ([[self getCurrentDayLabelStr:previousDate] intValue] < 15) {
                            [self.dayLabel setTextColor:[UIColor lightGrayColor]];
                        }
                    }
                    
                    // 오늘 날짜가 있으면 파란색(추후대비)
                    // 현재 달력에 오늘날짜에 해당하는 뷰가 존재한다면
                    if ([[self getFormattedDateString:(previousDate)] isEqualToString:([self getFormattedDateString:[NSDate date]])]) {
                        
                        //NSLog(@"첫번째 달력에 오늘날짜:START");
                        
                        [self.dayLabel setTextColor:[UIColor blueColor]];
                        [self.dayLabel setText:[self getCurrentDayLabelStr:previousDate]];
                        [self.dayLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
                    }
                    
                    previousDate = [self getDateByAddingOneDayAfter:previousDate];
                    
                    // dayCircle 선언 및 dayLabelFocus에 추가
                    
                    self.dayCircle = [[PSHDayCircle alloc] initWithFrame:CGRectMake(self.dayLabel.bounds.origin.x, (self.dayLabel.bounds.size.height/2.0)-(self.dayLabel.bounds.size.width/2.0), self.dayLabel.bounds.size.width, self.dayLabel.bounds.size.width)];
                    
                    [self.dayCircle setCircleColor:[UIColor clearColor]];
                    [self.dayLabelFocus addSubview:self.dayCircle];
                    [self.dayCircle setTag:self.circleTag];
                    self.circleTag = self.circleTag - 1;
                    
#pragma mark - //두번째 달력 생성부
                    
                // 두번째 달력
                } else if (i == 1) {
                    
                    // 현재 달력에 오늘날짜에 해당하는 뷰가 존재한다면
                    if ([[self getFormattedDateString:(currentDate)] isEqualToString:([self getFormattedDateString:[NSDate date]])]) {
                        
                        //NSLog(@"두번째 달력에 오늘날짜:START");
                        
                        [self.dayLabel setTextColor:[UIColor blueColor]];
                        //[self.dayLabel setTextColor:[UIColor whiteColor]];
                        [self.dayLabel setText:[self getCurrentDayLabelStr:currentDate]];
                        [self.dayLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
                        
                        //상태바 클릭을 위해
                        [self.AllDateStrings addObject:[self getCurrentDayLabelStr:currentDate]];
                        
                        [self.dayLabel setTag:self.labelTag];
                        
                        //오늘 날짜에 해당하는 labelTag를 따로 저장
                        self.todayLabelTag = self.labelTag;
                        
                        // 최초에는 오늘날짜가 선택되므로
                        self.selectedDayTag = self.todayLabelTag;
                        self.selectedDate = currentDate;
                        
                        // 현재 달력에서 한번 다른 날짜를 선택하고 (처음의 1일이나 오늘날짜로부터) 또 다른날짜를 선택할때
                        // 이전에 선택된 날짜를 의미함
                        self.previousSelectedDate = currentDate;
                        
                        // 이전에 선택된 날짜의 태그 (현재 달력에서는 오늘날짜의 태그)
                        self.previousSelectedDateTag = self.todayLabelTag;
                        
                        self.changedTodayTag = self.todayLabelTag;
                        self.currentViewingMonthStr = [self getThisMonthStringOnlyFromSomeDay:[NSDate date]];
                        self.currentViewingMonthInt = [self getThisMonthIntOnlyFromSomeDay:[NSDate date]];
                        
                        self.selectedDateStr = [self getCurrentMonthYearDayStr:self.selectedDate];

                        // 두번째 달력에 오늘날짜가 존재함
                        self.changeTodayHere = YES;
                        
                        // 이번달 달력에 오늘날짜가 존재함
                        self.todayIsThisMonth = YES;
                        
                        // 현재 초기 선택된 날짜를 출력
                        //NSLog(@" ");
                        NSLog(@"[loadView]:self.selectedDateStr:%@", self.selectedDateStr);
                        NSLog(@"[loadView]:ThisMonth is:[%ld]월", (long)[self getThisMonthIntOnlyFromSomeDay:[NSDate date]]);
                        
                        
                        // dayCircle 선언 및 dayLabelFocus에 추가
                        // 원의 위치 정확하게 배치
                        
                        self.dayCircle = [[PSHDayCircle alloc] initWithFrame:CGRectMake(self.dayLabel.bounds.origin.x, (self.dayLabel.bounds.size.height/2.0)-(self.dayLabel.bounds.size.width/2.0), self.dayLabel.bounds.size.width, self.dayLabel.bounds.size.width)];
                        
                        [self.dayCircle setCircleColor:[UIColor colorWithRed:0.755 green:0.844 blue:0.988 alpha:1.0]];
                        //[self.dayCircle setCircleColor:[UIColor colorWithRed:0.0168 green:0.1984 blue:1.0 alpha:1.0]];//파란색
                        
                        [self.dayLabelFocus addSubview:self.dayCircle];
                        [self.dayCircle setTag:self.circleTag];
                        
                        // 오늘 날짜에 해당하는 circleLabelTag를 따로 저정
                        self.todaycircleTag = self.circleTag;
                        
                    } else {
                        
                        [self.dayLabel setTextColor:[UIColor blackColor]];
                        [self.dayLabel setText:[self getCurrentDayLabelStr:currentDate]];
                        [self.dayLabel setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
                        
                        //상태바 클릭을 위해
                        [self.AllDateStrings addObject:[self getCurrentDayLabelStr:currentDate]];
                        
                        [self.dayLabel setTag:self.labelTag];
                        
                        // dayCircle 선언 및 dayLabelFocus에 추가
                        
                        self.dayCircle = [[PSHDayCircle alloc] initWithFrame:CGRectMake(self.dayLabel.bounds.origin.x, (self.dayLabel.bounds.size.height/2.0)-(self.dayLabel.bounds.size.width/2.0), self.dayLabel.bounds.size.width, self.dayLabel.bounds.size.width)];
                        [self.dayCircle setCircleColor:[UIColor clearColor]];
                        [self.dayLabelFocus addSubview:self.dayCircle];
                        [self.dayCircle setTag:self.circleTag];
                    }

                    // 두번째 달력의 첫번째 일요일에 해당하는 NSDate 가져오기
                    if (self.labelTag == 43) {
                        self.secondCalFirstSun = currentDate;
                        
                        // 상태바 클릭시를 위해 따로 저장
                        self.InitSecondCalFirstSun = currentDate;
                        
                        // dayLabel을 클릭시를 위해 따로 저장
                        self.firstDayOfSecondCal = currentDate;
                    }
                        
                    self.labelTag = self.labelTag + 1;
                    
                    self.circleTag = self.circleTag - 1;
                    
                    if (j == 5 && k == 6) {
                        
                        futureDate = currentDate;
                        //NSLog(@"두번째달력마지막날짜: %@", (NSString *)[futureDate description]);
                        
                        //세번째 달력에 사용할 하루지난 날짜
                        futureDate = [self getDateByAddingOneDayAfter:futureDate];
                        
                        //다시 세번째 달력에서 첫번째 일요일에 해당하는 날짜
                        futureDate = [self getMostClosedPastSunday:futureDate];
                    }
                    
                    // 두번째 달력에서 labelTag 가 50에 해당하는 Date를 가져오자
                    // 이 경우 항상 이번달 날짜일 것이므로
                    if (self.labelTag == 50) {
                        
                        //NSLog(@"%@:START",[self getCurrentMonthYearStr:currentDate]);
                        self.navBarMonthYearStr = [self getCurrentMonthYearStr:currentDate];
                        
                        //상단바 클릭 대비
                        self.InitNavBarMonthYearStr = self.navBarMonthYearStr;
                    }
                    
                    // 첫번째 주차 이전달 날짜 회색으로
                    if (j == 0 && [self getCurrentDayLabelStr:currentDate].length == 2) {
                        
                        [self.dayLabel setTextColor:[UIColor lightGrayColor]];
                    }
                    
                    // 4, 5 주차 다음달 날짜 회색으로
                    if (j == 4 || j == 5) {

                        if ([[self getCurrentDayLabelStr:currentDate] intValue] < 15) {
                            [self.dayLabel setTextColor:[UIColor lightGrayColor]];
                        }
                    }
                    
                    currentDate = [self getDateByAddingOneDayAfter:currentDate];                    
                    
                // 세번째 달력
                } else if (i == 2) {
                    
                    [self.dayLabel setText:[self getCurrentDayLabelStr:futureDate]];
                    
                    //상태바 클릭을 위해
                    [self.AllDateStrings addObject:[self getCurrentDayLabelStr:futureDate]];
                    
                    [self.dayLabel setTag:self.labelTag];
                    
                    // 세번째 달력의 첫번째 일요일과
                    // 마지막 토요일에 해당하는 NSDate 가져오기
                    if (self.labelTag == 85) {
                        
                        self.thirdCalFirstSun = futureDate;
                        
                        //상단바 클릭 대비
                        self.InitThirdCalFirstSun = futureDate;
                        
                    } else if (self.labelTag == 126) {
                        
                        self.thirdCalLastSat = futureDate;
                        
                        //상단바 클릭 대비
                        self.InitThirdCalLastSat = futureDate;
                    }
                    
                    self.labelTag = self.labelTag + 1;
                    
                    /// 다른달 날짜색 회색으로
                    if (j == 0 && [[self getCurrentDayLabelStr:futureDate] intValue] > 15) {
                        
                        [self.dayLabel setTextColor:[UIColor lightGrayColor]];
                    }
                    
                    if (j == 4 || j == 5) {
                        
                        if ([[self getCurrentDayLabelStr:futureDate] intValue] < 15) {
                            [self.dayLabel setTextColor:[UIColor lightGrayColor]];
                        }
                    }
                    
                    // 오늘날짜가 있으면 파란색(추후대비)
                    // 현재 달력에 오늘날짜에 해당하는 뷰가 존재한다면
                    if ([[self getFormattedDateString:(futureDate)] isEqualToString:([self getFormattedDateString:[NSDate date]])]) {
                        
                        //NSLog(@"세번째 달력에 오늘날짜:START");
                        
                        [self.dayLabel setTextColor:[UIColor blueColor]];
                        [self.dayLabel setText:[self getCurrentDayLabelStr:futureDate]];
                        [self.dayLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
                    }
                    
                    futureDate = [self getDateByAddingOneDayAfter:futureDate];
                    
                    // dayCircle 선언 및 dayLabelFocus에 추가
                    
                    self.dayCircle = [[PSHDayCircle alloc] initWithFrame:CGRectMake(self.dayLabel.bounds.origin.x, (self.dayLabel.bounds.size.height/2.0)-(self.dayLabel.bounds.size.width/2.0), self.dayLabel.bounds.size.width, self.dayLabel.bounds.size.width)];
                    [self.dayCircle setCircleColor:[UIColor clearColor]];
                    [self.dayLabelFocus addSubview:self.dayCircle];
                    [self.dayCircle setTag:self.circleTag];
                    self.circleTag = self.circleTag - 1;
                }
                
                [self.calendarView addSubview:self.dayLabelFocus];
                [self.calendarView addSubview:self.dayLabel];
                
                //[self.calendarView addSubview:self.dayLabel];                
                
                if (i == 0) {
                    self.firstCalView = self.calendarView;
                } else if (i == 1) {
                    self.secondCalView = self.calendarView;
                } else if (i == 2) {
                    self.thirdCalView = self.calendarView;
                }
            }
        }

        [self.scrollView addSubview:self.firstCalView];
        [self.scrollView addSubview:self.secondCalView];
        [self.scrollView addSubview:self.thirdCalView];
    }
    // for문 종료점
    
    [self.scrollView scrollRectToVisible:CGRectMake(0, self.bNbH, self.bNbW, self.bNbH) animated:NO];
    
    // 현재 스크롤 상태 = 0
    self.currentScrollState = 0;
    
    //NSLog(@"scrollSTATUS = %ld", self.currentScrollState);
    
    self.view = self.scrollView;
}

#pragma mark - (void)addNewEvent
// 이벤트 이미지 아이콘을 추가하는 창 불러오기
- (void)addNewEvent
{
    NSLog(@"PSHCalendarViewController:addNewEvent");
    
    // 우선 pshEventViewController 초기화
    PSHEventViewController *pshEventViewController = [[PSHEventViewController alloc] init];
    
    // UINavigationController 의 rootView로 추가
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pshEventViewController];
    
    // 우선 창을 밑에서 위로 띄우는 것 까지...
    [self presentViewController:navController animated:YES completion:nil];
    
}

// dayLabel을 Tap할경우

#pragma mark - dayLabelTapHandler
#pragma mark -

- (void)dayLabelTapHandler:(UITapGestureRecognizer *)dayLabeltapGestureRecognizer {
    
    NSLog(@" ");
    NSLog(@"[dayLabelTapHandler]");
    
    // 현재 클릭된 날짜를 우선 출력해보자.
    // 먼저 현재 달력의 첫번째 일요일을 가져오자
    NSLog(@"[dayLabelTapHandler]:self.firstDayOfSecondCal(STR):%@", [self getCurrentMonthYearDayStr:self.firstDayOfSecondCal]);
    
    // 현재 달력에서 탭하기 전의 선택된 날짜를 우선 가져오자 (당연히 오늘(이번달) 아니면 1일(다른달))
    NSLog(@"[dayLabelTapHandler]:self.selectedDate(STR)-I:%@",[self getCurrentMonthYearDayStr:self.selectedDate]);
    
    // 현재 달력에서 우선 탭하기 전의 선택된 날짜의 태그를 가져오자
    NSLog(@"[dayLabelTapHandler]:self.previousSelectedDateTag-I:%ld",(long)self.previousSelectedDateTag);
    NSLog(@"[dayLabelTapHandler]:self.previousSelectedDate(STR)-I:%@",[self getCurrentMonthYearDayStr:self.previousSelectedDate]);
    // 이전에 선택된 날짜는 몇월이었나? (제대로 나오는듯)
    NSLog(@"[dayLabelTapHandler]:self.getThisMonthIntOnlyFromSomeDay(STR):self.previousSelectedDate-I:[%ld]월",(long)[self getThisMonthIntOnlyFromSomeDay:self.previousSelectedDate]);
    NSLog(@"[dayLabelTapHandler]:self.secondCalFirstSun(STR)-I:%@",[self getCurrentMonthYearDayStr:self.secondCalFirstSun]);
    
    // 우선 이전에 탭 되었던 날짜의 원을 없애자 (글자는 우선 검은색으로 추후 변경예정 : 오늘날짜는 파랗게, 다른달 날짜는 회색으로)
    // 이번달의 날짜가 아닌경우에는 회색으로 처리하자
    // 이전에 선택된 날짜의 월이 현재 보이는 달력의 월과 일치하지 않으면 회색으로 하자
    if ([self getThisMonthIntOnlyFromFirstSunday:self.secondCalFirstSun] != [self getThisMonthIntOnlyFromSomeDay:self.previousSelectedDate]) {
        
        // 그런데 이전에 선택된 날짜가 오늘날짜와 일치한다면 파란색으로 해야함
        if ([[self getCurrentMonthYearDayStr:[NSDate date]] isEqualToString:[self getCurrentMonthYearDayStr:self.previousSelectedDate]]) {
            
            [(PSHDayCircle *)[self.view viewWithTag:(-self.previousSelectedDateTag)] setCircleColor:[UIColor clearColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:self.previousSelectedDateTag]) setTextColor:[UIColor blueColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:self.previousSelectedDateTag]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
            
        } else {
            
            // 그외 월이 일치하지 않으면 회색으로
            [(PSHDayCircle *)[self.view viewWithTag:(-self.previousSelectedDateTag)] setCircleColor:[UIColor clearColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:self.previousSelectedDateTag]) setTextColor:[UIColor lightGrayColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:self.previousSelectedDateTag]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
        }
    
    } else {
        
        // 이전에 선택된 날짜의 월이 현재 보이는 달력의 월과 일치하고
        // 그런데 이전에 선택된 날짜가 오늘날짜와 일치한다면 파란색으로 해야함
        if ([[self getCurrentMonthYearDayStr:[NSDate date]] isEqualToString:[self getCurrentMonthYearDayStr:self.previousSelectedDate]]) {
            
            [(PSHDayCircle *)[self.view viewWithTag:(-self.previousSelectedDateTag)] setCircleColor:[UIColor clearColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:self.previousSelectedDateTag]) setTextColor:[UIColor blueColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:self.previousSelectedDateTag]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
            
        } else {
        
            // 이전에 선택된 날짜의 월이 오늘날짜의 월과 일치하는데 오늘날짜가 아닌경우 검은색으로 처리
            [(PSHDayCircle *)[self.view viewWithTag:(-self.previousSelectedDateTag)] setCircleColor:[UIColor clearColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:self.previousSelectedDateTag]) setTextColor:[UIColor blackColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:self.previousSelectedDateTag]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
        }
    }
    
    ////// 탭한 이후의 변화
    NSLog(@" ");
    NSLog(@"[탭이 이루어진 이후]");
    // 현재 탭된 날짜 레이블의 태그가 몇번째인가
    NSLog(@"[dayLabelTapHandler]:dayLabeltapGestureRecognizer.view.tag:%ld", (long)dayLabeltapGestureRecognizer.view.tag);
    
    // 두번째 달력의 첫번째 날짜(태그 43)로부터 현재 탭된 레이블의 태그간의 차이를 통해 탭된 날짜를 알아보자
    self.selectedDate = [self getDateByAddingDaysAfter:self.firstDayOfSecondCal dayCount:(dayLabeltapGestureRecognizer.view.tag-43)];
    
    // 다시 탭된 날짜가 제대로 나오는지 체크 (제대로 나옴)
    NSLog(@"[dayLabelTapHandler]:self.selectedDate(STR)-II:%@",[self getCurrentMonthYearDayStr:self.selectedDate]);
    
    // 탭된 날짜에 대한 태그를 저장하지
    self.previousSelectedDateTag = dayLabeltapGestureRecognizer.view.tag;
    // 탭된 날짜를 저장하자
    self.previousSelectedDate = self.selectedDate;
    
    // 다시 탭된 날짜의 태그를 출력해보자
    NSLog(@"[dayLabelTapHandler]:self.previousSelectedDateTag-II:%ld",(long)self.previousSelectedDateTag);
    
    // 탭한 날짜가 오늘날짜인 경우 (파란색 원에, 파란글자로)
    if ([[self getCurrentMonthYearDayStr:[NSDate date]] isEqualToString:[self getCurrentMonthYearDayStr:self.selectedDate]]) {
        
        [((PSHCalendarDayLabel *)[self.view viewWithTag:(dayLabeltapGestureRecognizer.view.tag)]) setTextColor:[UIColor blueColor]];
        [((PSHCalendarDayLabel *)[self.view viewWithTag:(dayLabeltapGestureRecognizer.view.tag)]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
        
        // 오늘날짜에 해당하는 circle 색 입히기
        [(PSHDayCircle *)[self.view viewWithTag:(-dayLabeltapGestureRecognizer.view.tag)] setCircleColor:[UIColor colorWithRed:0.755 green:0.844 blue:0.988 alpha:1.0]];
        
    } else {
        
        // 오늘날짜가 아닌경우
        // 기본적으로 현재 탭된 날짜를 선택된 상태로 만들어보자 (검은색 원, 흰색 글자) - 오늘날짜에 대한 것은 추후 생각
        [(PSHDayCircle *)[self.view viewWithTag:(-dayLabeltapGestureRecognizer.view.tag)] setCircleColor:[UIColor colorWithRed:0.077 green:0.0897 blue:0.1014 alpha:1.0]];
        [((PSHCalendarDayLabel *)[self.view viewWithTag:dayLabeltapGestureRecognizer.view.tag]) setTextColor:[UIColor whiteColor]];
        [((PSHCalendarDayLabel *)[self.view viewWithTag:dayLabeltapGestureRecognizer.view.tag]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
    }
    
    // 테스트 테스트.., 이벤트 처리방식 고민...
    // 날짜를 탭하면 바로 이벤트 처리 관련 창을 보여줄 것이냐
    // 아니면 날짜를 클릭하고 원하는 액션을 취하게 할 것인가?
    
    //[self addNewEvent];
    
}

#pragma mark -

// 생성된 네비게이션 바를 리턴함
- (UILabel *)getNavBarMonthYearLabel
{
    
    // 네비게이션 바의 레이블 초기화
    self.navBarMonthYearLabel = [[PSHNavBarMonthYearLabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44.0)];
    //[self.navBarMonthYearLabel setBackgroundColor:[UIColor colorWithRed:0.889 green:0.138 blue:0.146 alpha:1]];
    
    // 사용자가 네비게이션바의 달력 레이블 클릭시 이번달로 이동하도록    
    [self.navBarMonthYearLabel setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navBarTapHandler:)];
    [self.navBarMonthYearLabel addGestureRecognizer:tapGestureRecognizer];
    
    //[self.navBarMonthYearLabel setBackgroundColor:[UIColor whiteColor]];
    // 네비게이션 바의 색깔을 희끄무레한 회색으로 하기 위해 레이블 색도 통일해 줌    
    [self.navBarMonthYearLabel setBackgroundColor:[UIColor colorWithRed:0.9751 green:0.9751 blue:0.9751 alpha:1.0]];
    
    [self.navBarMonthYearLabel setTextColor:[UIColor blackColor]];
    
    return self.navBarMonthYearLabel;
}

// navBarTapHandler 가 샐행되면 scrollViewDidEndScrollingAnimation 이 실행되고 backToThisMonth 이 실행되어
// 이번달 달력으로 이동함

-(void)navBarTapHandler:(UITapGestureRecognizer *)tapGestureRecognizer {
    
    NSLog(@" ");
    NSLog(@"[navBarTapHandler]");
    
    if (self.currentScrollState > 0) {
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.bNbW, self.bNbH) animated:YES];
    } else if (self.currentScrollState < 0) {
        [self.scrollView scrollRectToVisible:CGRectMake(0, self.bNbH*2, self.bNbW, self.bNbH) animated:YES];

    } else if (self.currentScrollState == 0) {
        
        [self backToThisMonth];
        
        //NSLog(@"이번달 캘린더");
//        // 현재 선택된 날짜의 태그를 찍어보자
//        
//        NSLog(@"[navBarTapHandler]:self.previousSelectedDateTag:%ld",self.previousSelectedDateTag);
//        NSLog(@"[navBarTapHandler]:self.previousSelectedDate(STR):%@",[self getCurrentMonthYearDayStr:self.previousSelectedDate]);
//        
//        //현재 선택된 날짜가 오늘날짜가 아니라면 우선 아니라고 출력
//        //오늘날짜를 선택하게 하자.
//        if (![[self getCurrentMonthYearDayStr:self.previousSelectedDate] isEqualToString:[self getCurrentMonthYearDayStr:[NSDate date]]]) {
//            NSLog(@"[navBarTapHandler]:이번달 달력에서 오늘 아닌날이 선택된 상태임");
//            NSLog(@"[navBarTapHandler]:self.todayLabelTag):%ld", self.todayLabelTag);
//        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //NSLog(@" ");
    NSLog(@"[scrollViewDidEndScrollingAnimation]");
    
    [self backToThisMonth];
    
    //self.firstDayOfSecondCal 날짜 변경
    self.firstDayOfSecondCal = self.secondCalFirstSun;
    
    NSLog(@"[scrollViewDidEndScrollingAnimation]:self.firstDayOfSecondCal:%@",self.firstDayOfSecondCal.description);
}

// 이번달 달력으로 복귀

- (void)backToThisMonth
{
    //NSLog(@" ");
    NSLog(@"[backToThisMonth]");
    
    
    // 오늘날짜
    //NSDate *today = [NSDate date];
    
    // 그전에 네비게이션 바의 달력을 이번달로 바꾸자
    self.navBarMonthYearStr = self.InitNavBarMonthYearStr;
    [self.navBarMonthYearLabel setText:self.navBarMonthYearStr];
    
    // 태그 1부터 126까지의 날짜를 모두 바꾸자, 오늘날짜는 파랗게
    for (int i = 0; i < [self.AllDateStrings count]; i++) {
        
        [(PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)] setText:[self.AllDateStrings objectAtIndex:i]];
        
        //오늘 날짜에 해당하는 태그라면
        if ((i+1) == self.todayLabelTag) {
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor blueColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
            
            // 오늘날짜에 해당하는 circle 색 입히기
            [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor colorWithRed:0.755 green:0.844 blue:0.988 alpha:1.0]];
            
            //NSLog(@"[backToThisMonth:self.todayLabelTag:%d]", (i+1));
            
            
        // 네비게이션 바 클릭시 현재달력에서 오늘날짜가 아닌 날이 선택되어 있을 경우 이를 선택 해제하고자 함
        } else if ((i+1) != self.todayLabelTag && (i >= 49) && (i < 70)){
            
            //NSLog(@"[backToThisMonth]:여기에서 처리해줘야 함");
            [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor clearColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor blackColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
        }
    }
    
    for (int i = 0; i < 7; i++) {
        if ([[(PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)] text] intValue] > 15) {
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor lightGrayColor]];
        } else {
            // 날짜색은 다시 클리어
            [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor clearColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor blackColor]];
        }
    }
    
    // 이곳에 오늘날짜가 있으면 폰트를 푸른색으로 보이게 해야함
    for (int i = 28; i < 42; i++) {
        if ([[(PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)] text] intValue] < 15) {
            
            if ([[(PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)] text] isEqualToString:[self getCurrentDayLabelStr:[NSDate date]]]) {
                
                // 첫번째 달력 후반부에 오늘날짜가 포함되어 있다면 당연히 파란색으로 해야함
                [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor blueColor]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
            } else {
                [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor clearColor]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor lightGrayColor]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
            }
            
        } else {
            // 날짜색은 다시 클리어
            [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor clearColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor blackColor]];
        }
    }
    
    for (int i = 42; i < 49; i++) {
        
        if ([[(PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)] text] intValue] > 15) {
            [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor clearColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor lightGrayColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
            
        } else {
            
            // 상단바나 상단네비게이션 바를 클릭했을때 오늘날짜가 다시 검은색으로 바뀌는 현상 수정
            // 오늘날짜에 해당하는 태그라면
            if ((i+1) == self.todayLabelTag) {
                [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor blueColor]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
                
                // 오늘날짜에 해당하는 circle 색 입히기
                [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor colorWithRed:0.755 green:0.844 blue:0.988 alpha:1.0]];
                
                NSLog(@"[backToThisMonth:두번째 달력에 오늘날짜-I:%d]", (i+1));

                
            } else {
                // 날짜색은 다시 클리어
                [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor clearColor]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor blackColor]];
                // 글씨가 굵게 되는 현상 방지
                [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
            }
        }
    }
    
    for (int i = 70; i < 84; i++) {
        
        if ([[(PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)] text] intValue] < 15) {
            
            [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor clearColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor lightGrayColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
            
        } else if ((i+1) == self.todayLabelTag) {
            
            // 오늘날짜라면
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor blueColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
            
            // 오늘날짜에 해당하는 circle 색 입히기
            [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor colorWithRed:0.755 green:0.844 blue:0.988 alpha:1.0]];
            
            NSLog(@"[backToThisMonth:두번째 달력에 오늘날짜-II:%d]", (i+1));

            
        } else {
            // 날짜색은 다시 클리어
            [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor clearColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor blackColor]];
        }
    }
    
    // 세번째 달력 전반부에 두번째 달력의 오늘날짜가 있는 경우도 고려
    for (int i = 84; i < 91; i++) {
        if ([[(PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)] text] intValue] > 15) {
            
            if ([[(PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)] text] isEqualToString:[self getCurrentDayLabelStr:[NSDate date]]]) {
                
                // 세번째 달력 전반부에 두번째 달력의 오늘날짜가 포함되어 있다면 당연히 파란색으로 해야함
                [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor blueColor]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
                
            } else {
                
                // 날짜색은 다시 클리어
                [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor clearColor]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor lightGrayColor]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
            }

        } else {
            // 날짜색은 다시 클리어
            [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor clearColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor blackColor]];
        }
    }
    
    for (int i = 112; i < 126; i++) {
        if ([[(PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)] text] intValue] < 15) {
            // 날짜색은 다시 클리어
            [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor clearColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor lightGrayColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
        } else {
            // 날짜색은 다시 클리어
            [(PSHDayCircle *)[self.view viewWithTag:(-i-1)] setCircleColor:[UIColor clearColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:(i+1)]) setTextColor:[UIColor blackColor]];
        }
    }
    
    //오늘 날짜가 아닌 달의 경우 파랗게 되는 현상 수정 임시로
    [((PSHCalendarDayLabel *)[self.view viewWithTag:(self.todayLabelTag + 42)]) setTextColor:[UIColor blackColor]];
    [((PSHCalendarDayLabel *)[self.view viewWithTag:(self.todayLabelTag + 42)]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
    
    [((PSHCalendarDayLabel *)[self.view viewWithTag:(self.todayLabelTag - 42)]) setTextColor:[UIColor blackColor]];
    [((PSHCalendarDayLabel *)[self.view viewWithTag:(self.todayLabelTag - 42)]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
    
    // 달력 이동에 따른 기준날짜들을 이번달 달력 기준으로 초기화
    self.firstCalFirstSun = self.InitFirstCalFirstSun;
    self.secondCalFirstSun = self.InitSecondCalFirstSun;
    self.thirdCalFirstSun = self.InitThirdCalFirstSun;
    self.thirdCalLastSat = self.InitThirdCalLastSat;
    
    self.currentScrollState = 0;
    self.statusBarClicked = 0;
    
    // 이번달 달력으로 돌아가므로 현재 선택된 날짜는 오늘날짜
    self.selectedDate = [NSDate date];
    
    // 나머지 값도 초기화
    self.changedTodayTag = self.todayLabelTag;
    self.todayIsThisMonth = YES;
    self.changeTodayHere = YES;
    
    // 같은이유
    self.previousSelectedDate = [NSDate date];
    self.previousSelectedDateTag = self.todayLabelTag;
    
    
    NSLog(@"[backToThisMonth:self.selectedDate(STR):%@]", [self getCurrentMonthYearDayStr:self.selectedDate]);
    NSLog(@"[backToThisMonth:ThisMonth is:[%@월]", [self getThisMonthStringOnlyFromFirstSunday:self.secondCalFirstSun]);
    NSLog(@"[backToThisMonth:self.changedTodayTag:%ld]", (long)self.changedTodayTag);
}

// 상단 상태줄을 클릭했을때
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    //NSLog(@" ");
    NSLog(@"[scrollViewShouldScrollToTop](상단상태줄 클릭)");
    
    // 상단바가 클릭되었음
    self.statusBarClicked = 1;
    
    if (self.currentScrollState > 0) {
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.bNbW, self.bNbH) animated:YES];

    }
    
    if (self.currentScrollState < 0) {
        [self.scrollView scrollRectToVisible:CGRectMake(0, self.bNbH*2, self.bNbW, self.bNbH) animated:YES];

    }
    
    if (self.currentScrollState == 0) {
        //NSLog(@"이번달 캘린더");
        
        [self backToThisMonth];
    }
    
    return NO;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@" ");
    
    //오늘날짜
    //NSDate *today = [NSDate date];
    
    CGFloat contentOffsetY = self.scrollView.contentOffset.y;
    
    //NSLog(@"contentOffsetY:%f", contentOffsetY);
    
#pragma mark - //다음달로
    
    // 다음달로 이동
    if (contentOffsetY == self.bNbH * 2) {
        
        //[(PSHCalendarDayLabel *)[self.view viewWithTag:self.todaycircleTag] setHidden:YES];
        
        // 기존에 오늘날짜에 색칠된 원의 색을 없앰, 달력이동때문에
        //[(PSHDayCircle *)[self.view viewWithTag:self.todaycircleTag] setCircleColor:[UIColor clearColor]];

        //NSLog(@"다음달로");
        
        [self.scrollView scrollRectToVisible:CGRectMake(0, self.bNbH, self.bNbW, self.bNbH) animated:NO];

        
        // 다음달로 이동하면 두번째 달력의 첫번째 일요일이
        // --> 첫번째 달력의 첫번째 일요일로 이동한 후
        //     1부터 42까지 태그를 가진 달력 레이블 조정
        NSDate *newFirstCalFirstSun = [[NSDate alloc] init];
        
        for (int i = 1; i <= 42; i++) {
            
            // 현재 달력에 오늘날짜에 해당하는 뷰가 존재한다면
            if ([[self getFormattedDateString:(self.secondCalFirstSun)] isEqualToString:([self getFormattedDateString:[NSDate date]])]) {
                
                //NSLog(@"첫번째 달력에 오늘날짜:다음달로");
                
                [(PSHCalendarDayLabel *)[self.view viewWithTag:i] setText:[self getCurrentDayLabelStr:(self.secondCalFirstSun)]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor blueColor]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
                
                // 오늘날짜에 해당하는 circle 색 입히기
                // 폰트색만 푸른색으로 해야 함
                //[(PSHDayCircle *)[self.view viewWithTag:(-i)] setCircleColor:[UIColor colorWithRed:0.755 green:0.844 blue:0.988 alpha:1.0]];
                
                
            } else {
            
                [(PSHCalendarDayLabel *)[self.view viewWithTag:i] setText:[self getCurrentDayLabelStr:(self.secondCalFirstSun)]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
                
                if (i <= 7 && [[self getCurrentDayLabelStr:(self.secondCalFirstSun)] intValue] > 15) {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor lightGrayColor]];
                    
                } else if (i >= 29 && [[self getCurrentDayLabelStr:(self.secondCalFirstSun)] intValue] < 15) {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor lightGrayColor]];
                    
                } else {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor blackColor]];
                }
                
                [(PSHDayCircle *)[self.view viewWithTag:(-i)] setCircleColor:[UIColor clearColor]];
            }
            
            // 첫번째 달력의 일요일을 재조정
            if (i == 1) {
                newFirstCalFirstSun = self.secondCalFirstSun;
            }
            
            self.secondCalFirstSun = [self getDateByAddingOneDayAfter:self.secondCalFirstSun];
        }
        
        // 첫번째 달력의 일요일을 재조정
        self.firstCalFirstSun = newFirstCalFirstSun;
        
        // 다음달로 이동하면 세번째 달력의 첫번째 일요일이
        // --> 두번째 달력의 첫번째 일요일로 이동한 후
        //     43부터 84까지 태그를 가진 달력 레이블 조정
        
        NSDate *newSecondCalFirstSun = [[NSDate alloc] init];
        
        // NO로 초기화 한뒤 오늘날짜가 발견되면 YES로 변경예정
        self.changeTodayHere = NO;
        
        for (int i = 43; i <= 84; i++) {
            
            // 현재 달력에 오늘날짜에 해당하는 뷰가 존재한다면
            if ([[self getFormattedDateString:(self.thirdCalFirstSun)] isEqualToString:([self getFormattedDateString:[NSDate date]])]) {
                
                // 달력이 이동함에 따라 선택되는 오늘 날짜를 변경
                // 다만 오늘날짜가 이번달 달력에 있는 경우에만
                if ((self.currentViewingMonthInt + 1) == [self getThisMonthIntOnlyFromSomeDay:self.thirdCalFirstSun]) {
                    self.selectedDate = self.thirdCalFirstSun;
                    //NSLog(@" ");
                    //NSLog(@"[scrollViewDidScroll]:currentViewingMonthInt-I:%ld", (self.currentViewingMonthInt + 1));
                } else {
                    //NSLog(@" ");
                    //NSLog(@"[scrollViewDidScroll]:currentViewingMonthInt-II:%ld", (self.currentViewingMonthInt + 1));
                    NSLog(@"[scrollViewDidScroll]:[여기서 뭔가를...]");
                }
                
                //NSLog(@" ");
                NSLog(@"[scrollViewDidScroll]:[scrollDown]:두번째 달력에 오늘날짜:%d", i);
                NSLog(@"[scrollViewDidScroll]:[scrollDown]:self.selectedDateStr:%@", [self getCurrentMonthYearDayStr:self.selectedDate]);
                
                // 두번째 달력에서 변화는 오늘날짜 태그
                self.changedTodayTag = i;
                self.changeTodayHere = YES;
                
                NSLog(@"[scrollViewDidScroll]:[scrollDown]:self.changedTodayTag:%ld", (long)self.changedTodayTag);
                
                [(PSHCalendarDayLabel *)[self.view viewWithTag:i] setText:[self getCurrentDayLabelStr:(self.thirdCalFirstSun)]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor blueColor]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
                
                // 오늘날짜에 해당하는 circle 색 입히기
                [(PSHDayCircle *)[self.view viewWithTag:(-i)] setCircleColor:[UIColor colorWithRed:0.755 green:0.844 blue:0.988 alpha:1.0]];
                
            } else {
                
                [(PSHCalendarDayLabel *)[self.view viewWithTag:i] setText:[self getCurrentDayLabelStr:(self.thirdCalFirstSun)]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
                
                
                if (i < 49 && [[self getCurrentDayLabelStr:(self.thirdCalFirstSun)] intValue] > 15) {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor lightGrayColor]];
                    
                } else if (i >= 71 && [[self getCurrentDayLabelStr:(self.thirdCalFirstSun)] intValue] < 15) {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor lightGrayColor]];
                    
                } else {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor blackColor]];
                    
                    // 이번달 달력의 첫번째 1일인 경우 달력 이동시 선택된 상태여여 함
                    // 이때 오늘날짜가 포함한 이번달 달력은 아니어야 함:self.todayIsThisMonth = NO 인 상태
                    // 우선은 1일을 선택된 날짜로 설정
                    if ([[self getCurrentDayLabelStr:(self.thirdCalFirstSun)] intValue] == 1) {
                        self.selectedDate = self.thirdCalFirstSun;
                        
                        // 1일이 선택된 날짜로 되는 경우를 대비해서 이때의 i값을 따로 저장해두자
                        self.thisMonthFirstOneDayInt = i;
                        
                        NSLog(self.todayIsThisMonth ? @"[[scrollViewDidScroll]:self.todayIsThisMonth:YES]":@"[[scrollViewDidScroll]:self.todayIsThisMonth:NO]");
                    }
                }
                
                [(PSHDayCircle *)[self.view viewWithTag:(-i)] setCircleColor:[UIColor clearColor]];
            }
            
            // 두번째 달력의 첫번째 일요일을 재조정
            if (i == 43) {
                newSecondCalFirstSun = self.thirdCalFirstSun;
            }
            
            // 두번째 달력에서 labelTag 가 50에 해당하는 Date를 가져오자
            // 이 경우 항상 이번달 날짜일 것이므로
            if (i == 50) {
                
                //NSLog(@"%@:NEXT",[self getCurrentMonthYearStr:self.thirdCalFirstSun]);
                
                self.navBarMonthYearStr = [self getCurrentMonthYearStr:self.thirdCalFirstSun];
                
                [self.navBarMonthYearLabel setText:self.navBarMonthYearStr];
            }
            self.thirdCalFirstSun = [self getDateByAddingOneDayAfter:self.thirdCalFirstSun];
        }
        //for문 종료
        
        // 두번째 달력에 오늘날짜가 없으면 0으로 초기화
        if (self.changeTodayHere == NO) {
            self.changedTodayTag = 0;
        }
        
        // 두번째 달력의 첫번째 일요일을 재조정
        self.secondCalFirstSun = newSecondCalFirstSun;
        
        // 두번째 달력의 현재 첫번째 일요일을 출력
        //NSLog(@" ");
        NSLog(@"[scrollViewDidScroll]:NEXT:self.secondCalFirstSun(STR):%@", [self getCurrentMonthYearDayStr:self.secondCalFirstSun]);
        NSLog(self.changeTodayHere ? @"[scrollViewDidScroll]:self.changeTodayHere:YES":@"[scrollViewDidScroll]:self.changeTodayHere:NO");
        NSLog(@"[scrollViewDidScroll]:ThisMonth is:[%@월]", [self getThisMonthStringOnlyFromFirstSunday:self.secondCalFirstSun]);
        
        //self.currentViewingMonthStr = [self getThisMonthStringOnlyFromFirstSunday:self.secondCalFirstSun];
        self.currentViewingMonthInt = [self getThisMonthIntOnlyFromFirstSunday:self.secondCalFirstSun];
        
        // 이번달 달력에 이번달 날짜가 있는냐?
        //if ([[self getThisMonthStringOnlyFromSomeDay:[NSDate date]] isEqualToString:self.currentViewingMonthStr]) {
        if ([self getThisMonthIntOnlyFromSomeDay:[NSDate date]] == self.currentViewingMonthInt) {
            self.todayIsThisMonth = YES;
            NSLog(@"[scrollViewDidScroll]:self.todayIsThisMonth:YES:이번달 달력에 이번달 날짜");
        } else {
            self.todayIsThisMonth = NO;
            NSLog(@"[scrollViewDidScroll]:self.todayIsThisMonth:NO:다른달 달력에 이번달 날짜");
        }
        
        if (self.todayIsThisMonth == YES && self.changeTodayHere == YES) {
            self.selectedDate = [NSDate date];
            NSLog(@"[scrollViewDidScroll]:[scrollDown-II]:self.selectedDateStr:%@", [self getCurrentMonthYearDayStr:self.selectedDate]);
            
            // 달력이동후에는 이전 선택날짜가 초기화 (selectedDate 와 동일하게)
            self.previousSelectedDate = [NSDate date];
            self.previousSelectedDateTag = self.changedTodayTag;
            
        } else {
            
            // 매월 1일이 선택된 날짜여야 하는 경우 여기서 걸림 (매월 1일이 잘 선택됨 - 까먹었음 구현방법은 어쨌던 잘 되는듯...)
            NSLog(@"[scrollViewDidScroll]:[scrollDown-III]:self.selectedDateStr:%@", [self getCurrentMonthYearDayStr:self.selectedDate]);
            
            // 달력이동후에는 이전 선택날짜가 초기화 (selectedDate 와 동일하게)
            self.previousSelectedDate = self.selectedDate;
            self.previousSelectedDateTag = self.thisMonthFirstOneDayInt;
            
            // 1일에 해당하는 날짜 선택된 모양으로:글짜 흰색, 검은색 원            
            [(PSHDayCircle *)[self.view viewWithTag:(-self.thisMonthFirstOneDayInt)] setCircleColor:[UIColor colorWithRed:0.077 green:0.0897 blue:0.1014 alpha:1.0]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:self.thisMonthFirstOneDayInt]) setTextColor:[UIColor whiteColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:self.thisMonthFirstOneDayInt]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
            
            // 다른달 달력의 오늘날짜는 글자만 파랗게
            if (self.todayIsThisMonth == NO && self.changeTodayHere == YES) {
                
                NSLog(@"[scrollViewDidScroll]:[scrollDown-III]:self.changedTodayTag:%ld", (long)self.changedTodayTag);
                
                // 글자만 파랗게
                [(PSHDayCircle *)[self.view viewWithTag:-self.changedTodayTag] setCircleColor:[UIColor clearColor]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:self.changedTodayTag]) setTextColor:[UIColor blueColor]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:self.changedTodayTag]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
            }
        }

        // dayLabel 클릭시를 대비한 날짜 저장
        self.firstDayOfSecondCal = self.secondCalFirstSun;
        //NSLog(@"NT:self.firstDayOfSecondCal:%@",self.firstDayOfSecondCal.description);
        
        // 세번째 달력 구성부분 //
        
        // 다음달로 이동하면 세번째 달력의 마지막 토요일에
        // 해당하는 날짜의 다음날에 해당하는 달력의
        // 첫번째 일요일부터 달력이 생성되어야함
        
        // 세번째 달력의 마지막날 다음날 가져오기
        self.thirdCalLastSat = [self getDateByAddingOneDayAfter:self.thirdCalLastSat];
        
        // 다음으로 위의 날에 해당하는 월의 첫번째 일요일 가져오기
        self.thirdCalLastSat = [self getMostClosedPastSunday:self.thirdCalLastSat];
        
        NSDate *newThirdCalFirstSun = [[NSDate alloc] init];
        
        //세번째 달력의 첫번째 일요일을 재조정
        newThirdCalFirstSun = self.thirdCalLastSat;
        
        NSDate *newThirdCalLastSat = [[NSDate alloc] init];
        
        // 85부터  126까지의 레이블 조정
        for (int i = 85; i <= 126; i++) {
            
            // 현재 달력에 오늘날짜에 해당하는 뷰가 존재한다면
            if ([[self getFormattedDateString:(self.thirdCalLastSat)] isEqualToString:([self getFormattedDateString:[NSDate date]])]) {
                
                //NSLog(@"세번째 달력에 오늘날짜:다음달로");
                
                [(PSHCalendarDayLabel *)[self.view viewWithTag:i] setText:[self getCurrentDayLabelStr:(self.thirdCalLastSat)]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor blueColor]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
                
                // 오늘날짜에 해당하는 circle 색 입히기
                // 폰트색만 푸른색으로 해야함
                // [(PSHDayCircle *)[self.view viewWithTag:(-i)] setCircleColor:[UIColor colorWithRed:0.755 green:0.844 blue:0.988 alpha:1.0]];
                
            } else {
                
                [(PSHCalendarDayLabel *)[self.view viewWithTag:i] setText:[self getCurrentDayLabelStr:(self.thirdCalLastSat)]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
                
                
                if (i <= 91 && [[self getCurrentDayLabelStr:(self.thirdCalLastSat)] intValue] > 15) {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor grayColor]];
                
                } else if (i >= 113 && [[self getCurrentDayLabelStr:(self.thirdCalLastSat)] intValue] < 15) {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor lightGrayColor]];
                    
                } else {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor blackColor]];
                }
                
                [(PSHDayCircle *)[self.view viewWithTag:(-i)] setCircleColor:[UIColor clearColor]];
            }
            
            // 세번째 달력의 마지막 토요일을 재조정
            if (i == 126) {
                
                newThirdCalLastSat = self.thirdCalLastSat;
            }
            
            self.thirdCalLastSat = [self getDateByAddingOneDayAfter:self.thirdCalLastSat];
        }
        // 세번째 달력의 마지막 토요일을 재조정
        self.thirdCalLastSat = newThirdCalLastSat;
        self.thirdCalFirstSun = newThirdCalFirstSun;
        
        // 미래로 스크롤하므로 더하기
        self.currentScrollState = self.currentScrollState + 1;
        
        //NSLog(@"NEXT:scrollSTATUS = %ld", self.currentScrollState);
        
#pragma mark - //이전달로
        
    } else if (contentOffsetY == 0.0) {
        
        // 기존에 오늘날짜에 색칠된 원의 색을 없앰, 달력이동때문에
        //[(PSHDayCircle *)[self.view viewWithTag:self.todaycircleTag] setCircleColor:[UIColor clearColor]];
        
        //NSLog(@"이전달로");
        
        [self.scrollView scrollRectToVisible:CGRectMake(0, self.bNbH, self.bNbW, self.bNbH) animated:NO];

        /// 변경된 세번째 달력 구현
        // 이전달로 이동하면, 두번째 달력의 첫번째 일요일이 --> 세번째 달력의 첫번째 일요일로 이동한 후
        // 85부터 126까지의 태그를 가진 달력 레이블 조정, 세번째 달력의 첫번째 일요일을 재조정
        // 세번째 달력의 마지막 토요일을 재조정
        
        NSDate *newThirdCalFirstSun = [[NSDate alloc] init];
        NSDate *newThirdCalLastSat = [[NSDate alloc] init];
        
        newThirdCalFirstSun = self.secondCalFirstSun;
        
        for (int i = 85; i <= 126; i++) {
            
            // 현재 달력에 오늘날짜에 해당하는 뷰가 존재한다면
            if ([[self getFormattedDateString:(self.secondCalFirstSun)] isEqualToString:([self getFormattedDateString:[NSDate date]])]) {
                
                //NSLog(@"세번째 달력에 오늘날짜:이전달로");
                
                [(PSHCalendarDayLabel *)[self.view viewWithTag:i] setText:[self getCurrentDayLabelStr:(self.secondCalFirstSun)]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor blueColor]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
                
                // 오늘날짜에 해당하는 circle 색 입히기
                // 폰트색만 푸른색으로 해야함
                //[(PSHDayCircle *)[self.view viewWithTag:(-i)] setCircleColor:[UIColor colorWithRed:0.755 green:0.844 blue:0.988 alpha:1.0]];
                
            } else {
            
                [(PSHCalendarDayLabel *)[self.view viewWithTag:i] setText:[self getCurrentDayLabelStr:(self.secondCalFirstSun)]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
                
                if (i <= 91 && [[self getCurrentDayLabelStr:(self.secondCalFirstSun)] intValue] > 15) {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor lightGrayColor]];
                    
                } else if (i >= 113 && [[self getCurrentDayLabelStr:(self.secondCalFirstSun)] intValue] < 15) {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor lightGrayColor]];
                    
                } else {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor blackColor]];
                }
                
                [(PSHDayCircle *)[self.view viewWithTag:(-i)] setCircleColor:[UIColor clearColor]];
            }
            
            // 세번째 달력의 마지막 토요일을 재조정
            if (i == 126) {
                newThirdCalLastSat = self.secondCalFirstSun;
            }
            
            self.secondCalFirstSun = [self getDateByAddingOneDayAfter:self.secondCalFirstSun];
        }
        
        //세번째 달력의 첫번째 일요일, 마지막 토요일 재조정
        self.thirdCalFirstSun = newThirdCalFirstSun;
        self.thirdCalLastSat = newThirdCalLastSat;        
        
        // 변경된 두번째 달력 구현
        // 이전달로 이동하면, 첫번째 달력의 첫번째 일요일이 --> 두번째 달력의 첫번째 일요일로 이동한 후
        // 43부터 84까지의 태그를 가진 달력 레이블 조정
        // 두번째 달력의 첫번째 일요일을 재조정
        NSDate *newSecondCalFirstSun = [[NSDate alloc] init];
        
        //NO 로 초기화한뒤 오늘날짜가 발견되면 YES로
        self.changeTodayHere = NO;
        
        for (int i = 43; i <= 84; i++) {
            
            // 현재 달력에 오늘날짜에 해당하는 뷰가 존재한다면
            if ([[self getFormattedDateString:(self.firstCalFirstSun)] isEqualToString:([self getFormattedDateString:[NSDate date]])]) {
                
                // 달력이 이동함에 따라 선택되는 오늘 날짜를 변경
                // 다만 오늘날짜가 이번달 달력에 있는 경우에만
                if ((self.currentViewingMonthInt + 1) == [self getThisMonthIntOnlyFromSomeDay:self.firstCalFirstSun]) {
                    self.selectedDate = self.thirdCalFirstSun;
                    //NSLog(@" ");
                    //NSLog(@"[scrollViewDidScroll]:currentViewingMonthInt-I:%ld", (self.currentViewingMonthInt + 1));
                } else {
                    //NSLog(@" ");
                    //NSLog(@"[scrollViewDidScroll]:currentViewingMonthInt-II:%ld", (self.currentViewingMonthInt + 1));
                    NSLog(@"[scrollViewDidScroll]:[여기서 뭔가를...]");
                }
                
                //NSLog(@" ");
                NSLog(@"[scrollViewDidScroll]:[scrollUpUp]:두번째 달력에 오늘날짜:%d", i);
                NSLog(@"[scrollViewDidScroll]:[scrollUpUp]:self.selectedDateStr:%@", [self getCurrentMonthYearDayStr:self.selectedDate]);
                
                self.changedTodayTag = i;
                self.changeTodayHere = YES;
                
                NSLog(@"[scrollViewDidScroll]:[scrollUpUp]:self.changedTodayTag:%ld", (long)self.changedTodayTag);
                
                [(PSHCalendarDayLabel *)[self.view viewWithTag:i] setText:[self getCurrentDayLabelStr:(self.firstCalFirstSun)]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor blueColor]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
                
                // 오늘날짜에 해당하는 circle 색 입히기
                [(PSHDayCircle *)[self.view viewWithTag:(-i)] setCircleColor:[UIColor colorWithRed:0.755 green:0.844 blue:0.988 alpha:1.0]];
                
            } else {
                
                [(PSHCalendarDayLabel *)[self.view viewWithTag:i] setText:[self getCurrentDayLabelStr:(self.firstCalFirstSun)]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
                
                if (i < 49 && [[self getCurrentDayLabelStr:(self.firstCalFirstSun)] intValue] > 15) {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor lightGrayColor]];
                    
                    
                } else if (i >= 71 && [[self getCurrentDayLabelStr:(self.firstCalFirstSun)] intValue] < 15) {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor lightGrayColor]];
                    
                } else {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor blackColor]];
                    
                    // 이번달 달력의 첫번째 1일인 경우 달력 이동시 선택된 상태여여 함
                    // 이때 오늘날짜가 포함한 이번달 달력은 아니어야 함:self.todayIsThisMonth = NO 인 상태
                    // 우선은 1일을 선택된 날짜로 설정
                    if ([[self getCurrentDayLabelStr:(self.firstCalFirstSun)] intValue] == 1) {
                        self.selectedDate = self.firstCalFirstSun;
                        
                        // 1일이 선택된 날짜로 되는 경우를 대비해서 이때의 i값을 따로 저장해두자
                        self.thisMonthFirstOneDayInt = i;
                        
                        NSLog(self.todayIsThisMonth ? @"[[scrollViewDidScroll]:self.todayIsThisMonth:YES]":@"[[scrollViewDidScroll]:self.todayIsThisMonth:NO]");
                    }
                }
                
                [(PSHDayCircle *)[self.view viewWithTag:(-i)] setCircleColor:[UIColor clearColor]];
            }
            
            // 두번째 달력의 첫번째 일요일을 재조정
            if (i == 43) {
                newSecondCalFirstSun = self.firstCalFirstSun;
            }
            
            // 두번째 달력에서 labelTag 가 50에 해당하는 Date를 가져오자
            // 이 경우 항상 이번달 날짜일 것이므로
            if (i == 50) {
                
                //NSLog(@"%@:NEXT",[self getCurrentMonthYearStr:self.firstCalFirstSun]);
                
                self.navBarMonthYearStr = [self getCurrentMonthYearStr:self.firstCalFirstSun];
                
                [self.navBarMonthYearLabel setText:self.navBarMonthYearStr];
            }
            
            self.firstCalFirstSun = [self getDateByAddingOneDayAfter:self.firstCalFirstSun];
        }
        //for문 끝
        
        //두번째 달력에 오늘날짜가 없으면 0으로 초기화
        if (self.changeTodayHere == NO) {
            self.changedTodayTag = 0;
        }
        
        //두번째 달력의 첫번째 일요일 재조정
        self.secondCalFirstSun = newSecondCalFirstSun;
        
        // 두번째 달력의 현재 첫번째 일요일을 출력
        //NSLog(@" ");
        NSLog(@"[scrollViewDidScroll]:BACK:self.secondCalFirstSun(STR):%@", [self getCurrentMonthYearDayStr:self.secondCalFirstSun]);
        NSLog(self.changeTodayHere ? @"[scrollViewDidScroll]:self.changeTodayHere:YES":@"[scrollViewDidScroll]:self.changeTodayHere:NO");
        NSLog(@"[scrollViewDidScroll]:ThisMonth is:[%@월]", [self getThisMonthStringOnlyFromFirstSunday:self.secondCalFirstSun]);
        
//        self.currentViewingMonthStr = [self getThisMonthStringOnlyFromFirstSunday:self.secondCalFirstSun];
//        
//        // 이번달 달력에 이번달 날짜가 있는냐?
//        if ([[self getThisMonthStringOnlyFromFirstSunday:[NSDate date]] isEqualToString:self.currentViewingMonthStr]) {
//            self.todayIsThisMonth = YES;
//            NSLog(@"self.todayIsThisMonth: YES:이번달 달력에 이번달 날짜");
//        } else {
//            self.todayIsThisMonth = NO;
//            NSLog(@"self.todayIsThisMonth:NO:다른달 달력에 이번달 날짜");
//        }
        

        self.currentViewingMonthInt = [self getThisMonthIntOnlyFromFirstSunday:self.secondCalFirstSun];
        
        // 이번달 달력에 이번달 날짜가 있는냐?
        if ([self getThisMonthIntOnlyFromSomeDay:[NSDate date]] == self.currentViewingMonthInt) {
            self.todayIsThisMonth = YES;
            NSLog(@"[scrollViewDidScroll]:self.todayIsThisMonth:YES:이번달 달력에 이번달 날짜");
        } else {
            self.todayIsThisMonth = NO;
            NSLog(@"[scrollViewDidScroll]:self.todayIsThisMonth:NO:다른달 달력에 이번달 날짜");
        }
        
        if (self.todayIsThisMonth == YES && self.changeTodayHere == YES) {
            
            self.selectedDate = [NSDate date];
            NSLog(@"[scrollViewDidScroll]:[scrollUP-II]:self.selectedDateStr:%@", [self getCurrentMonthYearDayStr:self.selectedDate]);
            
            // 같은 이유
            self.previousSelectedDate = [NSDate date];
            self.previousSelectedDateTag = self.changedTodayTag;
            
        } else {
            
            // 매월 1일이 선택되어야 하는경우
            NSLog(@"[scrollViewDidScroll]:[scrollUP-III]:self.selectedDateStr:%@", [self getCurrentMonthYearDayStr:self.selectedDate]);
            
            self.previousSelectedDate = self.selectedDate;
            self.previousSelectedDateTag = self.thisMonthFirstOneDayInt;
            
            // 1일에 해당하는 날짜 선택된 모양으로:글짜 흰색, 검은색 원
            [(PSHDayCircle *)[self.view viewWithTag:(-self.thisMonthFirstOneDayInt)] setCircleColor:[UIColor colorWithRed:0.077 green:0.0897 blue:0.1014 alpha:1.0]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:self.thisMonthFirstOneDayInt]) setTextColor:[UIColor whiteColor]];
            [((PSHCalendarDayLabel *)[self.view viewWithTag:self.thisMonthFirstOneDayInt]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
            
            // 오늘 날짜가 다른 달력에 있는 경우 - 글자만 파랗게
            if (self.todayIsThisMonth == NO && self.changeTodayHere == YES) {
                NSLog(@"[scrollViewDidScroll]:[scrollUP-III]:self.changedTodayTag:%ld", (long)self.changedTodayTag);
                
                // 글자만 파랗게
                [(PSHDayCircle *)[self.view viewWithTag:-self.changedTodayTag] setCircleColor:[UIColor clearColor]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:self.changedTodayTag]) setTextColor:[UIColor blueColor]];
                [((PSHCalendarDayLabel *)[self.view viewWithTag:self.changedTodayTag]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
            }
        }
        
        // dayLabel 클릭시를 대비한 날짜 저장
        self.firstDayOfSecondCal = self.secondCalFirstSun;
        //NSLog(@"BK:self.firstDayOfSecondCal:%@",self.firstDayOfSecondCal.description);
        
        // 변경된 첫번째 달력 구현
        // 이전달로 이동하면, 새로운 두번째 달력의 첫번째 일요일에 해당하는 날짜의 전날에 해당하는 달력의 첫번째 일요일부터
        // 달력이 생성되어야 함
        // 1부터 42까지의 태그를 가진 달력 레이블 조정, 첫번째 달력의 첫번째 일요일을 재조정
        
        // 새로운 첫번째 달력의 첫번째 일요일 선언
        NSDate *newFirstCalFirstSun = [[NSDate alloc] init];
        
        //두번째 달력 변경 구현시 생성된 새로운 두번째 달력의 첫번째 일요일의 이전날짜 가져오기
        //새로운 두번째 달력의 첫번째 일요일의 이전날짜 가져오기
        self.firstCalFirstSun = [self getDateByAddingOneDayBefore:self.secondCalFirstSun];
        
        //위의 이전날짜에 해당하는 월의 첫번째 일요일 가져오기
        self.firstCalFirstSun = [self getMostClosedPastSunday:self.firstCalFirstSun];
        
        for (int i = 1; i <= 42; i++) {
            
            // 현재 달력에 오늘날짜에 해당하는 뷰가 존재한다면
            if ([[self getFormattedDateString:(self.firstCalFirstSun)] isEqualToString:([self getFormattedDateString:[NSDate date]])]) {
                
                //NSLog(@"첫번째 달력에 오늘날짜:이전달로");
                
                [(PSHCalendarDayLabel *)[self.view viewWithTag:i] setText:[self getCurrentDayLabelStr:(self.firstCalFirstSun)]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor blueColor]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setFont:[UIFont fontWithName:@"OpenSans-Bold" size:self.dayLabelFontSize]];
                
                // 오늘날짜에 해당하는 circle 색 입히기
                // 폰트색만 푸른색으로 해야함
                //[(PSHDayCircle *)[self.view viewWithTag:(-i)] setCircleColor:[UIColor colorWithRed:0.755 green:0.844 blue:0.988 alpha:1.0]];

                
            } else {
                
                [(PSHCalendarDayLabel *)[self.view viewWithTag:i] setText:[self getCurrentDayLabelStr:self.firstCalFirstSun]];
                
                [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setFont:[UIFont fontWithName:@"OpenSans" size:self.dayLabelFontSize]];
                
                if (i <= 7 && [[self getCurrentDayLabelStr:self.firstCalFirstSun] intValue] > 15) {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor lightGrayColor]];
                    
                } else if (i >= 29 && [[self getCurrentDayLabelStr:(self.firstCalFirstSun)] intValue] < 15) {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor lightGrayColor]];
                    
                } else {
                    
                    [((PSHCalendarDayLabel *)[self.view viewWithTag:i]) setTextColor:[UIColor blackColor]];
                }
                
                [(PSHDayCircle *)[self.view viewWithTag:(-i)] setCircleColor:[UIColor clearColor]];
            }
            
            if (i == 1) {
                newFirstCalFirstSun = self.firstCalFirstSun;
            }
            self.firstCalFirstSun = [self getDateByAddingOneDayAfter:self.firstCalFirstSun];
        }
        
        //첫번째 달력의 첫번째 일요일을 재조정
        self.firstCalFirstSun = newFirstCalFirstSun;
        
        // 과거로 스크롤하므로 빼기
        self.currentScrollState = self.currentScrollState - 1;
    }
}

#pragma mark
// 최초 실행시 현재시간에 해당하는 두번째 달력 레이블의 Str 가져오기
// 이때 첫번째 레이블은 이번달의 1일을 포함하는 가장 최근의 일요일(지난달이 될수도 있음)을 가져오도록 한다.

- (NSDate *)getMostClosedPastSunday:(NSDate *)currentDay
{
   // 이번달 1일에 해당하는 NSDate
    NSDate *thisMonthFirstDay = [self getCurrentDateFirstOneday:currentDay];
    
    // 이번달 1일의 요일에 해당하는 Int
    NSInteger thisMonthFirstDayWeekDayInt = [self getCurrentDateFirstOnedayInt:thisMonthFirstDay];
    
    // 이번달 1일이 무슨요일인가?
    //NSLog(@"이번달 1일의 요일은:%ld", thisMonthFirstDayWeekDayInt);
    
    // 이번달 1일이 일요일이 아니라면 1일 이전의 일요일에 해당하는 NSDate를 가져오자
    // 가장 최근의 일요일 정보를 저장할 NSDate 선언
    NSDate *mostPastSunday = [[NSDate alloc] init];
    
    if (thisMonthFirstDayWeekDayInt != 1) {
        mostPastSunday = [thisMonthFirstDay dateByAddingTimeInterval:(60*60*-24*(thisMonthFirstDayWeekDayInt-1))];
    } else {
        mostPastSunday = thisMonthFirstDay;
    }
    
    return mostPastSunday;
}

// 현재 NSDate의 하루지난 NSDate 를 가져오자
- (NSDate *) getDateByAddingOneDayAfter:(NSDate *)currentDay
{
    return [currentDay dateByAddingTimeInterval:(60*60*24)];
}

// 현재 NSDate 로부터 원하는 기간이 지난 NSDate를 가져오자
- (NSDate *) getDateByAddingDaysAfter:(NSDate *)currentDay dayCount:(NSInteger)count
{
    return [currentDay dateByAddingTimeInterval:(60*60*24*count)];
}

// 현재 NSDate의 하루전의 NSDate 를 가져오자
- (NSDate *) getDateByAddingOneDayBefore:(NSDate *)currentDay
{
    return [currentDay dateByAddingTimeInterval:(60*60*-24)];
}

// 현재 NSDate로부터 날짜 label에 넣을 String을 추출하자
- (NSString *) getCurrentDayLabelStr:(NSDate *)currentDay
{
    //'NSGregorianCalendar' is deprecated: first deprecated in iOS 8.0
    // - Use NSCalendarIdentifierGregorian instead
    
    //NSDateComponents *currentDayComponents = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] components: kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitWeekday | kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond fromDate:currentDay];
    
    NSDateComponents *currentDayComponents = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] components: kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitWeekday | kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond fromDate:currentDay];

    NSString *currentDayStr = [NSString stringWithFormat:@"%ld", (long)[currentDayComponents day]];
    
    return currentDayStr;
}

// 현재 NSDate로부터 Month, Year 스트링을 추출하자
- (NSString *) getCurrentMonthYearStr:(NSDate *)currentDay
{
    NSDateComponents *currentDayComponents = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] components: kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitWeekday | kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond fromDate:currentDay];
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    
    NSArray *monthNames = [dateformatter standaloneMonthSymbols];
    
    NSString *monthNameStr = [monthNames objectAtIndex:([currentDayComponents month] - 1)];
    
    NSString *blankStr = @" ";
    
    NSString *currentYearStr =[NSString stringWithFormat:@"%ld", (long)[currentDayComponents year]];
    
    return [[monthNameStr stringByAppendingString:blankStr] stringByAppendingString:currentYearStr];
}

// 현재 NSDate로부터 Month, Year, Day 스트링을 Short Style로 추출하자
- (NSString *) getCurrentMonthYearDayStr:(NSDate *)currentDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    
    return [dateFormatter stringFromDate:currentDay];
    
}

// 현재 NSDate에 해당하는 월의 1일의 NSDate를 가져오자
- (NSDate *) getCurrentDateFirstOneday:(NSDate *)currentDay
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *thisMonthComponents = [gregorianCalendar components:kCFCalendarUnitMonth | kCFCalendarUnitYear fromDate:currentDay];
    
    NSInteger thisMonthInt = [thisMonthComponents month];
    NSInteger thisYearInt = [thisMonthComponents year];
    
    //이번달의 첫번째 1일에 해당하는 NSDate 가져오기
    NSDateComponents *thisMonthFirstDayComponents = [[NSDateComponents alloc] init];
    [thisMonthFirstDayComponents setMonth:thisMonthInt];
    [thisMonthFirstDayComponents setDay:1];//이번달의 1일
    [thisMonthFirstDayComponents setYear:thisYearInt];//금년
    [thisMonthFirstDayComponents setHour:12]; //12시 00분 00초
    [thisMonthFirstDayComponents setMinute:0];
    [thisMonthFirstDayComponents setSecond:0];
    
    NSDate *thisMonthFirstDay = [gregorianCalendar dateFromComponents:thisMonthFirstDayComponents];
    
    return thisMonthFirstDay;
}

// 이번달 1일의 Int값 구하기
- (NSInteger) getCurrentDateFirstOnedayInt:(NSDate *)currentDay
{
    
    //이번달 1일의 요일 Int 구하기
    NSDateComponents *thisMonthFirstDayWeekDayComponents = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] components: kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitWeekday | kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond fromDate:currentDay];
    
    // 이번달 1일의 요일 Int값
    NSInteger thisMonthFirstDayWeekDayInt = [thisMonthFirstDayWeekDayComponents weekday];
    
    return thisMonthFirstDayWeekDayInt;
}

// 현재 NSDate를 년, 월, 일로만 구성되도록 조정 (날짜 비교를 위하여)
- (NSString *) getFormattedDateString:(NSDate *)currentDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:currentDay];
    
    return formattedDateString;
}

// 현재 NSDate의 월에 관한 스트링만을 가져오자 (달력에 오늘날짜가 있지만 다음날의 오늘인 경우를 알기위해)
- (NSString *) getThisMonthStringOnlyFromFirstSunday:(NSDate *)currentDay
{
    
    // 첫번째 달력의 첫번째 일요일은 이전달의 날짜일 수 있으니
    // 이번달 달력의 확실한 날짜를 가져와서 이번달 스트링을 추출
    NSDate *afterCurrentDay = [self getDateByAddingDaysAfter:currentDay dayCount:15];
    
    //이번달이 몇월인지..
    NSDateComponents *thisMonthFirstDayWeekDayComponents = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] components: kCFCalendarUnitYear | kCFCalendarUnitMonth fromDate:afterCurrentDay];
    
    // 이번달은 몇월인가?
    NSInteger thisMonth = [thisMonthFirstDayWeekDayComponents month];
    
    NSString *thisMonthStr = [NSString stringWithFormat: @"%ld", (long)thisMonth];
    
    return thisMonthStr;
}

// 현재 NSDate의 월에 관한 스트링만을 가져오자 날짜의 증감없이 바로 현재 날짜로부터 추출
- (NSString *) getThisMonthStringOnlyFromSomeDay:(NSDate *)currentDay
{
    //이번달이 몇월인지..
    NSDateComponents *thisMonthFirstDayWeekDayComponents = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] components: kCFCalendarUnitYear | kCFCalendarUnitMonth fromDate:currentDay];
    
    // 이번달은 몇월인가?
    NSInteger thisMonth = [thisMonthFirstDayWeekDayComponents month];
    
    NSString *thisMonthStr = [NSString stringWithFormat: @"%ld", (long)thisMonth];
    
    return thisMonthStr;
}


// 현재 NSDate의 월에 관한 NSInterger를 가져오자 날짜의 증감없이 바로 현재 날짜로부터 추출
- (NSInteger) getThisMonthIntOnlyFromSomeDay:(NSDate *)currentDay
{
    //이번달이 몇월인지..
    NSDateComponents *thisMonthFirstDayWeekDayComponents = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] components: kCFCalendarUnitYear | kCFCalendarUnitMonth fromDate:currentDay];
    
    // 이번달은 몇월인가?
    NSInteger thisMonth = [thisMonthFirstDayWeekDayComponents month];
    
    return thisMonth;
}

// 현재 NSDate의 월에 관한 NSInterger를 가져오자 첫번째 일요일을 기준으로 15일후에
- (NSInteger) getThisMonthIntOnlyFromFirstSunday:(NSDate *)currentDay
{
    // 첫번째 달력의 첫번째 일요일은 이전달의 날짜일 수 있으니
    // 이번달 달력의 확실한 날짜를 가져와서 이번달 스트링을 추출
    NSDate *afterCurrentDay = [self getDateByAddingDaysAfter:currentDay dayCount:15];
    
    //이번달이 몇월인지..
    NSDateComponents *thisMonthFirstDayWeekDayComponents = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] components: kCFCalendarUnitYear | kCFCalendarUnitMonth fromDate:afterCurrentDay];
    
    // 이번달은 몇월인가?
    NSInteger thisMonth = [thisMonthFirstDayWeekDayComponents month];
    
    return thisMonth;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self.navBarMonthYearLabel setText:self.navBarMonthYearStr];
    
    // TEST Get Size of statusbar
    
    //CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    //NSLog(@"statusBarHeight:%f",statusBarHeight);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
