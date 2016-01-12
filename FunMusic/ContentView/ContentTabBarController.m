//
//  ContentTabBarController.m
//  FunMusic
//
//  Created by frankie on 15/12/27.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ContentTabBarController.h"
#import "MusicPlayerViewController.h"
#import "SearchViewController.h"
#import "ChannelViewController.h"
#import "ChannelGroupController.h"
#import "TweetTableVIewController.h"
#import "MineTableViewController.h"
#import "SharedViewController.h"
#import "LoginViewController.h"
#import "ChannelInfo.h"
#import "ChannelGroup.h"
#import "FunServer.h"
#import "AppDelegate.h"
#import "SideMenuViewController.h"
#import <MBProgressHUD.h>
#import <RESideMenu.h>



static const CGFloat kTabbarItemTextFont = 12;
static const CGFloat kRefreshSleepTime = 0.8;

typedef NS_ENUM(NSInteger, tabBarControllerType)
{
    tabBarControllerTypePlayer = 1,
    tabBarControllerTypeChannel,
    tabBarControllerTypeTweeter,
    tabBarControllerTypeMine
};



@interface ContentTabBarController ()
{
    __weak ContentTabBarController *weakSelf;
    __weak TweetTableVIewController *weakTweetCtl;
    AppDelegate *appDelegate;
}

@end

@implementation ContentTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSArray *channelGroupNames = @[@"推荐",@"语言",@"风格",@"心情"];
    NSMutableArray *channelGroupCtrList = [[NSMutableArray alloc] init];
    weakSelf = self;
    for (NSString *singleChannelGroupname in channelGroupNames)
    {
        ChannelGroupController *controller = [[ChannelGroupController alloc] initWithChannelGroupName:singleChannelGroupname ];
        controller.presidentView = ^(NSInteger indexPath)
        {
            weakSelf.selectedIndex = indexPath;
        };
        
        [channelGroupCtrList addObject:controller];
    }
    ChannelViewController *channelViewCtl = [[ChannelViewController alloc] initWithTitle:@"FUN Music 频道"
                                                                               subTitles:channelGroupNames
                                                                     subTitleCOntrollers:channelGroupCtrList];
    
    MusicPlayerViewController *musicViewCtl = [[MusicPlayerViewController alloc] init];
    MineTableViewController *mineViewCtl = [[MineTableViewController alloc] init];
    TweetTableVIewController *tweetViewCtl = [[TweetTableVIewController alloc] init];
    weakTweetCtl = tweetViewCtl;
    _weakMineCtl = mineViewCtl;
    //取消navigationBar的半透明效果
    self.tabBar.translucent = NO;
    self.viewControllers = @[[self addNavigationItemForViewController:musicViewCtl tabBarControllerType:tabBarControllerTypePlayer],
                             [self addNavigationItemForViewController:channelViewCtl tabBarControllerType:tabBarControllerTypeChannel],
                             [self addNavigationItemForViewController:tweetViewCtl tabBarControllerType:tabBarControllerTypeTweeter],
                             [self addNavigationItemForViewController:mineViewCtl tabBarControllerType:tabBarControllerTypeMine]];
    
    NSArray *titles = @[@"音乐",@"FM频道",@"音乐圈",@"我"];
    //NSArray *images = @[];
    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop)
     {
         [item setTitle:titles[idx]];
         //设置属性
         [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont systemFontOfSize:kTabbarItemTextFont],NSFontAttributeName,nil]
                             forState:UIControlStateNormal];
         //[item setImage:[UIImage imageNamed:[images[idx] stringByAppendingString:@"-TabBarItem"]]];
          
     }];
    
//**********************************************SetBlockFunction********************************************
    mineViewCtl.presentView = ^(NSInteger indexPath)
    {
        weakSelf.selectedIndex = indexPath;
    };
    tweetViewCtl.presidentView = ^(NSInteger indexPath)
    {
        weakSelf.selectedIndex = indexPath;
    };
//**********************************************************************************************************
    
}



