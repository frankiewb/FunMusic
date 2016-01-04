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
#import "FunServer.h"
#import "AppDelegate.h"
#import "Utils.h"
#import <MJRefresh.h>




static NSString *kTweetCellID = @"TweetCellID";
static const CGFloat kRefreshSleepTime = 0.5;

@interface TweetTableVIewController ()
{
    AppDelegate *appDelegate;
    FunServer *funServer;
    NSMutableArray *tweetInfoGroup;
    ChannelInfo *currentChannelInfo;
}

@end

@implementation TweetTableVIewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        appDelegate = [[UIApplication sharedApplication] delegate];
        funServer = [[FunServer alloc] init];
        self.title = @"音乐圈";
    }
    
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //添加MJrefresh
    __weak TweetTableVIewController *weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^
    {
        [weakSelf refreshData];
    }];
    self.tableView.mj_header = header;
    [self fetchTweetData];
    [self.tableView registerClass:[TweetCell class] forCellReuseIdentifier:kTweetCellID];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshData
{
    //刷新另外开辟异步线程执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       [self fetchTweetData];
                   });
    //刷新完后，暂停若干时间
    [NSThread sleepForTimeInterval:kRefreshSleepTime];
    
    [self.tableView.mj_header endRefreshing];

}

- (void)fetchTweetData
{
    //本案中，因为数据是从本地读取的，故当读取一次后不再读取
    if (!tweetInfoGroup)
    {
        [funServer fmGetTweetInfoInLocal];
        tweetInfoGroup = appDelegate.tweetInfoGroup;
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
    TweetInfo *tweetInfo = tweetInfoGroup[indexPath.row];
    [tweetCell setUpTweetCellWithTweetInfo:tweetInfo];
    
    //**********************SetTweetBlock Function******************************************************
    __weak TweetTableVIewController *weakSelf = self;
    __weak NSMutableArray *weakTweetInfoGroup = tweetInfoGroup;
    __weak AppDelegate *weakAppDelegate = appDelegate;
    __weak FunServer *weakFunServer = funServer;
    tweetCell.deleteTweetCell = ^(NSString *tweetID)
    {
        NSInteger tweetIndex = [weakFunServer searchTweetInfoWithID:tweetID];
        [weakTweetInfoGroup removeObjectAtIndex:tweetIndex];
        //TO DO ...
        //updateServer()
        //Reload TableView
        [weakSelf.tableView reloadData];
    };
    
    tweetCell.scrollView = ^(NSInteger index, NSString *channelName)
    {
        ChannelInfo *channelInfo = [weakFunServer searchChannelInfoWithName:channelName];
        currentChannelInfo = [weakAppDelegate.currentPlayerInfo.currentChannel initWithChannelInfo:channelInfo];
        [weakFunServer fmSongOperationWithType:SongOperationTypeNext];
        if (weakSelf.presidentView)
        {
          _presidentView(index);
        }
    };
    
    tweetCell.updateTweetLikeCount = ^(NSString *tweetID,BOOL isLike)
    {
        [weakFunServer fmUpdateTweetLikeCountWithTweetID:tweetID like:isLike];
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
