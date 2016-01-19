//
//  ChannelCell.h
//  FunMusic
//
//  Created by frankie on 15/12/27.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChannelInfo;

@interface ChannelCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setUpChannelCellWithChannelInfo:(ChannelInfo *)channelInfo;

- (void)dawnAndNightMode;


@end
