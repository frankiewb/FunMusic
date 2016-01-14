//
//  SideBarCell.m
//  FunMusic
//
//  Created by frankie on 16/1/11.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "SideMenuCell.h"
#import "SideMenuInfo.h"
#import "UIColor+Util.h"
#import <Masonry.h>

static const CGFloat kOPImageSide        = 25;
static const CGFloat kNameLabeHeight     = 40;
static const CGFloat KNameLabelWidth     = 100;
static const CGFloat kLabelWidthDistance = 10;
static const CGFloat kEdgeDistance       = 10;


@interface SideMenuCell ()

@property (nonatomic, strong) UIImageView *sideMenuImageView;
@property (nonatomic, strong) UILabel *sideMenuNameLabel;

@end


@implementation SideMenuCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setUpUI];
        [self setSideMenuCellLayOut];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)setUpUI
{
    self.backgroundColor=[UIColor themeColor];    
    //opImageView
    _sideMenuImageView = [[UIImageView alloc] init];
    _sideMenuImageView.contentMode = UIViewContentModeScaleAspectFit;
    _sideMenuImageView.layer.cornerRadius = kOPImageSide / 2;
    [self.contentView addSubview:_sideMenuImageView];
    
    //opNameLabel
    _sideMenuNameLabel = [[UILabel alloc] init];
    _sideMenuNameLabel.textColor = [UIColor standerTextColor];
    [self.contentView addSubview:_sideMenuNameLabel];
}

- (void)setSideMenuCellLayOut
{
    [_sideMenuImageView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerY.equalTo(self.contentView.mas_centerY);
         make.left.equalTo(self.contentView.mas_left).offset(kEdgeDistance);
         make.right.equalTo(_sideMenuNameLabel.mas_left).offset(-kLabelWidthDistance);
         make.height.mas_equalTo(kOPImageSide);
     }];
    
    [_sideMenuNameLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerY.equalTo(self.contentView.mas_centerY);
         make.left.equalTo(_sideMenuImageView.mas_right).offset(kLabelWidthDistance);
         make.height.mas_equalTo(kNameLabeHeight);
         make.width.mas_equalTo(KNameLabelWidth);
     }];
}

- (void)setSideMenuCellWithOPInfo:(SideMenuInfo *)sideMenuInfo
{
    [_sideMenuImageView setImage:[UIImage imageNamed:sideMenuInfo.operationImageName]];
    _sideMenuNameLabel.text = sideMenuInfo.operationName;
}




@end
