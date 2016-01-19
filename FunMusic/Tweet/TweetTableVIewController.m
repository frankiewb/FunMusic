//
//  TweetTableVIewController.m
//  FunMusic
//
//  Created by frankie on 16/1/2.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "TweetTableVIewController.h"
#import "TweetCell.h"
#import "TweetInfo.h"
#import "ChannelInfo.h"
#import "FunServer.h"
#import "LoginViewController.h"
#import "MineTableViewController.h"
#import "ContentTabBarController.h"
#import "Utils.h"
#import "UIColor+Util.h"
#import "Config.h"
#import <MJRefresh.h>
#import <RESideMenu.h>


static const CGFloat kRefreshSleepTime           = 0.5;
static const CGFloat kSeperatorLineLeftDistance  = 10;
static const CGFloat kSeperatorLineRightDistance = 10;
static NSString *kTweetCellID                    = @"TweetCellID";

@interface TweetTableVIewController ()
{
    FunServer *_funServer;
    NSMutableArray *_tweetGroup;
    tweetViewType _tweetType;
}

@end

@implementation TweetTableVIewController


- (void)dawnAndNightMode
{
    self.tableView.backgroundColor = [UIColor themeColor];
    dispatch_async(dispatch_get_main_queue(), ^
    {        
        [self.tableView reloadData];
    });
}


- (instancetype)initWithType:(tweetViewType)type TweeterName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        _funServer = [[FunServer alloc] init];
        _tweetType = type;
        self.title = name;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpTableViewUI];
    [self fetchData];
}

- (void)setUpTableViewUI
{
    self.tableView.backgroundColor = [UIColor themeColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //添加MJrefresh
    __weak TweetTableVIewController *weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^
    {
        [weakSelf refreshData];
    }];
    self.tableView.mj_header = header;
    [self.tableView registerClass:[TweetCell class] forCellReuseIdentifier:kTweetCellID];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //解决分割线的距离问题
    self.tableView.separatorInset = UIEdgeInsetsMake(0, kSeperatorLineLeftDistance, 0, kSeperatorLineRightDistance);
}


- (void)refreshData
{
    //refresh之前检查是否登录
    
    if ([_funServer fmIsLogin])
    {
        //开辟异步并发线程
        //子线程更新数据，主线程可以用来显示数据状态，注意GCD可以嵌套
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            [self fetchData];
        });
        //刷新完后，暂停若干时间
        [NSThread sleepForTimeInterval:kRefreshSleepTime];
        [self.tableView reloadData];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请先登录"
                                                                                 message:@"请登录后再刷新您的音乐圈"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    [self.tableView.mj_header endRefreshing];
    

}

- (void)fetchData
{
    if (!_tweetGroup)
    {
        _tweetGroup = [_funServer fmGetTweetInfoWithType:_tweetType];
    }
}


#pragma TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tweetGroup.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell *tweetCell = [tableView dequeueReusableCellWithIdentifier:kTweetCellID forIndexPath:indexPath];
    [tweetCell dawnAndNightMode];
    TweetInfo *tweetInfo = _tweetGroup[indexPath.row];
    [tweetCell setUpTweetCellWithTweetInfo:tweetInfo];
    
    //**********************SetTweetBlock Function******************************************************
    __weak TweetTableVIewController *weakSelf = self;
    __weak FunServer *weakFunServer = _funServer;
    __weak TweetTableVIewController *weakMainTweetCtl = ((ContentTabBarController *)self.sideMenuViewController.contentViewController).weakTweetCtl;
    tweetCell.deleteTweetCell = ^(NSString *tweetID)
    {
        [weakFunServer fmDeleteTweetInfoWithTweetID:tweetID];
        [weakSelf.tableView reloadData];
        if (_tweetType != tweetViewTypeLocal)
        {
            [weakMainTweetCtl.tableView reloadData];
        }
    };
    
    tweetCell.scrollView = ^(NSInteger index, NSString *channelName)
    {
        ChannelInfo *channelInfo = [weakFunServer fmSearchChannelInfoWithName:channelName];
        [weakFunServer fmUpdateCurrentChannelInfo:channelInfo];
        [weakFunServer fmSongOperationWithType:SongOperationTypeNext];
        ((UITabBarController *)weakSelf.sideMenuViewController.contentViewController).selectedIndex = funViewTypeMusic;
    };
    
    tweetCell.updateTweetLikeCount = ^(NSString *tweetID,BOOL isLike, BOOL isMineTweet)
    {
        [weakFunServer fmUpdateTweetLikeCountWithTweetID:tweetID like:isLike isMineTweet:isMineTweet];
        [weakSelf.tableView reloadData];
        if (_tweetType != tweetViewTypeLocal)
        {
            [weakMainTweetCtl.tableView reloadData];
        }
    };
    //****************************************************************************************************

    return tweetCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetInfo *currentTweetInfo = _tweetGroup[indexPath.row];
    NSAssert(currentTweetInfo.cellHeight, @"CellHeight has not been caculated !");
    return currentTweetInfo.cellHeight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
