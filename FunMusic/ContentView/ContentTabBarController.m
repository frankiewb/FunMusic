//
//  ContentTabBarController.m
//  FunMusic
//
//  Created by frankie on 15/12/27.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ContentTabBarController.h"
#import "SearchViewController.h"
#import "ChannelViewController.h"
#import "ChannelGroupController.h"
#import "ChannelInfo.h"
#import "ChannelGroup.h"


static const CGFloat kTabbarItemTextFont = 12;

typedef NS_ENUM(NSInteger, tabBarControllerType)
{
    tabBarControllerTypePlayer = 1,
    tabBarControllerTypeChannel,
    tabBarControllerTypeWeiBo,
    tabBarControllerTypeMine
};



@interface ContentTabBarController ()

@end

@implementation ContentTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    NSArray *channelGroupNames = @[@"推荐",
                                  @"语言",
                                  @"风格",
                                  @"心情"];
    
    NSMutableArray *channelGroupCtr = [[NSMutableArray alloc] init];
    
    for (NSString *singleChannelGroupname in channelGroupNames)
    {
        ChannelGroupController *controller = [[ChannelGroupController alloc] initWithChannelGroupName:singleChannelGroupname ];
        [channelGroupCtr addObject:controller];
    }
    
    ChannelViewController *channelViewCtr = [[ChannelViewController alloc] initWithTitle:@"FUN Music 频道" subTitles:channelGroupNames subTitleCOntrollers:channelGroupCtr];
    
    //取消navigationBar的半透明效果
    self.tabBar.translucent = NO;
    self.viewControllers = @[[self addNavigationItemForViewController:channelViewCtr tabBarControllerType:tabBarControllerTypeChannel]];
    NSArray *titles = @[@"FM频道"];
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
}



- (UINavigationController *)addNavigationItemForViewController:(UIViewController *)viewController tabBarControllerType:(tabBarControllerType)type
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    switch (type)
    {
        case tabBarControllerTypeChannel:
            navigationController.navigationBar.tintColor = [UIColor redColor];
            navigationController.navigationBar.backgroundColor = [UIColor redColor];
            navigationController.navigationBar.translucent = NO;
            viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar-sidebar"]
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:self
                                                                                              action:@selector(onClickMenuButton)];
            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                             target:self
                                                                                                             action:@selector(pushSearchViewController)];
            viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
           

            break;
        case tabBarControllerTypePlayer:
            break;
        case tabBarControllerTypeMine:
            break;
        case tabBarControllerTypeWeiBo:
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

    [(UINavigationController *)self.selectedViewController pushViewController:[[SearchViewController alloc] init] animated:YES];
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