- (UINavigationController *)addNavigationItemForViewController:(UIViewController *)viewController tabBarControllerType:(tabBarControllerType)type
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.navigationBar.tintColor = [UIColor redColor];
    navigationController.navigationBar.translucent = NO;
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar-sidebar"]
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                      action:@selector(onClickMenuButton)];
    switch (type)
    {
        case tabBarControllerTypeChannel:

            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                             target:self
                                                                                                             action:@selector(pushSearchViewController)];
            viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:nil
                                                                                              action:nil];
           
            break;
        case tabBarControllerTypePlayer:
            
            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                                             target:self
                                                                                                             action:@selector(pushSharedViewController)];
            
            
            viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:nil
                                                                                              action:nil];

            break;
        case tabBarControllerTypeTweeter:
            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                                             target:self
                                                                                                             action:@selector(refreshTweeter)];

            break;
        case tabBarControllerTypeMine:
            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                             target:self
                                                                                                             action:@selector(pushSearchViewController)];
            break;
        
    }
    
    return navigationController;
}

- (void)onClickMenuButton
{
    [self.sideMenuViewController presentLeftMenuViewController];
}


- (void)pushSearchViewController
{
    SearchViewController *searchViewCtl = [[SearchViewController alloc] init];
    
    searchViewCtl.presidentView = ^(NSInteger indexPath)
    {
        weakSelf.selectedIndex = indexPath;
    };
    [(UINavigationController *)self.selectedViewController pushViewController:searchViewCtl animated:YES];
}

- (void)pushSharedViewController
{
    if ([appDelegate isLogin])
    {
        SharedViewController *sharedViewCtl = [[SharedViewController alloc] init];
        
        sharedViewCtl.presidentView = ^(NSInteger index)
        {
            weakSelf.selectedIndex = index;
            [weakTweetCtl fetchTweetData];
            [weakTweetCtl.tableView reloadData];
        };
        [(UINavigationController *)self.selectedViewController pushViewController:sharedViewCtl animated:YES];
    }
    else
    {
        
        __weak SideMenuViewController *weakSideMenuCtl = (SideMenuViewController *)self.sideMenuViewController.leftMenuViewController;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请先登录"
                                                                                 message:@"请登录后再分享您的频道"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       LoginViewController *loginCtl = [[LoginViewController alloc] init];
                                       loginCtl.updateUserUI = ^()
                                       {
                                           [_weakMineCtl refreshUserView];
                                           [weakSideMenuCtl refreshUserView];
                                       };
                                       [(UINavigationController *)weakSelf.selectedViewController pushViewController:loginCtl animated:YES];
                                       
                                   }];
        
        
        [alertController addAction:okAction];
        [weakSelf.selectedViewController presentViewController:alertController animated:YES completion:nil];
    }
    
   
}

- (void)refreshTweeter
{
    if ([appDelegate isLogin])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakTweetCtl.tableView animated:YES];
        hud.labelText = @"刷新中";
        hud.mode = MBProgressHUDModeIndeterminate;
        //注意GCD的强大的嵌套能力，涉及UI的动作在主线程做，其余可以放在默认并发线程global_queue中做
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           [weakTweetCtl fetchTweetData];
                           [weakTweetCtl.tableView reloadData];
                           [NSThread sleepForTimeInterval:kRefreshSleepTime];
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              [hud hide:YES];
                                          });
                       });

    }
    else
    {
        __weak SideMenuViewController *weakSideMenuCtl = (SideMenuViewController *)self.sideMenuViewController.leftMenuViewController;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请先登录"
                                                                                 message:@"请登录后再刷新您的音乐圈"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       LoginViewController *loginCtl = [[LoginViewController alloc] init];
                                       loginCtl.updateUserUI = ^()
                                       {
                                           [_weakMineCtl refreshUserView];
                                           [weakSideMenuCtl refreshUserView];
                                       };
                                       loginCtl.hidesBottomBarWhenPushed = YES;
                                       weakTweetCtl.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                                                    style:UIBarButtonItemStylePlain
                                                                                                                   target:nil
                                                                                                                   action:nil];
                                       
                                       [weakTweetCtl.navigationController pushViewController:loginCtl animated:YES];
                                       
                                   }];
        [alertController addAction:okAction];
        [weakTweetCtl presentViewController:alertController animated:YES completion:nil];

    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
