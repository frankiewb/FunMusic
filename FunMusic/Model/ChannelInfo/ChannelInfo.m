//
//  ChannelInfo.m
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ChannelInfo.h"

@implementation ChannelInfo


- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        _channelCoverURL  = dic[@"cover"];
        _channelID        = dic[@"id"];
        _channelName      = dic[@"name"];
        _channelIntro     = dic[@"intro"];
        _channelBannerURL = dic[@"banner"];
    }
    
    return self;
}

@end
