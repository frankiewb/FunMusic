//
//  ChannelCell.h
//  FunMusic
//
//  Created by frankie on 15/12/27.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChannelInfo;
@class MarqueeLabel;

@interface ChannelCell : UITableViewCell

@property (nonatomic, strong) UIImageView *channelImageView;
@property (nonatomic, strong) UILabel *channelNameLabel;
@property (nonatomic, strong) MarqueeLabel *channelDescriptionLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setUpChannelCellWithChannelInfo:(ChannelInfo *)channelInfo;





@end
