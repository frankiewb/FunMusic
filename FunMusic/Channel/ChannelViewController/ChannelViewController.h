//
//  SwipableViewController.h
//  FunMusic
//
//  Created by frankie on 15/12/26.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitlebarView.h"
#import "HorizonalTableViewController.h"

@interface ChannelViewController : UIViewController

@property (nonatomic, strong) HorizonalTableViewController *viewPager;
@property (nonatomic, strong) TitlebarView *titleBar;



- (instancetype)initWithTitle:(NSString *)title subTitles:(NSArray *)subTitles subTitleCOntrollers:(NSArray *)controllers;

@end
