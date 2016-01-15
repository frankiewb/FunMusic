
//
//  SearchViewController.m
//  FunMusic
//
//  Created by frankie on 15/12/30.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "SearchViewController.h"
#import "ChannelInfo.h"
#import "ChannelGroup.h"
#import "ChannelCell.h"
#import "PlayerInfo.h"
#import "FunServer.h"
#import "Utils.h"
#import "UIColor+Util.h"
#import "AppDelegate.h"



static const CGFloat kFootHeight                 = 0.1;
static const CGFloat kTitleHeight                = 30;
static const CGFloat kRowHeight                  = 80;
static const CGFloat kSeperatorLineLeftDistance  = 30;
static const CGFloat kSeperatorLineRightDistance = 15;
static NSString *kChannelSearchCellID = @"ChannelSearchCellID";


@interface SearchViewController ()<UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong)UISearchController *searchController;
@property (nonatomic, strong)NSMutableArray *filteredChannelInfoCells;
@property (nonatomic, strong)NSMutableArray *_allChannelInfoCells;
@property (nonatomic, strong)FunServer *funServer;
@property (nonatomic, weak)AppDelegate *appDelegate;

@end

@implementation SearchViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _appDelegate = [[UIApplication sharedApplication] delegate];
        _funServer = [[FunServer alloc] init];
        _filteredChannelInfoCells = [[NSMutableArray alloc] init];
        if (!_appDelegate.allChannelGroup)
        {
            _appDelegate.allChannelGroup = [_funServer fmGetAllChannelInfos];

        }
        __allChannelInfoCells = _appDelegate.allChannelGroup;       
        //这个很关键，当从tabbar切换到查找页面时，隐藏tabber界面，回退时还可以恢复
        self.hidesBottomBarWhenPushed = YES;
        
    }
    
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.searchController.active = FALSE;
    [self.searchController.searchBar resignFirstResponder];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.backgroundColor = [UIColor themeColor];
    self.searchController.searchBar.showsCancelButton = YES;
    self.searchController.searchBar.barStyle = UIBarMetricsDefault;
    self.searchController.dimsBackgroundDuringPresentation = false;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"输入要查找的频道名称";
    [self.searchController.searchBar sizeToFit];
    self.navigationItem.titleView = self.searchController.searchBar;
    //哈！！解决Attemping to load the view warning的关键一步，好好研究下深层原因！感谢stackoverflow！
    [self.searchController loadViewIfNeeded];
    
    self.tableView.backgroundColor = [UIColor themeColor];    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:@selector(dismissSearchView)];
   
    
    //注册channelCell
    [self.tableView registerClass:[ChannelCell class] forCellReuseIdentifier:kChannelSearchCellID];
    //解决分割线的距离问题
    self.tableView.separatorInset = UIEdgeInsetsMake(0, kSeperatorLineLeftDistance, 0, kSeperatorLineRightDistance);
}

- (void)dismissSearchView
{
    [self dismissViewControllerAnimated:YES completion:^
     {
         [(UINavigationController *)self.presentingViewController popToRootViewControllerAnimated:YES];
     }];
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
    [self.filteredChannelInfoCells removeAllObjects];
    for (ChannelGroup *singleChannelGroup in __allChannelInfoCells)
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


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    for (UIView *view in [[self.searchController.searchBar.subviews lastObject] subviews])
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            UIButton *cancelBtn = (UIButton *)view;
            [cancelBtn setTitle:@"搜索" forState:UIControlStateNormal];
        }
    }

}




#pragma tableviewController delegate


#pragma mark 返回组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchController.active)
    {
        return 1;
    }
    return __allChannelInfoCells.count;
}


#pragma mark 返回每组行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active)
    {
        return _filteredChannelInfoCells.count;
    }
    ChannelGroup *singleChannelGroup = __allChannelInfoCells[section];
    return singleChannelGroup.channelArray.count;
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
    }
    else
    {
        ChannelGroup *singleChannelGroup = [__allChannelInfoCells objectAtIndex:indexPath.section];
        channelSearchInfo = [singleChannelGroup.channelArray objectAtIndex:indexPath.row];
    }
    [channelSearchCell setUpChannelCellWithChannelInfo:channelSearchInfo];
    
    return channelSearchCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelInfo *selectChannelSearchInfo;
    ChannelInfo *currentChannelInfo;
    if (self.searchController.active)
    {
        selectChannelSearchInfo = _filteredChannelInfoCells[indexPath.row];
    }
    else
    {
        ChannelGroup *singleChannelGroup = [__allChannelInfoCells objectAtIndex:indexPath.section];
        selectChannelSearchInfo = [singleChannelGroup.channelArray objectAtIndex:indexPath.row];
    }
    currentChannelInfo = [_appDelegate.currentPlayerInfo.currentChannel initWithChannelInfo:selectChannelSearchInfo];
    [_funServer fmSongOperationWithType:SongOperationTypeNext];
    //跳转页面
    if (_presidentView)
    {
        _presidentView(0);
    }
    

    
}

#pragma mark 返回每组头标题名称
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.searchController.active)
    {
        return @"频道查询结果";
    }
    ChannelGroup *singleChannelGroup = __allChannelInfoCells[section];
    ChannelType type = singleChannelGroup.channelType;
    return [Utils gennerateChannelGroupNameWithChannelType:type isChineseLanguage:TRUE];
}

#pragma mark修改每组标题字体颜色
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *HeaderView = (UITableViewHeaderFooterView *)view;
    [HeaderView.textLabel setTextColor:[UIColor standerGreenTextColor]];
    [HeaderView.contentView setBackgroundColor:[UIColor themeColor]];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
