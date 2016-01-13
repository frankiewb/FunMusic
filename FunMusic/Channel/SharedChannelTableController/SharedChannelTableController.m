//
//  SharedChannelTableController.m
//  FunMusic
//
//  Created by frankie on 16/1/13.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "SharedChannelTableController.h"
#import "ChannelCell.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "ChannelInfo.h"
#import "FunServer.h"
#import "PlayerInfo.h"
#import <MJRefresh.h>





static  NSString *kChannelCellID = @"ChannelCellID";
static const CGFloat kCellHeight = 80;
static const CGFloat kRefreshSleepTime = 0.5;

@interface SharedChannelTableController ()
{
    AppDelegate *appDelegate;
    NSMutableArray *sharedChannelGroup;
    FunServer *funServer;
    ChannelInfo *currentChannelInfo;
    
}


@end

@implementation SharedChannelTableController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    appDelegate = [[UIApplication sharedApplication] delegate];
    funServer = [[FunServer alloc] init];
    self.title = @"我的频道";
    
    //添加MJRefresh
    __weak SharedChannelTableController *weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^
    {
        [weakSelf refreshData];
    }];
    self.tableView.mj_header = header;
    [self fetchSharedChannelData];
    [self.tableView registerClass:[ChannelCell class] forCellReuseIdentifier:kChannelCellID];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
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
                       [self fetchSharedChannelData];
                   });
    //刷新完后，暂停若干时间
    [NSThread sleepForTimeInterval:kRefreshSleepTime];
    
    [self.tableView.mj_header endRefreshing];

}

- (void)fetchSharedChannelData
{
    if (!sharedChannelGroup)
    {
        sharedChannelGroup = appDelegate.currentUserInfo.userSharedChannelLists;
    }
}

#pragma mark -TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sharedChannelGroup.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelCell *channelCell = [tableView dequeueReusableCellWithIdentifier:kChannelCellID forIndexPath:indexPath];
    ChannelInfo *channelInfo = sharedChannelGroup[indexPath.row];
    [channelCell setUpChannelCellWithChannelInfo:channelInfo];
    return channelCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelInfo *selectChannelInfo = sharedChannelGroup[indexPath.row];
    currentChannelInfo = [appDelegate.currentPlayerInfo.currentChannel initWithChannelInfo:selectChannelInfo];
    [funServer fmSongOperationWithType:SongOperationTypeNext];
    //跳转至首页音乐播放界面
    if (_presidentView)
    {
        //后面变成ENUM
        _presidentView(0);
    }
    
}



#pragma tableviewCell delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TRUE;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [sharedChannelGroup removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}


@end