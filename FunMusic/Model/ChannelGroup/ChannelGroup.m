//
//  ChannelGroup.m
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ChannelGroup.h"


@implementation ChannelGroup

- (instancetype) initWithChannelTypeName:(NSString *)channelTypeName channelType:(ChannelType)channelType
{
    self = [super init];
    if (self)
    {
        _channelArray = [[NSMutableArray alloc] init];
        _channelType = channelType;
        _channelTypeName = channelTypeName;
    }
    
    return self;
}



@end
