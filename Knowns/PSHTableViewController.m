//
//  PSHTableViewController.m
//  Knowns
//
//  Created by PARK SANG HYUN on 6/2/15.
//  Copyright (c) 2015 PARK SANG HYUN. All rights reserved.
//

#import "PSHTableViewController.h"
#import "PSHDataStore.h"
#import "PSHEventPickController.h"
#import "PSHEventDetailController.h"

@interface PSHTableViewController ()

@property PSHDataStore *pshDataStore;
@property PSHEventPickController *pshEventPickController;
@property PSHEventDetailController *pshEventDetailController;

@property UILabel *currentSelectedEventImageTitleLabel;
@property UILabel *selectEventIconTitle;

// PSHEventPickController 상의 이벤트 아이콘을 클릭하기 전과
// 클릭한 후를 구분하기 위한 식별자
// 클릭하기전 : 0, 클릭후 : 1
@property NSInteger isEventIconClickedID;

@end

@implementation PSHTableViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    //self = [super initWithStyle:UITableViewStylePlain];
    
    // isEventIconClickedID 을 여기서 우선 초기화하자.
    self.isEventIconClickedID = 0;
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    return self;
}

- (void)pshEventPickController:(PSHEventPickController *)viewController isEventImageViewClicked:(NSInteger)value
{
    NSLog(@"PSHTableViewController:PSHEventPickControllerDelegate:pshEventPickController");
    
    // 우선 여기까지 PSHEventPickController 에서 사용자가 정의한 Delegate를 받아오는 것까지 동작
    // 여기서 현재 테이블 섹션의 아이콘 클릭시 다른 섹션으로 교체
    
    UITableView *tableView = (UITableView *)self.view;
    
    NSArray *insertIndexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:0 inSection:1], nil];
    NSArray *deleteIndexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:0 inSection:1], nil];
    
    //begin updates.
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
    
    // 이벤트 아이콘 이미지가 클릭되었으므로 1로 변경
    self.isEventIconClickedID = 1;
    
    NSLog(@"PSHTableViewController:isEventIconClickedID:[0]에서 [1]로 변경됨");
    
    // 여기서 해야 하나
    //[[self.tableView headerViewForSection:0].textLabel setText:@"    BLAH BLAS"];
    
    [tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
    
    [tableView endUpdates];
    //end updates.
}

// Required in UITableViewDataSource Protocol

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView setBackgroundColor:[UIColor whiteColor]];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        // 여기서 isEventIconClickedID 가 0일때와 1일때를 구분하여 이벤트 아이콘 클릭후에는 다른 뷰를 보여주도록 해야함
        // 우선 아래의 기본 구현 코드는 0일 때이고,
        
        if (self.isEventIconClickedID == 0) {
            
            self.pshDataStore = [PSHDataStore sharedStore];
            
            // 클래스 초기화
            self.pshEventPickController = [[PSHEventPickController alloc] init];
            
            // Delegate 를 여기서 선언
            self.pshEventPickController.delegate = self;
            
            [self.pshEventPickController.view setFrame:CGRectMake(0, 0, self.pshDataStore.xSizeOfMainScreen, self.pshDataStore.PSHEventPickController_Height)];
            
            [cell.contentView addSubview:self.pshEventPickController.view];
            
            [cell setContentMode:UIViewContentModeCenter];
            cell.separatorInset = UIEdgeInsetsMake(0.0, tableView.bounds.size.width, 0.0, 0.0);
            
            NSLog(@"%@:[pshEventPickController 로딩완료]", NSStringFromClass([self class]));

        } else if (self.isEventIconClickedID == 1) {
            
            // delegate 선언
            id<PSHTableViewControllerDelegate> strongDelegate = self.delegate;
            
            if ([strongDelegate respondsToSelector:@selector(pshTableViewController:isEventImageViewClicked:)]) {
                [strongDelegate pshTableViewController:self isEventImageViewClicked:self.pshDataStore.isEventImageViewClicked];
            }
            
            // isEventIconClickedID 가 1일 경우.
            
            // 별도의 뷰를 관리할 외부 클래스를 별도로 선언하여 호출하자.
            // 이벤트 선택후 보여질 뷰의 클래스 (PSHEventDetailController)
            
            self.pshDataStore = [PSHDataStore sharedStore];
            self.pshEventDetailController = [[PSHEventDetailController alloc] init];
            
            //[self.pshEventDetailController.view setFrame:CGRectMake(0, 0, self.pshDataStore.xSizeOfMainScreen, self.pshDataStore.PSHEventPickController_Height)];
            
            [self.pshEventDetailController.view setFrame:CGRectMake(0, 0, self.pshDataStore.xSizeOfMainScreen, self.pshDataStore.sizeOfEventImage + 20.0)];
            
            // 셀 사이즈를 줄여야 할것 같은데...
            //[cell setFrame:CGRectMake(0, 0, self.pshDataStore.xSizeOfMainScreen, self.pshDataStore.sizeOfEventImage + 20.0)];
            
            // 우선 여기서 cell 의 높이가 얼만지 출력해보자, 83.0 인데...
            //NSLog(@"PSHTableViewController:cell.contentView 높이:%f", cell.contentView.frame.size.height);
            // 44, 기본적인 셀의 디폴트 높이로 출력되는것 같은데..
            //NSLog(@"PSHTableViewController:cell 높이:%f", cell.frame.size.height);
            
            // 셀의 색깔을 빨간색으로 해서 비교해보자
            //[cell setBackgroundColor:[UIColor redColor]];
            
            [cell.contentView addSubview:self.pshEventDetailController.view];
            
            // 셀 자체의 탭을 우선 비활성화하였다.
            [cell setUserInteractionEnabled:NO];
            
            [cell setContentMode:UIViewContentModeCenter];
            cell.separatorInset = UIEdgeInsetsMake(0.0, tableView.bounds.size.width, 0.0, 0.0);
            
            // 이벤트 이미지가 클릭된 후이므로 다시 0으로 돌려놓아야 함 (아닌듯..)
            //self.pshDataStore.isEventImageViewClicked = 0;
            
            NSLog(@"%@:isEventImageViewClicked:%ld", NSStringFromClass([self class]), (long)self.pshDataStore.isEventImageViewClicked);
            
            NSLog(@"%@:[pshEventDetailController 로딩완료]", NSStringFromClass([self class]));
        }
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        
        if (self.isEventIconClickedID == 0) {
            
            [cell setHidden:YES];
            
        } else if (self.isEventIconClickedID == 1) {
            
            [cell setHidden:NO];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.textLabel setText:@"Add Reminder"];
            
            UISwitch *reminderSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = reminderSwitch;
            
            [reminderSwitch addTarget:self action:@selector(reminderSwitchState:) forControlEvents:UIControlEventValueChanged];
        }
    }
    
    return cell;
}

