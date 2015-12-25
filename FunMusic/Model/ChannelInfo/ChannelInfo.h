//
//  ChannelInfo.h
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChannelInfo : NSObject

@property (nonatomic, copy) NSString *channelCoverURL;
@property (nonatomic, copy) NSString *channelID;
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, copy) NSString *channelIntro;
@property (nonatomic, copy) NSString *channelBannerURL;

- (instancetype) initWithDictionary:(NSDictionary *)dic;

@end