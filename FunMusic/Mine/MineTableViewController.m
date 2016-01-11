//
//  MineTableViewController.m
//  FunMusic
//
//  Created by frankie on 16/1/7.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "MineTableViewController.h"
#import "AppDelegate.h"
#import "MineOperationInfo.h"
#import "MineOPCell.h"
#import "FunServer.h"
#import "UserInfo.h"
#import "LoginViewController.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>

static const CGFloat kHeaderViewHeight = 160;
static const CGFloat kUserImageViewSide = 80;
static const CGFloat kUserImageViewHeightDistance = 10;
static const CGFloat kLabelHeightDistance = 10;
static const CGFloat kLabelHeight = 40;
static const CGFloat kEdgeDistance = 5;
static const CGFloat kCellHeight = 50;
static const CGFloat kNameFont = 20;

#define USERIMAGEURL @"http://img3.douban.com/icon/ul%@-1.jpg"
static NSString *kOPCellID = @"opCellID";


typedef NS_ENUM(NSInteger, mineOPType)
{
    mineOPTypeChannel = 0,
    mineOPTypeTweeter,
    mineOPTypeClearCache,
    mineOPTypeNightMode
};

@interface MineTableViewController ()

{
    AppDelegate *appDelegate;
    FunServer *funServer;
    NSMutableArray *mineOperationLists;
}

@property (nonatomic, strong) UIView *mineHeaderView;
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel *userNameLabel;



@end

@implementation MineTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我";
    appDelegate = [[UIApplication sharedApplication] delegate];
    [self setUpOperationInfo];
    [self setUpHeaderView];
    self.tableView.tableHeaderView = _mineHeaderView;
    [self.tableView registerClass:[MineOPCell class] forCellReuseIdentifier:kOPCellID];
    //取消tableview留下的空余行白，记住！
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)setUpOperationInfo
{
    NSArray *operationNameLists = @[@"我的频道",@"我的音乐圈",@"清除缓存",@"夜间模式"];
    //NSArray *operationImageNameLists = @[@"频道",@"音乐圈",@"缓存",@"夜间模式"];
    if (!mineOperationLists)
    {
        mineOperationLists = [[NSMutableArray alloc] init];
    }
    __weak NSMutableArray *weakMineOpLists = mineOperationLists;
    
    [operationNameLists enumerateObjectsUsingBlock:^(NSString *opName, NSUInteger idx, BOOL *stop)
    {
        MineOperationInfo *opInfo = [[MineOperationInfo alloc] init];
        opInfo.operationName = opName;
        //opInfo.operationImageName = operationImageNameLists[idx];
        opInfo.operationImageName = @"小白虾";
        [weakMineOpLists addObject:opInfo];
    }];
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
    //userImageView
    _userImageView = [[UIImageView alloc] init];
    _userImageView.layer.cornerRadius = kUserImageViewSide / 2;
    _userImageView.userInteractionEnabled = YES;
    [_userImageView setImage:[UIImage imageNamed:@"userDefaultImage"]];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushLoginView)];
    [_userImageView addGestureRecognizer:singleTap];
    [_mineHeaderView addSubview:_userImageView];
    
    //userNameLabel
    _userNameLabel = [[UILabel alloc] init];
    _userNameLabel.textAlignment = NSTextAlignmentCenter;
    _userNameLabel.font = [UIFont systemFontOfSize:kNameFont];
    _userNameLabel.text = @"未登录";
    [_mineHeaderView addSubview:_userNameLabel];
    
}

- (void)refreshUserView
{
    [_userImageView setImage:[UIImage imageNamed:appDelegate.currentUserInfo.userImage]];
    _userImageView.userInteractionEnabled = NO;
    _userNameLabel.text = appDelegate.currentUserInfo.userName;
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
    if (_presentView)
    {
        switch (type)
        {
            case mineOPTypeChannel:
                _presentView(1);
                break;
            case mineOPTypeTweeter:
                _presentView(2);
                break;
            case mineOPTypeClearCache:
                break;
            case mineOPTypeNightMode:
                break;
        }

    }
}


#pragma TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mineOperationLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MineOPCell *opCell = [tableView dequeueReusableCellWithIdentifier:kOPCellID forIndexPath:indexPath];
    MineOperationInfo *opInfo = mineOperationLists[indexPath.row];
    [opCell setMineOPCellWithOPInfo:opInfo];
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

- (void)pushLoginView
{
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    loginCtl.hidesBottomBarWhenPushed = YES;
    __weak MineTableViewController *weakSelf = self;
    loginCtl.refreshUserView = ^()
    {
        [weakSelf refreshUserView];
    };

    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    [self.navigationController pushViewController:loginCtl animated:YES];
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
