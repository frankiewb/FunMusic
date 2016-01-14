//
//  ChannelGroupController.m
//  FunMusic
//
//  Created by frankie on 15/12/27.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ChannelGroupController.h"
#import "Common.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "ChannelCell.h"
#import "FunServer.h"
#import "PlayerInfo.h"
#import "ChannelInfo.h"
#import "UIColor+Util.h"
#import <MJRefresh.h>


static  NSString *kChannelCellID = @"ChannelCellID";
static const CGFloat kCellHeight = 80;
static const CGFloat kRefreshSleepTime = 0.5;


@interface ChannelGroupController ()
{
    AppDelegate *appDelegate;
    ChannelInfo *currentChannelInfo;
}

@property (nonatomic, strong) ChannelGroup *channelGroup;
@property (nonatomic, strong) FunServer *funServer;
@property (nonatomic, readonly, copy) NSString *channelGroupName;
@property (nonatomic, assign) ChannelType channelGroupType;


@end

@implementation ChannelGroupController

- (instancetype)initWithChannelGroupName:(NSString *)channelGroupName
{
    self = [super init];
    if (self)
    {
        appDelegate = [[UIApplication sharedApplication] delegate];
        _funServer = [[FunServer alloc] init];
        _channelGroupName = channelGroupName;
        _channelGroupType = [Utils gennerateChannelGroupTypeWithChannelName:channelGroupName];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.backgroundColor = [UIColor themeColor];
    
    //添加MJRefresh
    __weak ChannelGroupController *weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^
    {
        [weakSelf refreshData];
    }];
    self.tableView.mj_header = header;
    [self fetchChannelGroupData];
    //注册ChannelCell,注意不能传const引起警告
    [self.tableView registerClass:[ChannelCell class] forCellReuseIdentifier:kChannelCellID];
    
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)refreshData
{
    //刷新另外开辟异步线程执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        [self fetchChannelGroupData];
    });
    //刷新完后，暂停若干时间
    [NSThread sleepForTimeInterval:kRefreshSleepTime];
    
    [self.tableView.mj_header endRefreshing];
}

- (void)fetchChannelGroupData
{
    //本案中，因为数据从本地读取的，故当读取一次后不再读取
    if (!_channelGroup)
    {
        [_funServer fmGetChannelWithTypeInLocal:_channelGroupType];
        _channelGroup = appDelegate.currentChannelGroup;
    }
}


#pragma mark - Tableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _channelGroup.channelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelCell *channelCell = [tableView dequeueReusableCellWithIdentifier:kChannelCellID forIndexPath:indexPath];
    ChannelInfo *channelInfo= _channelGroup.channelArray[indexPath.row];
    [channelCell setUpChannelCellWithChannelInfo:channelInfo];

    
    return channelCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelInfo *selectChannelInfo = _channelGroup.channelArray[indexPath.row];
    currentChannelInfo = [appDelegate.currentPlayerInfo.currentChannel initWithChannelInfo:selectChannelInfo];
    [_funServer fmSongOperationWithType:SongOperationTypeNext];
    //跳转至首页音乐播放界面
    if (_presidentView)
    {
        //后面变成ENUM
        _presidentView(0);
    }
    
}






@end
