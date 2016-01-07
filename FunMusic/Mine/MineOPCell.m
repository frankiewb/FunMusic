//
//  MineOPCell.m
//  FunMusic
//
//  Created by frankie on 16/1/7.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "MineOPCell.h"
#import "MineOperationInfo.h"
#import <Masonry.h>

static const CGFloat kOPImageSide = 40;
static const CGFloat kNameLabeHeight = 40;
static const CGFloat KNameLabelWidth = 100;
static const CGFloat kLabelWidthDistance = 10;
static const CGFloat kEdgeDistance = 5;



@interface MineOPCell ()

@property (nonatomic, strong) UIImageView *opImageView;
@property (nonatomic, strong) UILabel *opNameLabel;

@end


@implementation MineOPCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setUpUI];
        [self setOPCellLayOut];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)setUpUI
{
    //opImageView
    _opImageView = [[UIImageView alloc] init];
    _opImageView.layer.cornerRadius = kOPImageSide / 2;
    [self.contentView addSubview:_opImageView];
    
    //opNameLabel
    _opNameLabel = [[UILabel alloc] init];
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

- (void)setMineOPCellWithOPInfo:(MineOperationInfo *)opInfo
{
    //为写login模块，暂时用本地图片
    [_opImageView setImage:[UIImage imageNamed:opInfo.operationImageName]];
    _opNameLabel.text = opInfo.operationName;
}

@end
