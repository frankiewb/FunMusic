//
//  ContentTabBarController.m
//  FunMusic
//
//  Created by frankie on 15/12/27.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ContentTabBarController.h"
#import "FunServer.h"
#import "MusicPlayerViewController.h"
#import "SearchViewController.h"
#import "ChannelViewController.h"
#import "ChannelGroupController.h"
#import "TweetTableVIewController.h"
#import "MineTableViewController.h"
#import "SharedViewController.h"
#import "LoginViewController.h"
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
    __weak ContentTabBarController *_weakSelf;
    FunServer *_funServer;
}

@end

@implementation ContentTabBarController


- (instancetype)init
{
    self = [super self];
    if (self)
    {
        _weakSelf = self;

    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTabBarSubViews];
    [self setTabBarUI];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UINavigationBar appearance] setBarTintColor:[UIColor navigationBarColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor tabbarColor]];
    //之所以放在这里主要是照顾到TabBar和NavigationBar的颜色设置问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dawnAndNightMode:) name:kDawnAndNightMode object:nil];
}

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


- (void)setTabBarSubViews
{
    //Music
    MusicPlayerViewController *musicViewCtl = [MusicPlayerViewController sharedInstance];
    
    //Channel
    NSArray *channelGroupNames = @[@"推荐",@"语言",@"风格",@"心情"];
    NSMutableArray *channelGroupCtrList = [[NSMutableArray alloc] init];
    for (NSString *singleChannelGroupname in channelGroupNames)
    {
        ChannelGroupController *controller = [[ChannelGroupController alloc] initWithChannelGroupName:singleChannelGroupname ];
        controller.presidentView = ^(NSInteger indexPath)
        {
            __strong typeof(self) strongSelf = _weakSelf;
            if (strongSelf)
            {
                strongSelf.selectedIndex = indexPath;
            }
        };
        [channelGroupCtrList addObject:controller];
    }
    ChannelViewController *channelViewCtl = [[ChannelViewController alloc] initWithTitle:@"Fun 频道"
                                                                               subTitles:channelGroupNames
                                                                     subTitleCOntrollers:channelGroupCtrList];
    //Tweet
    TweetTableVIewController *tweetViewCtl = [[TweetTableVIewController alloc] initWithType:tweetViewTypeLocal TweeterName:@"音乐圈"];
    
    //Mine
    MineTableViewController *mineViewCtl = [[MineTableViewController alloc] init];
    
    //addSubViews
    self.tabBar.translucent = NO;
    self.viewControllers = @[[self addNavigationItemForViewController:musicViewCtl funViewControllerType:funViewTypeMusic],
                             [self addNavigationItemForViewController:channelViewCtl funViewControllerType:funViewTypeChannel],
                             [self addNavigationItemForViewController:tweetViewCtl funViewControllerType:funViewTypeTweeter],
                             [self addNavigationItemForViewController:mineViewCtl funViewControllerType:funViewTypeMine]];
    
    _weakTweetCtl = tweetViewCtl;
    _weakMineCtl = mineViewCtl;
}

- (void)setTabBarUI
{
    _funServer = [[FunServer alloc] init];
    NSArray *titles = @[@"音乐",@"频道",@"音乐圈",@"我"];
    NSArray *images = @[@"音乐",@"频道",@"音乐圈",@"我"];
    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop)
     {
         [item setTitle:titles[idx]];
         //设置属性
         [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIColor tabbarTextColor],NSForegroundColorAttributeName,
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
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor standerGreenTextColor];
    [navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [UIFont systemFontOfSize:kNavigationTextFont],NSFontAttributeName,
                                                                [UIColor navigationBarTextColor],NSForegroundColorAttributeName, nil]];
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar-sidebar"]
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                      action:@selector(onClickMenuButton)];
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:nil
                                                                                      action:nil];
    switch (type)
    {
        case funViewTypeChannel:
        case funViewTypeMine:
            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                             target:self
                                                                                                             action:@selector(pushSearchViewController)];
            break;
        case funViewTypeMusic:
            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                                             target:self
                                                                                                             action:@selector(pushSharedViewController)];
            break;
        case funViewTypeTweeter:
            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                                             target:self
                                                                                                             action:@selector(refreshTweeter)];
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
        __strong typeof(self) strongSelf = _weakSelf;
        if (strongSelf)
        {
            strongSelf.selectedIndex = indexPath;
        }
    };
    [(UINavigationController *)self.selectedViewController pushViewController:searchViewCtl animated:YES];
}

- (void)pushSharedViewController
{
    if ([_funServer fmIsLogin])
    {
        SharedViewController *sharedViewCtl = [[SharedViewController alloc] init];
        sharedViewCtl.presidentView = ^(NSInteger index)
        {
            __strong typeof(self) strongSelf = _weakSelf;
            __strong TweetTableVIewController *strongTweetCtl = _weakTweetCtl;
            if (strongSelf && strongTweetCtl)
            {
                strongSelf.selectedIndex = index;
                [strongTweetCtl fetchData];
                [strongTweetCtl.tableView reloadData];
            }
        };
        [(UINavigationController *)self.selectedViewController pushViewController:sharedViewCtl animated:YES];
    }
    else
    {
        [self pushLoginAlertWithMessage:@"请登录后再分享您的频道"];
    }
}

- (void)refreshTweeter
{
    if ([_funServer fmIsLogin])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_weakTweetCtl.tableView animated:YES];
        hud.labelText = @"刷新中";
        hud.mode = MBProgressHUDModeIndeterminate;
        //注意GCD的强大的嵌套能力，涉及UI的动作在主线程做，其余可以放在默认并发线程global_queue中做
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            __strong TweetTableVIewController *strongTweetCtl = _weakTweetCtl;
            if (strongTweetCtl)
            {
                [strongTweetCtl fetchData];
                [strongTweetCtl.tableView reloadData];
                [NSThread sleepForTimeInterval:kRefreshSleepTime];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [hud hide:YES];
                });
            }
        });
    }
    else
    {
        [self pushLoginAlertWithMessage:@"请登录后再刷新您的音乐圈"];
    }
}

- (void)pushLoginAlertWithMessage:(NSString *)message
{
    __weak SideMenuViewController *weakSideMenuCtl = (SideMenuViewController *)self.sideMenuViewController.leftMenuViewController;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请先登录"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
                               {
                                   LoginViewController *loginCtl = [[LoginViewController alloc] init];
                                   loginCtl.updateUserUI = ^()
                                   {
                                       __strong MineTableViewController *strongMineCtl = _weakMineCtl;
                                       __strong SideMenuViewController *strongMenuCtl = weakSideMenuCtl;
                                       if (strongMineCtl && strongMenuCtl)
                                       {
                                           [strongMineCtl refreshUserView];
                                           [strongMenuCtl refreshUserView];
                                       }
                                   };
                                   loginCtl.hidesBottomBarWhenPushed = YES;
                                   [(UINavigationController *)_weakSelf.selectedViewController pushViewController:loginCtl animated:YES];
                                   
                               }];
    [alertController addAction:okAction];
    [_weakSelf.selectedViewController presentViewController:alertController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
