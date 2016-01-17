//
//  SideBarViewController.m
//  FunMusic
//
//  Created by frankie on 16/1/11.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "SideMenuViewController.h"
#import "SideMenuInfo.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "SideMenuCell.h"
#import "LoginViewController.h"
#import "MineTableViewController.h"
#import "ContentTabBarController.h"
#import "UIColor+Util.h"
#import "Config.h"
#import <RESideMenu.h>
#import <Masonry.h>
#import <MBProgressHUD.h>

static const CGFloat kHeaderViewHeight            = 200;
static const CGFloat kUserImageViewSide           = 80;
static const CGFloat kUserImageViewHeightDistance = 50;
static const CGFloat kLabelHeightDistance         = 10;
static const CGFloat kLabelHeight                 = 40;
static const CGFloat kEdgeDistance                = 10;
static const CGFloat kCellHeight                  = 50;
static const CGFloat kNameFont                    = 20;
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
    AppDelegate *appDelegate;
    NSMutableArray *sideMenuOperationLists;
}

@property (nonatomic, strong) UIView *sideHeaderView;
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel*userNameLabel;



@end

@implementation SideMenuViewController

- (void)dawnAndNightMode:(NSNotification *)center
{
    self.sideHeaderView.backgroundColor = [UIColor themeColor];
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
        appDelegate = [[UIApplication sharedApplication] delegate];
    }
    
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor themeColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dawnAndNightMode:) name:kDawnAndNightMode object:nil];
    [self setUpOperationInfo];
    [self setUpHeaderView];
    self.tableView.tableHeaderView = _sideHeaderView;
    [self.tableView registerClass:[SideMenuCell class] forCellReuseIdentifier:kOPCellID];
    //取消tableview留下的空余行白
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView.backgroundColor = [UIColor themeColor];
    //解决分割线的距离问题
    self.tableView.separatorInset = UIEdgeInsetsMake(0, kSeperatorLineLeftDistance, 0, kSeperatorLineRightDistance);
}



- (void)setUpOperationInfo
{
    NSArray *operationNameLists = @[@"频道",@"音乐圈",@"清除缓存",@"夜间模式",@"注销登录"];
    NSArray *operationImageNameLists = @[@"频道",@"音乐圈",@"缓存",@"夜间模式",@"注销"];
    if (!sideMenuOperationLists)
    {
        sideMenuOperationLists = [[NSMutableArray alloc] init];
    }
    
    __weak NSMutableArray *weakSideMenuOpLists = sideMenuOperationLists;
    
    [operationNameLists enumerateObjectsUsingBlock:^(NSString *opName, NSUInteger idx, BOOL *stop)
     {
         SideMenuInfo *opInfo = [[SideMenuInfo alloc] init];
         opInfo.operationName = opName;
         opInfo.operationImageName = operationImageNameLists[idx];
         [weakSideMenuOpLists addObject:opInfo];
     }];
}

- (void)setUpHeaderView
{
    _sideHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kHeaderViewHeight)];
    _sideHeaderView.userInteractionEnabled = YES;
    [self setUpHeaderUI];
    [self setUpHeaderLayOut];
}


- (void)setUpHeaderUI
{
    //self
    self.sideHeaderView.backgroundColor = [UIColor themeColor];
    //userImageView
    _userImageView = [[UIImageView alloc] init];
    _userImageView.layer.cornerRadius = kUserImageViewSide / 2;
    _userImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushLoginView)];
    [_userImageView addGestureRecognizer:singleTap];
    
    //userNameLabel
    _userNameLabel = [[UILabel alloc] init];
    _userNameLabel.textColor = [UIColor orangeColor];
    _userNameLabel.textAlignment = NSTextAlignmentCenter;
    _userNameLabel.font = [UIFont systemFontOfSize:kNameFont];
    
    [self refreshUserView];
    [_sideHeaderView addSubview:_userNameLabel];
    [_sideHeaderView addSubview:_userImageView];
}

- (void)setUpHeaderLayOut
{
    [_userImageView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(_sideHeaderView.mas_top).offset(kUserImageViewHeightDistance);
         make.height.and.width.mas_equalTo(kUserImageViewSide);
         make.centerX.equalTo(_sideHeaderView.mas_centerX).multipliedBy(0.6);
     }];
    
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(_userImageView.mas_bottom).offset(kLabelHeightDistance);
         make.centerX.equalTo(_sideHeaderView.mas_centerX).multipliedBy(0.6);
         make.height.mas_equalTo(kLabelHeight);
         make.left.equalTo(_sideHeaderView.mas_left).offset(kEdgeDistance);
     }];

}

- (void)refreshUserView
{
    if ([appDelegate isLogin])
    {
        _userImageView.userInteractionEnabled = NO;
        [_userImageView setImage:[UIImage imageNamed:appDelegate.currentUserInfo.userImage]];
        _userNameLabel.text = appDelegate.currentUserInfo.userName;
    }
    else
    {
        _userImageView.userInteractionEnabled = YES;
        [_userImageView setImage:[UIImage imageNamed:@"userDefaultImage"]];
        _userNameLabel.text = @"未登录";
         
    }
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
        [Config clearAllDataInUserDefaults];
        [NSThread sleepForTimeInterval:kRefreshSleepTime];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [hud hide:YES];
        });
    });
}




- (void)presentDawnAndNightMode
{
    if (appDelegate.isNightMode)
    {
        appDelegate.isNightMode = FALSE;
    }
    else
    {
        appDelegate.isNightMode = YES;
    }
    //************调试模式下还需要用，暂且不删********************
    [Config saveDawnAndNightMode:appDelegate.isNightMode];
    //*******************************************************
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
    if ([appDelegate isLogin])
    {
        [appDelegate logOut];
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
    if (indexPath.row == sideMenuOPTypeNightMode && appDelegate.isNightMode)
    {
        [opCell.sideMenuImageView setImage:[UIImage imageNamed:@"日间模式"]];
        opCell.sideMenuNameLabel.text = @"日间模式";
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
