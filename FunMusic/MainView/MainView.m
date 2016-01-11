//
//  MainView.m
//  FunMusic
//
//  Created by frankie on 16/1/11.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "MainView.h"
#import "ContentTabBarController.h"
#import "SideBarViewController.h"
#import "MineTableViewController.h"

static const CGFloat kContentScaleValue = 0.95;
static const CGFloat kContentShadowRadius = 4.5;
@interface MainView ()

@end

@implementation MainView


- (void)awakeFromNib
{
    self.parallaxEnabled = NO;
    self.scaleContentView = YES;
    self.contentViewScaleValue = kContentScaleValue;
    self.scaleMenuView = NO;
    self.contentViewShadowEnabled = YES;
    self.contentViewShadowRadius = kContentShadowRadius;
    
    ContentTabBarController *contentTabBarCtl = [[ContentTabBarController alloc] init];
    SideBarViewController *sideBarCtl = [[SideBarViewController alloc] init];
    
    self.contentViewController = contentTabBarCtl;
    self.leftMenuViewController = sideBarCtl;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
