//
//  ContentTabBarController.h
//  FunMusic
//
//  Created by frankie on 15/12/27.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MineTableViewController;

@interface ContentTabBarController : UITabBarController

@property (nonatomic, weak) MineTableViewController *weakMineCtl;

@end
