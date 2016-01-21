//
//  MineTableViewController.m
//  FunMusic
//
//  Created by frankie on 16/1/7.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "MineTableViewController.h"
#import "UserHeaderView.h"
#import "MineOPCell.h"
#import "FunServer.h"
#import "UserInfo.h"
#import "LoginViewController.h"
#import "SideMenuViewController.h"
#import "TweetTableVIewController.h"
#import "SharedChannelTableController.h"
#import "UIColor+Util.h"
#import "Config.h"
#import "FunServer.h"
#import <RESideMenu.h>
#import <MBProgressHUD.h>

static const CGFloat kHeaderViewHeight            = 160;
static const CGFloat kCellHeight                  = 50;
static const CGFloat kSeperatorLineLeftDistance   = 80;
static const CGFloat kSeperatorLineRightDistance  = 10;
static const CGFloat kRefreshSleepTime            = 1;

static NSString *kOPCellID         = @"opCellID";
static NSString *kDawnAndNightMode = @"dawnAndNightMode";


typedef NS_ENUM(NSInteger, mineOPType)
{
    mineOPTypeChannel = 0,
    mineOPTypeTweeter,
    mineOPTypeClearCache,
    mineOPTypeNightMode
};

@interface MineTableViewController ()
{
    FunServer *_funServer;
    NSMutableArray *_mineOperationList;
}

@property (nonatomic, strong) UserHeaderView *mineHeaderView;

@end

@implementation MineTableViewController

- (void)dawnAndNightMode
{
    [self.mineHeaderView dawnAndNightMode];
    self.tableView.backgroundColor = [UIColor themeColor];
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.tableView reloadData];
    });
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _funServer = [[FunServer alloc] init];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUserHeaderView];
    [self setUpTableViewUI];
    [self fetchData];
}

- (void)setUpTableViewUI
{
    self.title = @"我";
    self.tableView.backgroundColor = [UIColor themeColor];
    //[self.tableView registerClass:[MineOPCell class] forCellReuseIdentifier:kOPCellID];
    //取消tableview留下的空余行白，记住！
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //解决分割线的距离问题
    self.tableView.separatorInset = UIEdgeInsetsMake(0, kSeperatorLineLeftDistance, 0, kSeperatorLineRightDistance);
}

- (void)fetchData
{
    if (!_mineOperationList)
    {
        _mineOperationList = [_funServer fmGetMineMenuInfo];
    }
}

- (void)setUpUserHeaderView
{
    _mineHeaderView = [[UserHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kHeaderViewHeight) isSideMenuHeader:NO];
    [self refreshUserView];
    __weak MineTableViewController *weakSelf = self;
    _mineHeaderView.pushLoginView = ^()
    {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf pushLoginView];
        }
    };
    self.tableView.tableHeaderView = _mineHeaderView;
}

- (void)refreshUserView
{
    BOOL isLogin = [_funServer fmIsLogin];
    UserInfo *currentUserInfo = [_funServer fmGetCurrentUserInfo];
    [_mineHeaderView refreshHeaderViewWithUserName:currentUserInfo.userName imageName:currentUserInfo.userImage Login:isLogin];
}


- (void) mineOpeationWithType:(mineOPType)type
{
    switch (type)
    {
        case mineOPTypeChannel:
            [self pushMyChannelView];
            break;
        case mineOPTypeTweeter:
            [self pushMyTweeterView];
            break;
        case mineOPTypeClearCache:
            [self clearAllUserDefaultData];
            break;
        case mineOPTypeNightMode:
            [self pushDawnAndNightMode];
            break;

    }
}


#pragma TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _mineOperationList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MineOPCell *opCell = [tableView dequeueReusableCellWithIdentifier:kOPCellID];
    if (!opCell)
    {
        opCell = [[MineOPCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOPCellID isSideOPCell:NO];
    }
    [opCell dawnAndNightMode];
    MenuInfo *opInfo = _mineOperationList[indexPath.row];
    [opCell setMineOPCellWithOPInfo:opInfo];
    if (indexPath.row == mineOPTypeNightMode && [_funServer fmGetNightMode])
    {
        [opCell changeDawnCell];
    }
    return opCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self mineOpeationWithType:indexPath.row];
}

#pragma common function


- (void)clearAllUserDefaultData
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    hud.labelText = @"清理缓存中";
    hud.mode = MBProgressHUDModeIndeterminate;
    //注意GCD的强大的嵌套能力，涉及UI的动作在主线程做，其余可以放在默认并发线程global_queue中做
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        [_funServer fmClearAllData];
        [NSThread sleepForTimeInterval:kRefreshSleepTime];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [hud hide:YES];
        });
    });
}



- (void)pushDawnAndNightMode
{
    [_funServer fmGetNightMode] ? ([_funServer fmSetNightMode:FALSE]) : ([_funServer fmSetNightMode:YES]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kDawnAndNightMode object:nil];
}

- (void)pushLoginView
{
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    __weak SideMenuViewController *weakSideMenuCtl = (SideMenuViewController *)self.sideMenuViewController.leftMenuViewController;
    __weak MineTableViewController *weakSelf = self;
    loginCtl.updateUserUI = ^()
    {
        __strong typeof(self) strongSelf = weakSelf;
        __strong SideMenuViewController *strongSideCtl = weakSideMenuCtl;
        if (strongSelf && strongSideCtl)
        {
            [strongSelf refreshUserView];
            [strongSideCtl refreshUserView];
        }
    };
    loginCtl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginCtl animated:YES];
}

- (void)pushMyTweeterView
{
    if ([_funServer fmIsLogin])
    {
        TweetTableVIewController *myTweetCtl = [[TweetTableVIewController alloc] initWithType:tweetViewTypeMine TweeterName:@"我的音乐圈"];
        myTweetCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:myTweetCtl animated:YES];
    }
    else
    {
        [self pushLoginAlertWithMessage:@"请登录后再进入我的音乐圈"];
    }
}

- (void)pushMyChannelView
{
    if ([_funServer fmIsLogin])
    {
        SharedChannelTableController *sharedChannelCtl = [[SharedChannelTableController alloc] init];
        __weak MineTableViewController *weakSelf = self;
        __weak SharedChannelTableController *weakSharedChannelCtl = sharedChannelCtl;
        sharedChannelCtl.presidentView = ^(NSInteger indexPath)
        {
            ((UITabBarController *)weakSelf.sideMenuViewController.contentViewController).selectedIndex = indexPath;
            __strong SharedChannelTableController *strongSharedCtl = weakSharedChannelCtl;
            if (strongSharedCtl)
            {
                [strongSharedCtl.navigationController popViewControllerAnimated:NO];
            }
        };
        sharedChannelCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:sharedChannelCtl animated:YES];
    }
    else
    {
        [self pushLoginAlertWithMessage:@"请登录后再进入我的频道"];
    }

}

- (void)pushLoginAlertWithMessage:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"您还未登录"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
