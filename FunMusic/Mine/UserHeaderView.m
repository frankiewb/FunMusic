//
//  UserHeaderView.m
//  FunMusic
//
//  Created by frankie on 16/1/19.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "UserHeaderView.h"
#import "UIColor+Util.h"
#import <Masonry.h>


static const CGFloat kUserImageViewSide           = 80;
static const CGFloat kUserImageViewHeightDistance = 10;
static const CGFloat kLabelHeightDistance         = 10;
static const CGFloat kUserNameLabelHeight         = 40;
static const CGFloat kEdgeDistance                = 5;
static const CGFloat kNameFont                    = 20;

@interface UserHeaderView ()

@property (nonatomic, strong)UILabel *userNameLabel;
@property (nonatomic, strong)UIImageView *userImageView;

@end




@implementation UserHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setUpUI];
        [self setAutoLayout];
    }
    
    return self;
}

- (void)setUpUI
{
    //self
    self.backgroundColor = [UIColor themeColor];
    
    //userImageView
    _userImageView = [[UIImageView alloc] init];
    _userImageView.layer.cornerRadius = kUserImageViewSide / 2;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushView)];
    [_userImageView addGestureRecognizer:singleTap];
    
    //userNameLabel
    _userNameLabel = [[UILabel alloc] init];
    _userNameLabel.textAlignment = NSTextAlignmentCenter;
    _userNameLabel.textColor = [UIColor orangeColor];
    _userNameLabel.font = [UIFont systemFontOfSize:kNameFont];
    
    [self addSubview:_userNameLabel];
    [self addSubview:_userImageView];

}

- (void)setAutoLayout
{
    [_userImageView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.mas_top).offset(kUserImageViewHeightDistance);
         make.height.and.width.mas_equalTo(kUserImageViewSide);
         make.centerX.equalTo(self.mas_centerX);
     }];
    
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(_userImageView.mas_bottom).offset(kLabelHeightDistance);
         make.centerX.equalTo(self.mas_centerX);
         make.height.mas_equalTo(kUserNameLabelHeight);
         make.right.equalTo(self.mas_right).offset(-kEdgeDistance);
         make.left.equalTo(self.mas_left).offset(kEdgeDistance);
     }];

}

- (void)refreshHeaderViewWithUserName:(NSString *)userName imageName:(NSString *)imageName Login:(BOOL)isLogin
{
    if (isLogin)
    {
        _userImageView.userInteractionEnabled = NO;
        [_userImageView setImage:[UIImage imageNamed:imageName]];
        _userNameLabel.text = userName;
    }
    else
    {
        _userImageView.userInteractionEnabled = YES;
        [_userImageView setImage:[UIImage imageNamed:@"userDefaultImage"]];
        _userNameLabel.text = @"未登录";
    }
}

- (void)dawnAndNightMode
{
    self.backgroundColor = [UIColor themeColor];
}

- (void)pushView
{
    if (_pushLoginView)
    {
        _pushLoginView();
    }
}


@end