// UISwitch 의 On/Off 상태 식별

- (void)reminderSwitchState:(id)sender
{
    UISwitch *currentSwitch = (UISwitch *)sender;
    
    if ([currentSwitch isOn]) {
        
        NSLog(@"PSHTableViewController:currentSwitch:ON");
        
    } else {
        
        NSLog(@"PSHTableViewController:currentSwitch:OFF");
    }
}

// Required in UITableViewDataSource Protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    
    if (section == 0) {
        
        numberOfRowsInSection = 1;
        
    } else if (section == 1) {
        
        numberOfRowsInSection = 1;
    }
    
    return numberOfRowsInSection;
}

// 여기서 조건에 따라 셀의 높이를 변경할수 있을듯 하다
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 디폴트 크기
    CGFloat heightForRowAtIndexPath = 44.0;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        // 아이콘이 선택되기 전의 높이, 그 외의 경우는 디폴트 높이로
        if (self.isEventIconClickedID == 0) {
          
            heightForRowAtIndexPath = self.pshDataStore.PSHEventPickController_Height;
            
        } else if (self.isEventIconClickedID == 1) {
            
            // 클릭된 후에는 이미지 사이즈에 맞도록 작게
            heightForRowAtIndexPath = self.pshDataStore.sizeOfEventImage + 20.0;
        }
    }
    
    return heightForRowAtIndexPath;
}

// 총 섹션의 개수는 2개로 하고..

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// UITableView 클래스는 상당히 세심하고 까다롭다.
// 테이블을 그룹으로 만들고 헤더의 크기를 작게 설정하니 네이게이션 바 바로 밑에 붙는다.
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //return UITableViewAutomaticDimension;
    //return 0.1;
    return 30.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.selectEventIconTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.pshDataStore.xSizeOfMainScreen, 30.0)];
    
    [self.selectEventIconTitle setFont:[UIFont fontWithName:@"OpenSans" size:13]];
    
    [self.selectEventIconTitle setTextColor:[UIColor colorWithRed:0.4281 green:0.4288 blue:0.4481 alpha:1.0]];
    //[selectEventIconTitle setBackgroundColor:[UIColor colorWithRed:0.9373 green:0.938 blue:0.9563 alpha:1.0]];
    //[selectEventIconTitle setBackgroundColor:[UIColor yellowColor]];
    
    if (section == 0) {
        
        if (self.isEventIconClickedID == 0) {
            
            [self.selectEventIconTitle setText:@"    SELECT EVENT ICON..."];
            //[self.selectEventIconTitle setText:@""];
            
            
        } else if (self.isEventIconClickedID == 1) {
            
            // 이하 작동안함
            NSLog(@"viewForHeaderInSection:self.isEventIconClickedID == 1");
            
            // 원하는 이벤트 아이콘을 클릭한 후에는 셀의 헤더에 아이콘을 선택하라는 메세지를 보여줄 필요가 없으므로
            // 필요한 경우 부가적인 다른 헤더 제목을 사용할 수 있음.            
            [self.selectEventIconTitle setText:@"    ENTER TITLE OR..(in progress)"];
        }
        
    } else if (section == 1) {
        
        // 첫번째 섹션의 헤더에만 제목을 주면 되니까.
        [self.selectEventIconTitle setText:@""];
    }
    
//    [self.selectEventIconTitle setBackgroundColor:[UIColor colorWithRed:0.9373 green:0.938 blue:0.9563 alpha:1.0]];
//    //[selectEventIconTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];
//    [self.selectEventIconTitle setFont:[UIFont fontWithName:@"OpenSans" size:13]];
//    [self.selectEventIconTitle setTextColor:[UIColor colorWithRed:0.4281 green:0.4288 blue:0.4481 alpha:1.0]];
//    [self.selectEventIconTitle setText:@"    SELECT EVENT ICON..."];
//    [self.scrollView addSubview:self.selectEventIconTitle];
    
    return self.selectEventIconTitle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 테이블 구분선을 모두 없애고 싶을때
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
}

@end






