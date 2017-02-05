//
//  PSHEventViewController.m
//  Knowns
//
//  Created by PARK SANG HYUN on 3/28/15.
//  Copyright (c) 2015 PARK SANG HYUN. All rights reserved.
//

#import "PSHEventViewController.h"
#import "PSHDataStore.h"
#import "PSHTableViewController.h"

@interface PSHEventViewController ()

// PSHDataStore 인스턴스 선언
@property PSHDataStore *pshDataStore;
@property PSHTableViewController *pshTableViewController;

@property UIBarButtonItem *doneItem;

@property (nonatomic) UIScrollView *scrollView;

@end

@implementation PSHEventViewController

//    2015-05-30 15:19:29.863 Knowns[2232:175648]   OpenSans-Semibold
//    2015-05-30 15:19:29.863 Knowns[2232:175648]   OpenSans-Light
//    2015-05-30 15:19:29.863 Knowns[2232:175648]   OpenSans
//    2015-05-30 15:19:29.863 Knowns[2232:175648]   OpenSans-Bold

- (void)loadView
{
    // 필요한 클래스 로드
    /// 데이터 저장소 초기화
    self.pshDataStore = [PSHDataStore sharedStore];
    
    // 네비게이션바에 텍스트가 너무 많으니 산만하다. 아이콘으로 바꿔야 하나.
    // 네비게이션바 왼쪽 버튼 아이템
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    [cancelItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans" size:17.0], NSFontAttributeName, [UIColor colorWithRed:0.0 green:0.459 blue:1.0 alpha:1.0], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    //[cancelItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans" size:([UIScreen mainScreen].bounds.size.width * 14) / 320], NSFontAttributeName, [UIColor colorWithRed:0.0 green:0.459 blue:1.0 alpha:1.0], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    // 네비게이션바 오른쪽 버튼 아이템
    self.doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
    
    [self.doneItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:17.0], NSFontAttributeName, [UIColor colorWithRed:0.0 green:0.459 blue:1.0 alpha:0.4], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    //[doneItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans" size:([UIScreen mainScreen].bounds.size.width * 14) / 320], NSFontAttributeName, [UIColor colorWithRed:0.0 green:0.459 blue:1.0 alpha:1.0], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = self.doneItem;
    
    if (self.pshDataStore.isEventImageViewClicked == 0) {
        NSLog(@"PSHEventViewController:isEventImageViewClicked=0");
        [self.doneItem setEnabled:NO];
    } else if (self.pshDataStore.isEventImageViewClicked == 1) {
        NSLog(@"PSHEventViewController:isEventImageViewClicked=1");
        [self.doneItem setEnabled:YES];
    }
    
    // 네비게이션바의 제목 레이블
    UILabel *addEventLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, self.pshDataStore.xSizeOfMainScreen, 44.0)];
    addEventLabel.textAlignment = NSTextAlignmentCenter;
    // 기본 폰트 사이즈는 17
    [addEventLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:(self.pshDataStore.xSizeOfMainScreen * 18) / 320]];
    //[addEventLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:18.0]];
    [addEventLabel setText:@"New Event"];
    self.navigationItem.titleView = addEventLabel;    
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.pshDataStore.yStartingPosOfMainUI, self.pshDataStore.xSizeOfMainScreen, self.pshDataStore.yStartingPosOfMainUI)];    

    // 우선은 현재 보이는 페이지의 2배의 크기로 스크롤뷰을 설정
    //self.scrollView.contentSize = CGSizeMake(self.pshDataStore.xSizeOfMainScreen, self.pshDataStore.yStartingPosOfMainUI * 2.0);
    self.scrollView.contentSize = CGSizeMake(self.pshDataStore.xSizeOfMainScreen, self.pshDataStore.yStartingPosOfMainUI);
    
    self.scrollView.pagingEnabled = NO;
    
    //self.scrollView.scrollEnabled = YES;
    self.scrollView.scrollEnabled = NO;
    
    //추후 NO로 바꿀예정
    self.scrollView.showsVerticalScrollIndicator = YES;
 
    //회색
    self.scrollView.backgroundColor = [UIColor colorWithRed:0.9373 green:0.938 blue:0.9563 alpha:1.0];
    //self.scrollView.backgroundColor = [UIColor whiteColor];
    
    //UIScrollViewDelegate 선언
    self.scrollView.delegate = self;
    
    // 이벤트 아이콘을 고르시오 제목뷰
//    self.selectEventIconTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.pshDataStore.xSizeOfMainScreen, 30.0)];
//    [self.selectEventIconTitle setBackgroundColor:[UIColor colorWithRed:0.9373 green:0.938 blue:0.9563 alpha:1.0]];
//    //[selectEventIconTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];
//    [self.selectEventIconTitle setFont:[UIFont fontWithName:@"OpenSans" size:13]];
//    [self.selectEventIconTitle setTextColor:[UIColor colorWithRed:0.4281 green:0.4288 blue:0.4481 alpha:1.0]];
//    [self.selectEventIconTitle setText:@"    SELECT EVENT ICON..."];
//    [self.scrollView addSubview:self.selectEventIconTitle];
    
    // 테이블뷰 생성 및 ADD
    self.pshTableViewController = [[PSHTableViewController alloc] init];
    
    // PSHTableViewController 에서 선언한 자체 delegate를 여기서 받아오자
    self.pshTableViewController.delegate = self;
    
    // PSHTableViewController 의 뷰 위치와 크기를 지정해 주면 위쪽에 여백이 안생기는듯...
    // 그리고 PSHTableViewController 상에서 Header뷰를 추가하면 여백이 생기는듯..
    //[self.pshTableViewController.view setFrame:CGRectMake(0, self.selectEventIconTitle.frame.size.height, self.pshDataStore.xSizeOfMainScreen, self.pshDataStore.yStartingPosOfMainUI - self.selectEventIconTitle.frame.size.height)];
    [self.pshTableViewController.view setFrame:CGRectMake(0, 0, self.pshDataStore.xSizeOfMainScreen, self.pshDataStore.yStartingPosOfMainUI)];
    
    [self.scrollView addSubview:self.pshTableViewController.view];
    
    self.view = self.scrollView;
    
}

// PSHTableViewController에서 선언한 사용자 Delegate를 상위 클래스인 PSHEventViewController 에서 구현하여 Done 버튼의 활성, 비활성화 구현
- (void)pshTableViewController:(PSHTableViewController *)viewController isEventImageViewClicked:(NSInteger)value
{
    NSLog(@"PSHEventViewController:PSHTableViewControllerDelegate:[%ld]", (long)self.pshDataStore.isEventImageViewClicked);
    
    if (self.pshDataStore.isEventImageViewClicked == 1) {
        
        [self.doneItem setEnabled:YES];
        
        [self.doneItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:17.0], NSFontAttributeName, [UIColor colorWithRed:0.0 green:0.459 blue:1.0 alpha:1.0], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        
       

    }
}

- (void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    // 이벤트 아이콘이 클릭되기 원 상태로 복귀
    self.pshDataStore.isEventImageViewClicked = 0;
}

- (void)cancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    // 이벤트 아이콘이 클릭되기 원 상태로 복귀
    self.pshDataStore.isEventImageViewClicked = 0;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
//    
//    [self.view addGestureRecognizer:tap];
    


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
