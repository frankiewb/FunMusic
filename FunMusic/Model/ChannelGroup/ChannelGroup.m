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

- (instancetype) initWithChannelType:(ChannelType)channelType channelGroupDictionary:(NSDictionary *)channelDic
{
    self = [super init];
    if (self)
    {
        _channelArray = [[NSMutableArray alloc] init];
        [self setChannelArrayWithDictionary:channelDic];
        _channelType = channelType;
    }
    
    return self;
}

- (void)setChannelArrayWithDictionary:(NSDictionary *)dic
{
    NSAssert(_channelArray, [NSString stringWithFormat:@"ChannelArray has not been inited !"]);
    NSString * singleChannelKey;
    NSMutableArray * singleChannelValue;
    for (singleChannelKey in dic)
    {
        singleChannelValue = dic[singleChannelKey];
        ChannelInfo * channelCell = [[ChannelInfo alloc] initWithDictionary:singleChannelValue];
        [_channelArray addObject:channelCell];
    }
}

@end
