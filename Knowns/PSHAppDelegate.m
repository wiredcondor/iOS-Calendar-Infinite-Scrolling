//
//  PSHAppDelegate.m
//  Knowns
//
//  Created by SANG HYUN PARK on 5/20/14.
//  Copyright (c) 2014 PARK SANG HYUN. All rights reserved.
//

#import "PSHAppDelegate.h"
#import "PSHCalendarViewController.h"

@interface PSHAppDelegate ();

@property PSHCalendarViewController *pshCalendarViewController;

@end

@implementation PSHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{ 
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.pshCalendarViewController = [[PSHCalendarViewController alloc] init];
    
    [self.pshCalendarViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.pshCalendarViewController];
    
    self.window.rootViewController = navController;
    
    // 네비게이션 바의 색을 변경
    [[UINavigationBar appearance] setTranslucent:NO];
    
    // 네비게이션 바의 날짜, 배터리 표시가 흰색 글자로 나오게 하려면 이렇게.
    //[[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    //[[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    // 희끄무레한 회색
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.9751 green:0.9751 blue:0.9751 alpha:1.0]];
    // 빨간색 like Fantastical
    //[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.889 green:0.138 blue:0.146 alpha:1]];
    
    // 네비게이션 바에 레이블을 추가
    [navController.navigationBar addSubview:(self.pshCalendarViewController.getNavBarMonthYearLabel)];
    
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
