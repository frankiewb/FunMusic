//
//  MineOPCell.m
//  FunMusic
//
//  Created by frankie on 16/1/7.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "MineOPCell.h"
#import "MenuInfo.h"
#import "UIColor+Util.h"
#import <Masonry.h>

static const CGFloat kOPImageSide        = 25;
static const CGFloat kNameLabeHeight     = 40;
static const CGFloat KNameLabelWidth     = 100;
static const CGFloat kLabelWidthDistance = 10;
static const CGFloat kEdgeDistance       = 10;

@interface MineOPCell ()

@property (nonatomic, strong) UIImageView *opImageView;
@property (nonatomic, strong) UILabel *opNameLabel;

@end

@implementation MineOPCell

- (void)dawnAndNightMode
{
    self.backgroundColor             = [UIColor themeColor];
    self.contentView.backgroundColor = [UIColor themeColor];
    _opNameLabel.textColor           = [UIColor standerTextColor];
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isSideOPCell:(BOOL)isSideOPCell
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setUpUI];
        [self setOPCellLayOut];
        (isSideOPCell) ? (self.accessoryType = UITableViewCellAccessoryNone):(self.accessoryType = UITableViewCellAccessoryDisclosureIndicator);
    }
    
    return self;
}

- (void)setUpUI
{
    //self
    self.backgroundColor = [UIColor themeColor];
    self.contentView.backgroundColor = [UIColor themeColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //opImageView
    _opImageView = [[UIImageView alloc] init];
    _opImageView.contentMode = UIViewContentModeScaleAspectFit;
    _opImageView.layer.cornerRadius = kOPImageSide / 2;
    [self.contentView addSubview:_opImageView];
    
    //opNameLabel
    _opNameLabel = [[UILabel alloc] init];
    _opNameLabel.textColor = [UIColor standerTextColor];
    [self.contentView addSubview:_opNameLabel];
}

- (void)setOPCellLayOut
{
    [_opImageView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(kEdgeDistance);
        make.right.equalTo(_opNameLabel.mas_left).offset(-kLabelWidthDistance);
        make.height.mas_equalTo(kOPImageSide);
    }];
    
    [_opNameLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(_opImageView.mas_right).offset(kLabelWidthDistance);
        make.height.mas_equalTo(kNameLabeHeight);
        make.width.mas_equalTo(KNameLabelWidth);
    }];
}

- (void)setMineOPCellWithOPInfo:(MenuInfo *)menuInfo
{
    [_opImageView setImage:[UIImage imageNamed:menuInfo.menuImageName]];
    _opNameLabel.text = menuInfo.menuName;
}

- (void)changeDawnCell
{
    [_opImageView setImage:[UIImage imageNamed:@"日间模式"]];
    _opNameLabel.text = @"日间模式";
}

@end
