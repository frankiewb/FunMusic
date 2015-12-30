//
//  SwipableViewController.m
//  FunMusic
//
//  Created by frankie on 15/12/26.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ChannelViewController.h"
#import "TitlebarView.h"
#include "Common.h"



static const CGFloat kTitleBarHeight = 36;
static const CGFloat kFirstButtonScale = 1.2;
static const CGFloat kNavigationbarHeight = 64;
static const CGFloat kTabbarHeight = 49;


@interface ChannelViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *controllers;
extern const CGFloat kFirstButtonScale;

@end

@implementation ChannelViewController



- (instancetype)initWithTitle:(NSString *)title subTitles:(NSArray *)subTitles subTitleCOntrollers:(NSArray *)controllers
{
    self = [super init];
    if (self)
    {
        //IOS7 鼓励全屏布局，默认值为UIRectEdgeAll，四周边缘延伸，
        //即如果视图中上有navigationBar，下有tabBar，那么视图仍然会延展覆盖到四周，解决办法采用UIRectEdgeNone
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.view.backgroundColor = [UIColor redColor];
        
        //添加titleBar
        if (title)
        {
            self.title = title;
        }
        CGFloat titleBarHeight = kTitleBarHeight;
        _titleBar = [[TitlebarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, titleBarHeight)
                                             titleNames:subTitles];
        
        _titleBar.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_titleBar];
        
        
        //添加ViewPager
        _viewPager = [[HorizonalTableViewController alloc] initWithViewControllers:controllers];
        CGFloat viewPagerHeight = self.view.bounds.size.height - kTitleBarHeight - kNavigationbarHeight - kTabbarHeight;
        _viewPager.view.frame = CGRectMake(0, kTitleBarHeight, self.view.bounds.size.width, viewPagerHeight);
        
        
        _viewPager.tableView.backgroundColor = [UIColor yellowColor];
        
        
        [self addChildViewController:self.viewPager];
        [self.view addSubview:_viewPager.view];
        
        
       
         //set block operation for TitlebarView and HorizonalTableviewController
        
        __weak TitlebarView *weakTitleBar = _titleBar;
        __weak HorizonalTableViewController *weakViewPager = _viewPager;
        
        _titleBar.titleButtonClicked = ^(NSInteger index)
        {
            weakTitleBar.currentIndex = index;
            for (UIButton *button in weakTitleBar.titleButtonArray)
            {
                if (button.tag != index)
                {
                    [button setTitleColor:TITLECOLOR forState:UIControlStateNormal];
                    button.transform = CGAffineTransformIdentity;
                }
                else
                {
                    [button setTitleColor:FIRSTTITLECOLOR forState:UIControlStateNormal];
                    button.transform = CGAffineTransformMakeScale(kFirstButtonScale, kFirstButtonScale);
                }
            }

            [weakViewPager scrollToViewAtIndex:index];
        };
        
        _viewPager.changeIndex = ^(NSInteger index)
        {
            if (weakTitleBar.titleButtonClicked)
            {
                weakTitleBar.titleButtonClicked(index);
            }
            
            [weakViewPager scrollToViewAtIndex:index];
        };
    }
    
    return  self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HORIZONALBACKGROUNDCOLOR;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
