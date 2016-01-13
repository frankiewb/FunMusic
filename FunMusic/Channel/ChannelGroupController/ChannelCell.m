//
//  ChannelCell.m
//  FunMusic
//
//  Created by frankie on 15/12/27.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ChannelCell.h"
#import "ChannelInfo.h"
#import "Common.h"
#import <MarqueeLabel.h>
#import <Masonry.h>


static const CGFloat kChannelLabelNameFontSize = 18;
static const CGFloat kChannelDesLabelRate = 10;
static const CGFloat kChannelDesLabelFadeLength = 10;
static const CGFloat kChannelDesLabelFontSize = 14;

static const CGFloat kChannelImageHeightWidthDistance = 60;
static const CGFloat kChannelImageCornerRadius = 30;
static const CGFloat kChannelCellUIEdgeDistance = 10;

@interface ChannelCell ()

@property (nonatomic, strong) UIImageView *channelImageView;
@property (nonatomic, strong) UILabel *channelNameLabel;
@property (nonatomic, strong) MarqueeLabel *channelDescriptionLabel;

@end





@implementation ChannelCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.backgroundColor = HORIZONALBACKGROUNDCOLOR;
        [self setUpUI];
        [self setUpChannelLayOut];
        //选中后不显示颜色
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)setUpUI
{
    //Image
    _channelImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_channelImageView];
    
    //NameLabel
    _channelNameLabel = [[UILabel alloc] init];
    _channelNameLabel.font = [UIFont systemFontOfSize:kChannelLabelNameFontSize];
    [self.contentView addSubview:_channelNameLabel];
    
    //DesLabel
    _channelDescriptionLabel = [[MarqueeLabel alloc] init];
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
        
    //调研下，在复用的时候为什么取不到imageview的bound的size的width，结果居然是0
    _channelImageView.layer.cornerRadius = kChannelImageCornerRadius;
    _channelImageView.layer.masksToBounds = YES;
    _channelImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _channelNameLabel.text = channelInfo.channelName;
    _channelDescriptionLabel.text = channelInfo.channelIntro;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
