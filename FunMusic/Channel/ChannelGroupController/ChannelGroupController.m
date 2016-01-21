//
//  ChannelGroupController.m
//  FunMusic
//
//  Created by frankie on 15/12/27.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ChannelGroupController.h"
#import "Utils.h"
#import "ChannelCell.h"
#import "FunServer.h"
#import "ChannelInfo.h"
#import "UIColor+Util.h"
#import "Config.h"
#import <MJRefresh.h>



static const CGFloat kCellHeight                 = 80;
static const CGFloat kRefreshSleepTime           = 0.5;
static const CGFloat kSeperatorLineLeftDistance  = 90;
static const CGFloat kSeperatorLineRightDistance = 15;
static  NSString *kChannelCellID                 = @"ChannelCellID";


@interface ChannelGroupController ()
{
    FunServer *_funServer;
    ChannelType _channelGroupType;
    ChannelGroup *_channelGroup;
}

@end

@implementation ChannelGroupController

- (instancetype)initWithChannelGroupName:(NSString *)channelGroupName
{
    self = [super init];
    if (self)
    {
        _funServer = [[FunServer alloc] init];
        _channelGroupType = [Utils getChannelGroupTypeWithChannelName:channelGroupName];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpTableviewUI];
}

- (void)setUpTableviewUI
{
    //添加MJRefresh
    __weak ChannelGroupController *weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^
    {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf)
        {
             [strongSelf refreshData];
        }       
    }];
    self.tableView.mj_header = header;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.backgroundColor = [UIColor themeColor];
    [self fetchData];
    [self.tableView registerClass:[ChannelCell class] forCellReuseIdentifier:kChannelCellID];
    //解决分割线的左右距离问题
    self.tableView.separatorInset = UIEdgeInsetsMake(0, kSeperatorLineLeftDistance, 0, kSeperatorLineRightDistance);
}



- (void)refreshData
{
    //刷新另外开辟异步线程执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        [self fetchData];
    });
    //刷新完后，暂停若干时间
    [NSThread sleepForTimeInterval:kRefreshSleepTime];
    [self.tableView.mj_header endRefreshing];
}

- (void)fetchData
{
    //本案中，因为数据从本地读取的，故当读取一次后不再读取
    if (!_channelGroup)
    {
        _channelGroup  = [_funServer fmGetChannelWithTypeInLocal:_channelGroupType];
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
    [channelCell dawnAndNightMode];
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
    [_funServer fmUpdateCurrentChannelInfo:selectChannelInfo];
    [_funServer fmSongOperationWithType:SongOperationTypeNext];
    //跳转至首页音乐播放界面
    if (_presidentView)
    {
        _presidentView(funViewTypeMusic);
    }    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
