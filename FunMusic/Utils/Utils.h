//
//  Utils.h
//  FunMusic
//
//  Created by frankie on 15/12/26.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChannelGroup.h"


@class ChannelInfo;

@interface Utils : NSObject


+ (NSDictionary *)getDicitonaryWithPlistFile:(NSString *)fileName;

+ (NSDictionary *)getDicitonaryWithJsonFile:(NSString *)fileName;

+ (NSString *)getChannelGroupNameWithChannelType:(ChannelType)type isChineseLanguage:(BOOL)isChinese;

+ (ChannelType)getChannelGroupTypeWithChannelName:(NSString *)name;




@end
