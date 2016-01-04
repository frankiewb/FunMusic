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
#import "ChannelInfo.h"
#import "ChannelGroup.h"


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
    
    ChannelViewController *channelViewCtr = [[ChannelViewController alloc] initWithTitle:@"FUN Music 频道"
                                                                               subTitles:channelGroupNames
                                                                     subTitleCOntrollers:channelGroupCtrList];
    
    MusicPlayerViewController *musicViewCtr = [[MusicPlayerViewController alloc] init];
    
    TweetTableVIewController *tweetViewCtr = [[TweetTableVIewController alloc] init];
    
    //set TweetView block Function
    tweetViewCtr.presidentView = ^(NSInteger indexPath)
    {
        weakSelf.selectedIndex = indexPath;
    };
    
    //取消navigationBar的半透明效果
    self.tabBar.translucent = NO;
    self.viewControllers = @[[self addNavigationItemForViewController:musicViewCtr tabBarControllerType:tabBarControllerTypePlayer],
                             [self addNavigationItemForViewController:channelViewCtr tabBarControllerType:tabBarControllerTypeChannel],
                             [self addNavigationItemForViewController:tweetViewCtr tabBarControllerType:tabBarControllerTypeTweeter]];
    NSArray *titles = @[@"音乐",@"FM频道",@"音乐圈"];
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
    
    //SetBlockFunction
    
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
            viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
           
            break;
        case tabBarControllerTypePlayer:

            break;
        case tabBarControllerTypeTweeter:

            break;
        case tabBarControllerTypeMine:
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








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
