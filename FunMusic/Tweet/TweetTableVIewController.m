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
#import "PlayerInfo.h"
#import "UserInfo.h"
#import "FunServer.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MineTableViewController.h"
#import "ContentTabBarController.h"
#import "Utils.h"
#import "UIColor+Util.h"
#import <MJRefresh.h>
#import <RESideMenu.h>





static const CGFloat kRefreshSleepTime           = 0.5;
static const CGFloat kSeperatorLineLeftDistance  = 10;
static const CGFloat kSeperatorLineRightDistance = 10;
static NSString *kTweetCellID      = @"TweetCellID";

@interface TweetTableVIewController ()
{
    AppDelegate *appDelegate;
    FunServer *funServer;
    NSMutableArray *tweetInfoGroup;
    ChannelInfo *currentChannelInfo;
    NSString *userID;
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


- (instancetype)initWithUserID:(NSString *)ID TweeterName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        appDelegate = [[UIApplication sharedApplication] delegate];
        funServer = [[FunServer alloc] init];
        userID = ID;
        self.title = name;
    }
    
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.backgroundColor = [UIColor themeColor];
    
    //添加MJrefresh
    __weak TweetTableVIewController *weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^
    {
        [weakSelf refreshData];
    }];
    self.tableView.mj_header = header;
    [self fetchTweetData];
    [self.tableView registerClass:[TweetCell class] forCellReuseIdentifier:kTweetCellID];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //解决分割线的距离问题
    self.tableView.separatorInset = UIEdgeInsetsMake(0, kSeperatorLineLeftDistance, 0, kSeperatorLineRightDistance);


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshData
{
    //refresh之前检查是否登录
    
    if (appDelegate.isLogin)
    {
        //开辟异步并发线程
        //子线程更新数据，主线程可以用来显示数据状态，注意GCD可以嵌套
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           [self fetchTweetData];
                       });
        //刷新完后，暂停若干时间
        [self.tableView reloadData];
        [NSThread sleepForTimeInterval:kRefreshSleepTime];
        
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

- (void)fetchTweetData
{
    //本案中，因为数据是从本地读取的，故当读取一次后不再读取
    //这是针对该app情况设计的逻辑，如果有真正的服务器，逻辑应该比此逻辑简单。
    if (!tweetInfoGroup)
    {
        if ([userID isEqualToString:@"localTweetData"])
        {
            [funServer fmGetTweetInfoInLocal];
            tweetInfoGroup = appDelegate.tweetInfoGroup;
        }
        else if ([userID isEqualToString:@"mine"])
        {
            tweetInfoGroup = appDelegate.currentUserInfo.userTweeterList;
        }
        else
        {
            tweetInfoGroup = [funServer fmGetTweetInfoWithUserID:userID];
        }
        
    }
    
}


#pragma TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tweetInfoGroup.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell *tweetCell = [tableView dequeueReusableCellWithIdentifier:kTweetCellID forIndexPath:indexPath];
    [tweetCell dawnAndNightMode];
    TweetInfo *tweetInfo = tweetInfoGroup[indexPath.row];
    [tweetCell setUpTweetCellWithTweetInfo:tweetInfo];
    
    //**********************SetTweetBlock Function******************************************************
    __weak TweetTableVIewController *weakSelf = self;
    __weak NSMutableArray *weakTweetInfoGroup = appDelegate.tweetInfoGroup;
    __weak NSMutableArray *weakMyTweetInfoGroup = appDelegate.currentUserInfo.userTweeterList;
    __weak AppDelegate *weakAppDelegate = appDelegate;
    __weak FunServer *weakFunServer = funServer;
    __weak TweetTableVIewController *weakMainTweetCtl = ((ContentTabBarController *)self.sideMenuViewController.contentViewController).weakTweetCtl;
    tweetCell.deleteTweetCell = ^(NSString *tweetID)
    {
        NSInteger tweetIndex = [weakFunServer searchTweetInfoWithID:tweetID isMyTweetGroup:NO];
        [weakTweetInfoGroup removeObjectAtIndex:tweetIndex];
        NSInteger myTweetIndex = [weakFunServer searchTweetInfoWithID:tweetID isMyTweetGroup:YES];
        [weakMyTweetInfoGroup removeObjectAtIndex:myTweetIndex];
        
        //TO DO ...
        //updateServer()
        //Reload TableView
        [self.tableView reloadData];
        if (![userID isEqualToString:@"localTweetData"])
        {
            [weakMainTweetCtl.tableView reloadData];
        }
        
    };
    
    tweetCell.scrollView = ^(NSInteger index, NSString *channelName)
    {
        ChannelInfo *channelInfo = [weakFunServer searchChannelInfoWithName:channelName];
        currentChannelInfo = [weakAppDelegate.currentPlayerInfo.currentChannel initWithChannelInfo:channelInfo];
        [weakFunServer fmSongOperationWithType:SongOperationTypeNext];
        ((UITabBarController *)weakSelf.sideMenuViewController.contentViewController).selectedIndex = 0;
    };
    
    tweetCell.updateTweetLikeCount = ^(NSString *tweetID,BOOL isLike)
    {
        [weakFunServer fmUpdateTweetLikeCountWithTweetID:tweetID like:isLike];
        [self.tableView reloadData];
        if (![userID isEqualToString:@"localTweetData"])
        {
            [weakMainTweetCtl.tableView reloadData];
        }
        
    };
    
    //****************************************************************************************************

    return tweetCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetInfo *currentTweetInfo = tweetInfoGroup[indexPath.row];
    NSAssert(currentTweetInfo.cellHeight, @"CellHeight has not been caculated !");
    return currentTweetInfo.cellHeight;
}



@end
