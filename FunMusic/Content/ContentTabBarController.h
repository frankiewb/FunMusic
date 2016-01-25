//
//  ContentTabBarController.h
//  FunMusic
//
//  Created by frankie on 15/12/27.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MineTableViewController;
@class TweetTableVIewController;
@class MusicPlayerViewController;

@interface ContentTabBarController : UITabBarController

@property (nonatomic, weak) MineTableViewController *weakMineCtl;
@property (nonatomic, weak) TweetTableVIewController *weakTweetCtl;
@property (nonatomic, weak) MusicPlayerViewController *weakMusicCtl;


@end
