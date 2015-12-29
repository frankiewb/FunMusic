//
//  Utils.h
//  FunMusic
//
//  Created by frankie on 15/12/26.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChannelGroup.h"

@interface Utils : NSObject


+ (NSDictionary *)gennerateDicitonaryWithPlistFile:(NSString *)fileName;
+ (NSDictionary *)gennerateDicitonaryWithJsonFile:(NSString *)fileName;
+ (NSString *)gennerateChannelGroupNameWithChannelType:(ChannelType)type;
+ (ChannelType)gennerateChannelGroupTypeWithChannelName:(NSString *)name;




@end
