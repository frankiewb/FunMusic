//
//  ChannelGroup.m
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ChannelGroup.h"
#import "ChannelInfo.h"


@implementation ChannelGroup

- (instancetype) initWithChannelType:(ChannelType)channelType channelName:(NSString *)name channelGroupDictionary:(NSDictionary *)channelDic
{
    self = [super init];
    if (self)
    {
        _channelArray = [[NSMutableArray alloc] init];
        [self setChannelArrayWithDictionary:channelDic];
        _channelType = channelType;
        _channelName = name;
    }
    
    return self;
}

- (void)setChannelArrayWithDictionary:(NSDictionary *)dic
{
    NSAssert(_channelArray, [NSString stringWithFormat:@"ChannelArray has not been inited !"]);
    NSString *singlehannelKey;
    NSDictionary *singleChannelValue;
    for (singlehannelKey in dic)
    {
        singleChannelValue = dic[singlehannelKey];
        ChannelInfo *channelInfo = [[ChannelInfo alloc] initWithDictionary:singleChannelValue];
        [_channelArray addObject:channelInfo];
    }
}

@end
