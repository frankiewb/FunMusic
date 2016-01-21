//
//  SwipableViewController.m
//  FunMusic
//
//  Created by frankie on 15/12/26.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ChannelViewController.h"
#import "TitlebarView.h"
#import "UIColor+Util.h"



static const CGFloat kTitleBarHeight      = 36;
static const CGFloat kFirstButtonScale    = 1.2;
static const CGFloat kNavigationbarHeight = 64;
static const CGFloat kTabbarHeight        = 49;
extern const CGFloat kFirstButtonScale;


@interface ChannelViewController () <UIScrollViewDelegate>

@end

@implementation ChannelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor themeColor];
}


- (void)dawnAndNightMode
{
    [_titleBar dawnAndNightMode];
    [_viewPager.controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        UITableViewController *channelGroupCtl = obj;
        channelGroupCtl.tableView.backgroundColor = [UIColor themeColor];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [channelGroupCtl.tableView reloadData];
        });        
    }];
}


- (instancetype)initWithTitle:(NSString *)title subTitles:(NSArray *)subTitles subTitleCOntrollers:(NSArray *)controllers
{
    self = [super init];
    if (self)
    {
        //IOS7 鼓励全屏布局，默认值为UIRectEdgeAll，四周边缘延伸，
        //即如果视图中上有navigationBar，下有tabBar，那么视图仍然会延展覆盖到四周，解决办法采用UIRectEdgeNone
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        //添加titleBar
        if (title)
        {
            self.title = title;
        }
        CGFloat titleBarHeight = kTitleBarHeight;
        _titleBar = [[TitlebarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, titleBarHeight)
                                             titleNames:subTitles];
        [self.view addSubview:_titleBar];
        
        //添加ViewPager
        _viewPager = [[HorizonalTableViewController alloc] initWithViewControllers:controllers];
        CGFloat viewPagerHeight = self.view.bounds.size.height - kTitleBarHeight - kNavigationbarHeight - kTabbarHeight;
        _viewPager.view.frame = CGRectMake(0, kTitleBarHeight, self.view.bounds.size.width, viewPagerHeight);
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
                    [button setTitleColor:[UIColor standerTextColor] forState:UIControlStateNormal];
                    button.transform = CGAffineTransformIdentity;
                }
                else
                {
                    [button setTitleColor:[UIColor standerGreenTextColor] forState:UIControlStateNormal];
                    button.transform = CGAffineTransformMakeScale(kFirstButtonScale, kFirstButtonScale);
                }
            }

            [weakViewPager scrollToViewAtIndex:index];
        };
        
        _viewPager.changeIndex = ^(NSInteger index)
        {
            __strong TitlebarView *strongTitleBar = weakTitleBar;
            __strong HorizonalTableViewController *strongViewPager = weakViewPager;
            if (strongTitleBar && strongViewPager)
            {
                if (strongTitleBar.titleButtonClicked)
                {
                    strongTitleBar.titleButtonClicked(index);
                }                
                [strongViewPager scrollToViewAtIndex:index];
            }
        };
    }
    
    return  self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
