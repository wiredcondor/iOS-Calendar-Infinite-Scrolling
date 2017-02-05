//
//  PSHEventDetailController.m
//  Knowns
//
//  Created by PARK SANG HYUN on 8/12/15.
//  Copyright (c) 2015 PARK SANG HYUN. All rights reserved.
//

#import "PSHEventDetailController.h"
#import "PSHDataStore.h"

@interface PSHEventDetailController ()

@property PSHDataStore *pshDataStore;

// 이벤트 아이콘 선택후 보여질 최상위 뷰
@property UIView *detailView;

// 선택된 이벤트 아이콘을 위한 이미지뷰
@property UIImageView *selectedEventImageView;

@end

@implementation PSHEventDetailController

- (void)loadView
{    
    // PSHDataStore 초기화
    self.pshDataStore = [PSHDataStore sharedStore];

    //self.detailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.pshDataStore.xSizeOfMainScreen, self.pshDataStore.PSHEventPickController_Height)];
    self.detailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.pshDataStore.xSizeOfMainScreen, self.pshDataStore.sizeOfEventImage + 20.0)];
    //[self.detailView setBackgroundColor:[UIColor yellowColor]];
    
    // 선택된 이미지 추가 (우선 임의로 추가한 것임)
    self.selectedEventImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sports-21.png"]];
    [self.selectedEventImageView setFrame:CGRectMake(10.0, 10.0, self.pshDataStore.sizeOfEventImage, self.pshDataStore.sizeOfEventImage)];
    
    [self.detailView addSubview:self.selectedEventImageView];
    
    self.view = self.detailView;
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
