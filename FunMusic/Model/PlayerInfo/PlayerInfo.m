//
//  PlayerInfo.m
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "PlayerInfo.h"
#import "SongInfo.h"
#import "ChannelInfo.h"

@implementation PlayerInfo

- (id)init
{
    self = [super init];
    if (self)
    {
        _currentSong = [[SongInfo alloc] init];
        _currentSong.songId = @"0";
        
        _currentChannel.channelID = @"1";
        _currentChannel.channelName = @"华语";
    }
    
    return self;
}

@end
