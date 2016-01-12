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
#import <RESideMenu.h>
#import <Masonry.h>

static const CGFloat kHeaderViewHeight = 200;
static const CGFloat kUserImageViewSide = 80;
static const CGFloat kUserImageViewHeightDistance = 50;
static const CGFloat kLabelHeightDistance = 10;
static const CGFloat kLabelHeight = 40;
static const CGFloat kEdgeDistance = 10;
static const CGFloat kCellHeight = 50;
static const CGFloat kNameFont = 20;

static NSString *kOPCellID = @"opCellID";

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = [[UIApplication sharedApplication] delegate];
    [self setUpOperationInfo];
    [self setUpHeaderView];
    self.tableView.tableHeaderView = _sideHeaderView;
    [self.tableView registerClass:[SideMenuCell class] forCellReuseIdentifier:kOPCellID];
    //取消tableview留下的空余行白
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}



- (void)setUpOperationInfo
{
    NSArray *operationNameLists = @[@"频道",@"音乐圈",@"清除缓存",@"夜间模式",@"注销登录"];
    //NSArray *operationImageNameLists = @[@"频道",@"音乐圈",@"缓存",@"夜间模式",@"注销登录"];
    if (!sideMenuOperationLists)
    {
        sideMenuOperationLists = [[NSMutableArray alloc] init];
    }
    
    __weak NSMutableArray *weakSideMenuOpLists = sideMenuOperationLists;
    
    [operationNameLists enumerateObjectsUsingBlock:^(NSString *opName, NSUInteger idx, BOOL *stop)
     {
         SideMenuInfo *opInfo = [[SideMenuInfo alloc] init];
         opInfo.operationName = opName;
         //opInfo.operationImageName = operationNameLists[idx];
         opInfo.operationImageName = @"辰溪";
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
    //userImageView
    _userImageView = [[UIImageView alloc] init];
    _userImageView.layer.cornerRadius = kUserImageViewSide / 2;
    _userImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushLoginView)];
    [_userImageView addGestureRecognizer:singleTap];
    
    //userNameLabel
    _userNameLabel = [[UILabel alloc] init];
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
    ([appDelegate isLogin]) ? (_userImageView.userInteractionEnabled = NO) : (_userImageView.userInteractionEnabled = YES);
    [_userImageView setImage:[UIImage imageNamed:appDelegate.currentUserInfo.userImage]];
    _userNameLabel.text = appDelegate.currentUserInfo.userName;
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
            [self presentViewWithIndex:1];
            break;
        case sideMenuOPTypeTweeter:
            [self presentViewWithIndex:2];
            break;
        case sideMenuOPTypeClearCache:
            break;
        case sideMenuOPTypeNightMode:
            break;
        case sideMenuOPTypeLogOut:
            [self logOut];
            break;
        
    }
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
    SideMenuInfo *opInfo = sideMenuOperationLists[indexPath.row];
    [opCell setSideMenuCellWithOPInfo:opInfo];
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
