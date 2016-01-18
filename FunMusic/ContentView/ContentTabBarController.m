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
#import "SideMenuViewController.h"
#import "UIColor+Util.h"
#import <MBProgressHUD.h>
#import <RESideMenu.h>


static const CGFloat kNavigationTextFont = 17;
static const CGFloat kTabbarItemTextFont = 12;
static const CGFloat kRefreshSleepTime   = 0.8;
static NSString *kDawnAndNightMode       = @"dawnAndNightMode";



@interface ContentTabBarController ()
{
    __weak ContentTabBarController *weakSelf;
    FunServer *funServer;
}

@end

@implementation ContentTabBarController

- (void)dawnAndNightMode:(NSNotification *)center
{
    [self.viewControllers enumerateObjectsUsingBlock:^(UINavigationController *nav, NSUInteger idx, BOOL *stop)
     {
         
         UIViewController *viewCtl = nav.viewControllers[0];
         [viewCtl.navigationController.navigationBar setBarTintColor:[UIColor navigationBarColor]];
         [viewCtl.tabBarController.tabBar setBarTintColor:[UIColor tabbarColor]];
         [viewCtl.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                    [UIColor navigationBarTextColor],NSForegroundColorAttributeName,
                                                                                    [UIFont systemFontOfSize:kNavigationTextFont],NSFontAttributeName,nil]];         
        if (idx == funViewTypeMusic)
        {
            MusicPlayerViewController *musicPlayerCtl = nav.viewControllers[0];
            [musicPlayerCtl dawnAndNightMode];
        }
        else if (idx == funViewTypeChannel)
        {
            ChannelViewController *channelCtl = nav.viewControllers[0];
            [channelCtl dawnAndNightMode];
        }
        else if (idx == funViewTypeTweeter)
        {
            TweetTableVIewController *tweetCtl = nav.viewControllers[0];
            [tweetCtl dawnAndNightMode];
        }
        else if (idx == funViewTypeMine)
        {
            MineTableViewController *mineCtl = nav.viewControllers[0];
            [mineCtl dawnAndNightMode];
        }
     }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDawnAndNightMode object:nil];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UINavigationBar appearance] setBarTintColor:[UIColor navigationBarColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor tabbarColor]];
    //之所以放在这里主要是照顾到TabBar和NavigationBar的颜色设置问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dawnAndNightMode:) name:kDawnAndNightMode object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    funServer = [[FunServer alloc] init];
    
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
    TweetTableVIewController *tweetViewCtl = [[TweetTableVIewController alloc] initWithType:tweetViewTypeLocal TweeterName:@"音乐圈"];
    _weakTweetCtl = tweetViewCtl;
    _weakMineCtl = mineViewCtl;
    //取消navigationBar的半透明效果
    self.tabBar.translucent = NO;
    self.viewControllers = @[[self addNavigationItemForViewController:musicViewCtl funViewControllerType:funViewTypeMusic],
                             [self addNavigationItemForViewController:channelViewCtl funViewControllerType:funViewTypeChannel],
                             [self addNavigationItemForViewController:tweetViewCtl funViewControllerType:funViewTypeTweeter],
                             [self addNavigationItemForViewController:mineViewCtl funViewControllerType:funViewTypeMine]];
    
    NSArray *titles = @[@"音乐",@"频道",@"音乐圈",@"我"];
    NSArray *images = @[@"音乐",@"频道",@"音乐圈",@"我"];
    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop)
     {
         [item setTitle:titles[idx]];
         //设置属性
         [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIColor standerTextColor],NSForegroundColorAttributeName,
                                       [UIFont systemFontOfSize:kTabbarItemTextFont],NSFontAttributeName,nil]
                             forState:UIControlStateNormal];
         [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIColor standerGreenTextColor],NSForegroundColorAttributeName,
                                       [UIFont systemFontOfSize:kTabbarItemTextFont],NSFontAttributeName,nil]
                             forState:UIControlStateSelected];
         item.selectedImage = [[UIImage imageNamed:[images[idx] stringByAppendingString:@"-sTabBar"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
         
         item.image = [[UIImage imageNamed:[images[idx] stringByAppendingString:@"-uTabBar"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
         
         
         
     }];
}



- (UINavigationController *)addNavigationItemForViewController:(UIViewController *)viewController funViewControllerType:(funViewType)type
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.navigationBar.tintColor = [UIColor standerGreenTextColor];
    [navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [UIFont systemFontOfSize:kNavigationTextFont],NSFontAttributeName,
                                                                [UIColor navigationBarTextColor],NSForegroundColorAttributeName, nil]];

    navigationController.navigationBar.translucent = NO;
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar-sidebar"]
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                      action:@selector(onClickMenuButton)];
    switch (type)
    {
        case funViewTypeChannel:

            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                             target:self
                                                                                                             action:@selector(pushSearchViewController)];
            viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:nil
                                                                                              action:nil];
           
            break;
        case funViewTypeMusic:
            
            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                                             target:self
                                                                                                             action:@selector(pushSharedViewController)];
            
            
            viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:nil
                                                                                              action:nil];

            break;
        case funViewTypeTweeter:
            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                                             target:self
                                                                                                             action:@selector(refreshTweeter)];

            break;
        case funViewTypeMine:
            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                             target:self
                                                                                                             action:@selector(pushSearchViewController)];
            viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:nil
                                                                                              action:nil];
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
    if ([funServer fmIsLogin])
    {
        SharedViewController *sharedViewCtl = [[SharedViewController alloc] init];
        
        sharedViewCtl.presidentView = ^(NSInteger index)
        {
            weakSelf.selectedIndex = index;
            [_weakTweetCtl fetchTweetData];
            [_weakTweetCtl.tableView reloadData];
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
    if ([funServer fmIsLogin])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_weakTweetCtl.tableView animated:YES];
        hud.labelText = @"刷新中";
        hud.mode = MBProgressHUDModeIndeterminate;
        //注意GCD的强大的嵌套能力，涉及UI的动作在主线程做，其余可以放在默认并发线程global_queue中做
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            [_weakTweetCtl fetchTweetData];
            [_weakTweetCtl.tableView reloadData];
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
                                       _weakTweetCtl.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                                                    style:UIBarButtonItemStylePlain
                                                                                                                   target:nil
                                                                                                                   action:nil];
                                       
                                       [_weakTweetCtl.navigationController pushViewController:loginCtl animated:YES];
                                       
                                   }];
        [alertController addAction:okAction];
        [_weakTweetCtl presentViewController:alertController animated:YES completion:nil];

    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
