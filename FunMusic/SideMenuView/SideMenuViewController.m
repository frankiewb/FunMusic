//
//  SideBarViewController.m
//  FunMusic
//
//  Created by frankie on 16/1/11.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "SideMenuViewController.h"
#import "UserInfo.h"
#import "SideUserHeaderView.h"
#import "SideMenuCell.h"
#import "LoginViewController.h"
#import "MineTableViewController.h"
#import "ContentTabBarController.h"
#import "FunServer.h"
#import "UIColor+Util.h"
#import "Config.h"
#import <RESideMenu.h>
#import <Masonry.h>
#import <MBProgressHUD.h>

static const CGFloat kHeaderViewHeight            = 200;
static const CGFloat kCellHeight                  = 50;
static const CGFloat kSeperatorLineLeftDistance   = 80;
static const CGFloat kSeperatorLineRightDistance  = 160;
static const CGFloat kRefreshSleepTime            = 1;

static NSString *kOPCellID         = @"opCellID";
static NSString *kDawnAndNightMode = @"dawnAndNightMode";

typedef NS_ENUM(NSInteger, sideMenuOPType)
{
    sideMenuOPTypeChannel = 0,
    sideMenuOPTypeTweeter,
    sideMenuOPTypeClearCache,
    sideMenuOPTypeNightMode,
    sideMenuOPTypeLogOut,
};

@interface SideMenuViewController ()
{
    FunServer *funServer;
    NSMutableArray *sideMenuOperationLists;
}

@property (nonatomic, strong) SideUserHeaderView *sideHeaderView;

@end

@implementation SideMenuViewController

- (void)dawnAndNightMode:(NSNotification *)center
{
    [_sideHeaderView dawnAndNightMode];
    self.tableView.backgroundColor = [UIColor themeColor];
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.tableView reloadData];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDawnAndNightMode object:nil];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dawnAndNightMode:) name:kDawnAndNightMode object:nil];
    if (!sideMenuOperationLists)
    {
        sideMenuOperationLists = [funServer fmGetSideMenuInfo];
    }    
    [self setUpUserHeaderView];
    self.tableView.tableHeaderView = _sideHeaderView;
    [self.tableView registerClass:[SideMenuCell class] forCellReuseIdentifier:kOPCellID];
    //取消tableview留下的空余行白
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView.backgroundColor = [UIColor themeColor];
    //解决分割线的距离问题
    self.tableView.separatorInset = UIEdgeInsetsMake(0, kSeperatorLineLeftDistance, 0, kSeperatorLineRightDistance);
}


- (void)setUpUserHeaderView
{
    _sideHeaderView = [[SideUserHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kHeaderViewHeight)];
    [self refreshUserView];
    __weak SideMenuViewController *weakSelf = self;
    _sideHeaderView.pushLoginView = ^()
    {
        [weakSelf pushLoginView];
    };

}


- (void)refreshUserView
{
    BOOL isLogin = [funServer fmIsLogin];
    UserInfo *currentUserInfo = [funServer fmGetCurrentUserInfo];
    [_sideHeaderView refreshHeaderViewWithUserName:currentUserInfo.userName imageName:currentUserInfo.userImage Login:isLogin];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void) sideMenuOperationWithType:(sideMenuOPType)type
{

    switch (type)
    {
        case sideMenuOPTypeChannel:
            [self presentViewWithIndex:funViewTypeChannel];
            break;
        case sideMenuOPTypeTweeter:
            [self presentViewWithIndex:funViewTypeTweeter];
            break;
        case sideMenuOPTypeClearCache:
            [self clearAllUserDefaultData];
            break;
        case sideMenuOPTypeNightMode:
            [self presentDawnAndNightMode];
            break;
        case sideMenuOPTypeLogOut:
            [self logOut];
            break;
        
    }
}


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




- (void)presentDawnAndNightMode
{
    [funServer fmGetNightMode] ? ([funServer fmSetNightMode:FALSE]) : ([funServer fmSetNightMode:YES]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kDawnAndNightMode object:nil];
}


- (void)presentViewWithIndex:(NSInteger)index
{
    ((UITabBarController *)self.sideMenuViewController.contentViewController).selectedIndex = index;
    [self.sideMenuViewController hideMenuViewController];
}


- (void)pushViewController:(UIViewController *)viewController
{
    viewController.hidesBottomBarWhenPushed = YES;
    UINavigationController *nav = (UINavigationController *)((UITabBarController *)self.sideMenuViewController.contentViewController).selectedViewController;
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:nil
                                                                                      action:nil];
    [nav pushViewController:viewController animated:NO];
    [self.sideMenuViewController hideMenuViewController];
}


- (void)pushLoginView
{
    __weak MineTableViewController *weakMineCtl = ((ContentTabBarController *)self.sideMenuViewController.contentViewController).weakMineCtl;
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    __weak SideMenuViewController *weakSelf = self;
    loginCtl.updateUserUI = ^()
    {
        [weakSelf refreshUserView];
        [weakMineCtl refreshUserView];
    };
    [self pushViewController:loginCtl];
}

- (void)logOut
{
    if ([funServer fmIsLogin])
    {
        [funServer fmLogOut];
        __weak MineTableViewController *weakMineCtl = ((ContentTabBarController *)self.sideMenuViewController.contentViewController).weakMineCtl;
        [self refreshUserView];
        [weakMineCtl refreshUserView];
        [self.sideMenuViewController hideMenuViewController];

    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"您还未登录"
                                                                                 message:@"请登录后再注销"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


#pragma TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sideMenuOperationLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SideMenuCell *opCell = [tableView dequeueReusableCellWithIdentifier:kOPCellID forIndexPath:indexPath];
    [opCell dawnAndNightMode];
    SideMenuInfo *opInfo = sideMenuOperationLists[indexPath.row];
    [opCell setSideMenuCellWithOPInfo:opInfo];
    if (indexPath.row == sideMenuOPTypeNightMode && [funServer fmGetNightMode])
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
    [self sideMenuOperationWithType:indexPath.row];
}


@end
