//
//  ChannelGroup.h
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChannelInfo;

typedef NS_ENUM(NSUInteger, ChannelType)
{
    ChannelTypeRecomand = 1,
    ChannelTypeLanguage,
    ChannelTypeSongStyle,
    ChannelTypeFeeling,
};

@interface ChannelGroup : NSObject

@property (nonatomic, copy) NSMutableArray * channelArray;
@property (nonatomic, assign) ChannelType channelType;


- (instancetype) initWithChannelType:(ChannelType) channelType channelGroupDictionary:(NSDictionary *)channelDic;


@end
