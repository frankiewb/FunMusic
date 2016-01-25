//
//  ChannelCell.m
//  FunMusic
//
//  Created by frankie on 15/12/27.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ChannelCell.h"
#import "ChannelInfo.h"
#import "UIColor+Util.h"
#import <MarqueeLabel.h>
#import <Masonry.h>


static const CGFloat kChannelLabelNameFontSize        = 18;
static const CGFloat kChannelDesLabelRate             = 10;
static const CGFloat kChannelDesLabelFadeLength       = 10;
static const CGFloat kChannelDesLabelFontSize         = 14;
static const CGFloat kChannelImageHeightWidthDistance = 60;
static const CGFloat kChannelImageCornerRadius        = 30;
static const CGFloat kChannelCellUIEdgeDistance       = 15;

@interface ChannelCell ()

@property (nonatomic, strong) UIImageView *channelImageView;
@property (nonatomic, strong) UILabel *channelNameLabel;
@property (nonatomic, strong) MarqueeLabel *channelDescriptionLabel;

@end


@implementation ChannelCell


- (void)dawnAndNightMode
{
    self.backgroundColor               = [UIColor themeColor];
    self.contentView.backgroundColor   = [UIColor themeColor];
    _channelNameLabel.textColor        = [UIColor standerTextColor];
    _channelDescriptionLabel.textColor = [UIColor standerGreyTextColor];

}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setUpUI];
        [self setUpChannelLayOut];
    }
    
    return self;
}

- (void)setUpUI
{
    //self
    self.backgroundColor = [UIColor themeColor];
    self.contentView.backgroundColor = [UIColor themeColor];
    //选中后不显示颜色
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //Image
    _channelImageView = [[UIImageView alloc] init];
    _channelImageView.layer.cornerRadius = kChannelImageCornerRadius;
    _channelImageView.layer.masksToBounds = YES;
    _channelImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_channelImageView];
    
    //NameLabel
    _channelNameLabel = [[UILabel alloc] init];
    _channelNameLabel.textColor = [UIColor standerTextColor];
    _channelNameLabel.font = [UIFont systemFontOfSize:kChannelLabelNameFontSize];
    [self.contentView addSubview:_channelNameLabel];
    
    //DesLabel
    _channelDescriptionLabel = [[MarqueeLabel alloc] init];
    _channelDescriptionLabel.textColor = [UIColor standerGreyTextColor];
    _channelDescriptionLabel.rate = kChannelDesLabelRate;
    _channelDescriptionLabel.fadeLength = kChannelDesLabelFadeLength;
    _channelDescriptionLabel.animationCurve = UIViewAnimationCurveEaseIn;
    _channelDescriptionLabel.marqueeType = MLContinuous;
    [_channelDescriptionLabel setFont:[UIFont systemFontOfSize:kChannelDesLabelFontSize]];
    [self.contentView addSubview:_channelDescriptionLabel];
   
}

- (void)setUpChannelLayOut
{
    [_channelImageView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.contentView.mas_left).offset(kChannelCellUIEdgeDistance);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.and.height.mas_equalTo(kChannelImageHeightWidthDistance);
    }];
    
    [_channelNameLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(_channelImageView.mas_right).offset(kChannelCellUIEdgeDistance);
        make.right.equalTo(self.contentView.mas_right).offset(-kChannelCellUIEdgeDistance);
        make.top.equalTo(self.contentView.mas_top).offset(kChannelCellUIEdgeDistance);
        make.bottom.equalTo(_channelDescriptionLabel.mas_top).offset(-kChannelCellUIEdgeDistance);
    }];
    
    [_channelDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(_channelImageView.mas_right).offset(kChannelCellUIEdgeDistance);
        make.right.equalTo(self.contentView.mas_right).offset(-kChannelCellUIEdgeDistance);
        make.top.equalTo(_channelNameLabel.mas_bottom).offset(kChannelCellUIEdgeDistance);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-kChannelCellUIEdgeDistance);
    }];
}

- (void)setUpChannelCellWithChannelInfo:(ChannelInfo *)channelInfo
{
    [_channelImageView setImage:[UIImage imageNamed:channelInfo.channelImage]];    
    _channelNameLabel.text = channelInfo.channelName;
    _channelDescriptionLabel.text = channelInfo.channelIntro;
}


@end
