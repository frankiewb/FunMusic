//
//  PlayerInfo.h
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SongInfo;
@class ChannelInfo;

@interface PlayerInfo : NSObject

@property(nonatomic,strong) ChannelInfo *currentChannel;
@property(nonatomic,strong) SongInfo *currentSong;


@end
