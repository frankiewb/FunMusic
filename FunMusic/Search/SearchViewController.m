
//
//  SearchViewController.m
//  FunMusic
//
//  Created by frankie on 15/12/30.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchController.h"
#import "ChannelInfo.h"
#import "ChannelGroup.h"
#import "ChannelCell.h"
#import "FunServer.h"
#import "Utils.h"
#import "UIColor+Util.h"



static const CGFloat kFootHeight                 = 0.1;
static const CGFloat kTitleHeight                = 30;
static const CGFloat kRowHeight                  = 80;
static const CGFloat kSeperatorLineLeftDistance  = 30;
static const CGFloat kSeperatorLineRightDistance = 15;
static NSString *kChannelSearchCellID = @"ChannelSearchCellID";


@interface SearchViewController ()<UISearchResultsUpdating, UISearchBarDelegate>
{
    FunServer *_funServer;
    NSMutableArray *_filteredChannelInfoCells;
    NSMutableArray *_allChannelInfoCells;
}

@property (nonatomic, strong)UISearchController *searchController;

@end

@implementation SearchViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _funServer = [[FunServer alloc] init];
    }
    
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.searchController.active = FALSE;
    [self.searchController.searchBar resignFirstResponder];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpSearchUI];
    [self setUpTableViewUI];
    [self fetchData];
}

- (void)setUpTableViewUI
{
    self.tableView.backgroundColor = [UIColor themeColor];
    self.hidesBottomBarWhenPushed = YES;
    //注册channelCell
    [self.tableView registerClass:[ChannelCell class] forCellReuseIdentifier:kChannelSearchCellID];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //解决分割线的距离问题
    self.tableView.separatorInset = UIEdgeInsetsMake(0, kSeperatorLineLeftDistance, 0, kSeperatorLineRightDistance);
}

- (void)setUpSearchUI
{
    self.searchController = [[SearchController alloc] initWithSearchResultsController:nil];
    //这个很关键，当从tabbar切换到查找页面时，隐藏tabber界面，回退时还可以恢复
    self.searchController.searchResultsUpdater = self;
    self.navigationItem.titleView = self.searchController.searchBar;
    //哈！！解决Attemping to load the view warning的关键一步，好好研究下深层原因！感谢stackoverflow！注意，只能在ios9下使用
    [self.searchController loadViewIfNeeded];
}

- (void)fetchData
{
    if (!_filteredChannelInfoCells)
    {
        _filteredChannelInfoCells = [[NSMutableArray alloc] init];
    }
    if (!_allChannelInfoCells)
    {
        _allChannelInfoCells = [_funServer fmGetSearchChannelList];
    }
}



#pragma mark - searchController delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self channelSearchFilterWithSearchText:self.searchController.searchBar.text];
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.tableView reloadData];
    });
}

- (void)channelSearchFilterWithSearchText:(NSString *)searchText
{
    [_filteredChannelInfoCells removeAllObjects];
    for (ChannelGroup *singleChannelGroup in _allChannelInfoCells)
    {
        for (ChannelInfo *singleChannelInfo in singleChannelGroup.channelArray)
        {
            //只要包含任意值就算部分匹配并返回
            if ([singleChannelInfo.channelName rangeOfString:searchText].location != NSNotFound)
            {
                [_filteredChannelInfoCells addObject:singleChannelInfo];
            }
        }
    }
}

#pragma mark tableviewController delegate


#pragma mark 返回组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchController.active)
    {
        return 1;
    }
    return 0;
}


#pragma mark 返回每组行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active)
    {
        return _filteredChannelInfoCells.count;
    }
    return 0;
}

#pragma mark 设置分组标题内容高度
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTitleHeight;
}

#pragma mark 设置分组标题高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTitleHeight;
}

#pragma mark 设置尾部说明高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kFootHeight;
}

#pragma mark 设置每行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRowHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelInfo *channelSearchInfo;
    ChannelCell *channelSearchCell = [tableView dequeueReusableCellWithIdentifier:kChannelSearchCellID forIndexPath:indexPath];
    if (self.searchController.active)
    {
        channelSearchInfo = _filteredChannelInfoCells[indexPath.row];
        [channelSearchCell setUpChannelCellWithChannelInfo:channelSearchInfo];
    }
    return channelSearchCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelInfo *selectChannelSearchInfo;
    if (self.searchController.active)
    {
        selectChannelSearchInfo = _filteredChannelInfoCells[indexPath.row];
        [_funServer fmUpdateCurrentChannelInfo:selectChannelSearchInfo];
        [_funServer fmSongOperationWithType:SongOperationTypeNext];
        //跳转页面
        if (_presidentView)
        {
            [self.navigationController popViewControllerAnimated:NO];
            _presidentView(funViewTypeMusic);
        }
    }
}

#pragma mark 返回每组头标题名称
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.searchController.active)
    {
        return @"频道查询结果";
    }
    return @"";
}

#pragma mark修改每组标题字体颜色
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *HeaderView = (UITableViewHeaderFooterView *)view;
    [HeaderView.textLabel setTextColor:[UIColor standerGreenTextColor]];
    [HeaderView.contentView setBackgroundColor:[UIColor themeColor]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
