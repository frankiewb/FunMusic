//
//  ChannelInfo.m
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ChannelInfo.h"

@implementation ChannelInfo


- (instancetype)initWithDictionary:(NSMutableDictionary *)dic
{
    self = [super init];
    if (self)
    {
        _channelID        = dic[@"channelid"];
        _channelName      = dic[@"name"];
        _channelIntro     = dic[@"intro"];
        _channelImage     = dic[@"imagename"];
    }
    
    return self;
}

- (instancetype)initWithChannelInfo:(ChannelInfo *)channelInfo
{
    self = [super init];
    if (self)
    {
        _channelID    = channelInfo.channelID;
        _channelName  = channelInfo.channelName;
        _channelIntro = channelInfo.channelIntro;
        _channelImage = channelInfo.channelImage;
    }
    
    return self;
}

@end
