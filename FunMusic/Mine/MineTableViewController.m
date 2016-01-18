//
//  MineTableViewController.m
//  FunMusic
//
//  Created by frankie on 16/1/7.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "MineTableViewController.h"
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
#import <Masonry.h>
#import <MBProgressHUD.h>

static const CGFloat kHeaderViewHeight            = 160;
static const CGFloat kUserImageViewSide           = 80;
static const CGFloat kUserImageViewHeightDistance = 10;
static const CGFloat kLabelHeightDistance         = 10;
static const CGFloat kLabelHeight                 = 40;
static const CGFloat kEdgeDistance                = 5;
static const CGFloat kCellHeight                  = 50;
static const CGFloat kNameFont                    = 20;
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
    FunServer *funServer;
    NSMutableArray *mineOperationList;
}

@property (nonatomic, strong) UIView *mineHeaderView;
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel *userNameLabel;



@end

@implementation MineTableViewController

- (void)dawnAndNightMode
{
    self.tableView.backgroundColor = [UIColor themeColor];
    self.mineHeaderView.backgroundColor = [UIColor themeColor];
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
        funServer = [[FunServer alloc] init];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor themeColor];
    self.title = @"我";
    if (!mineOperationList)
    {
        mineOperationList = [funServer fmGetMineMenuInfo];
    }

    [self setUpHeaderView];
    self.tableView.tableHeaderView = _mineHeaderView;
    [self.tableView registerClass:[MineOPCell class] forCellReuseIdentifier:kOPCellID];
    //取消tableview留下的空余行白，记住！
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //解决分割线的距离问题
    self.tableView.separatorInset = UIEdgeInsetsMake(0, kSeperatorLineLeftDistance, 0, kSeperatorLineRightDistance);
}



- (void)setUpHeaderView
{
    _mineHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kHeaderViewHeight)];
    _mineHeaderView.userInteractionEnabled = YES;
    [self setUpHeaderUI];
    [self setUpHeaderLayOut];
}

- (void)setUpHeaderUI
{
    //self
    self.mineHeaderView.backgroundColor = [UIColor themeColor];
    //userImageView
    _userImageView = [[UIImageView alloc] init];
    _userImageView.layer.cornerRadius = kUserImageViewSide / 2;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushLoginView)];
    [_userImageView addGestureRecognizer:singleTap];
    
    //userNameLabel
    _userNameLabel = [[UILabel alloc] init];
    _userNameLabel.textAlignment = NSTextAlignmentCenter;
    _userNameLabel.textColor = [UIColor orangeColor];
    _userNameLabel.font = [UIFont systemFontOfSize:kNameFont];
    
    [self refreshUserView];
    [_mineHeaderView addSubview:_userNameLabel];
    [_mineHeaderView addSubview:_userImageView];
    
}

- (void)refreshUserView
{
    if ([funServer fmIsLogin])
    {
        _userImageView.userInteractionEnabled = NO;
        UserInfo *currentUserInfo = [funServer fmGetCurrentUserInfo];
        [_userImageView setImage:[UIImage imageNamed:currentUserInfo.userImage]];
        _userNameLabel.text = currentUserInfo.userName;
    }
    else
    {
        _userImageView.userInteractionEnabled = YES;
        [_userImageView setImage:[UIImage imageNamed:@"userDefaultImage"]];
        _userNameLabel.text = @"未登录";        
    }
}


- (void)setUpHeaderLayOut
{
   [_userImageView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(_mineHeaderView.mas_top).offset(kUserImageViewHeightDistance);
        make.height.and.width.mas_equalTo(kUserImageViewSide);
        make.centerX.equalTo(_mineHeaderView.mas_centerX);
    }];
    
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(_userImageView.mas_bottom).offset(kLabelHeightDistance);
        make.centerX.equalTo(_mineHeaderView.mas_centerX);
        make.height.mas_equalTo(kLabelHeight);
        make.right.equalTo(_mineHeaderView.mas_right).offset(-kEdgeDistance);
        make.left.equalTo(_mineHeaderView.mas_left).offset(kEdgeDistance);
    }];
    
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
    return mineOperationList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MineOPCell *opCell = [tableView dequeueReusableCellWithIdentifier:kOPCellID forIndexPath:indexPath];
    [opCell dawnAndNightMode];
    MineOperationInfo *opInfo = mineOperationList[indexPath.row];
    [opCell setMineOPCellWithOPInfo:opInfo];
    if (indexPath.row == mineOPTypeNightMode && [funServer fmGetNightMode])
    {
        [opCell.opImageView setImage:[UIImage imageNamed:@"日间模式"]];
        opCell.opNameLabel.text = @"日间模式";
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
        [funServer fmClearAllData];
        [NSThread sleepForTimeInterval:kRefreshSleepTime];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [hud hide:YES];
        });
    });
}



- (void)pushDawnAndNightMode
{
    [funServer fmGetNightMode] ? ([funServer fmSetNightMode:FALSE]) : ([funServer fmSetNightMode:YES]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kDawnAndNightMode object:nil];
}

- (void)pushLoginView
{
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    __weak SideMenuViewController *weakSideMenuCtl = (SideMenuViewController *)self.sideMenuViewController.leftMenuViewController;
    __weak MineTableViewController *weakSelf = self;
    loginCtl.updateUserUI = ^()
    {
        [weakSelf refreshUserView];
        [weakSideMenuCtl refreshUserView];
    };
    loginCtl.hidesBottomBarWhenPushed = YES;    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    [self.navigationController pushViewController:loginCtl animated:YES];
}

- (void)pushMyTweeterView
{
    if ([funServer fmIsLogin])
    {
        TweetTableVIewController *myTweetCtl = [[TweetTableVIewController alloc] initWithType:tweetViewTypeMine TweeterName:@"我的音乐圈"];
        myTweetCtl.hidesBottomBarWhenPushed = YES;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:nil
                                                                                action:nil];
        [self.navigationController pushViewController:myTweetCtl animated:YES];

        
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"您还未登录"
                                                                                 message:@"请登录后再进入我的朋友圈"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)pushMyChannelView
{
    if ([funServer fmIsLogin])
    {
        SharedChannelTableController *sharedChannelCtl = [[SharedChannelTableController alloc] init];
        __weak MineTableViewController *weakSelf = self;
        __weak SharedChannelTableController *weakSharedChannelCtl = sharedChannelCtl;
        sharedChannelCtl.presidentView = ^(NSInteger indexPath)
        {
            ((UITabBarController *)weakSelf.sideMenuViewController.contentViewController).selectedIndex = indexPath;
            [weakSharedChannelCtl.navigationController popViewControllerAnimated:NO];
        };
        sharedChannelCtl.hidesBottomBarWhenPushed = YES;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:nil
                                                                                action:nil];
        [self.navigationController pushViewController:sharedChannelCtl animated:YES];
        
        
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"您还未登录"
                                                                                 message:@"请登录后再进入我的频道"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
