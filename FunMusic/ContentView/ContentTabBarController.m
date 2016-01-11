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
#import "ChannelInfo.h"
#import "ChannelGroup.h"
#import "FunServer.h"


static const CGFloat kTabbarItemTextFont = 12;

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
    
    
}

@end

@implementation ContentTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
//**********************************************SetBlockFunction************************************************
    mineViewCtl.presentView = ^(NSInteger indexPath)
    {
        weakSelf.selectedIndex = indexPath;
    };
    tweetViewCtl.presidentView = ^(NSInteger indexPath)
    {
        weakSelf.selectedIndex = indexPath;
    };
//****************************************************************************************************************
    
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
            
            
            viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
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
    //TO DO...
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
    SharedViewController *sharedViewCtl = [[SharedViewController alloc] init];
    
    sharedViewCtl.presidentView = ^(NSInteger index)
    {
        weakSelf.selectedIndex = index;
        [weakTweetCtl fetchTweetData];
        [weakTweetCtl.tableView reloadData];
    };
    [(UINavigationController *)self.selectedViewController pushViewController:sharedViewCtl animated:YES];
}

- (void)refreshTweeter
{
    [weakTweetCtl.tableView reloadData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
