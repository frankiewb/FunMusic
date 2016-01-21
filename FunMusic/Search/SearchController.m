//
//  SearchController.m
//  FunMusic
//
//  Created by frankie on 16/1/19.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "SearchController.h"
#import "UIColor+Util.h"

@interface SearchController ()

@end

@implementation SearchController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchBar.backgroundColor = [UIColor themeColor];
    self.searchBar.showsCancelButton = YES;
    self.searchBar.barStyle = UIBarMetricsDefault;
    self.dimsBackgroundDuringPresentation = false;
    self.hidesNavigationBarDuringPresentation = NO;
    self.searchBar.placeholder = @"输入要查找的频道名称";
    [self.searchBar sizeToFit];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.active = FALSE;
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
