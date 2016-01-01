//
//  Utils.m
//  FunMusic
//
//  Created by frankie on 15/12/26.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "Utils.h"
#import "ChannelInfo.h"

@implementation Utils

+ (NSDictionary *)gennerateDicitonaryWithJsonFile:(NSString *)fileName
{
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSString *errorMsg = [NSString stringWithFormat:@"%@.json could not find !",fileName];
    NSAssert(filePath, errorMsg);
    //NSDataReadingMappedIfSafe:使用该参数后，IOS就不会把整个文件全部读取到内存
    //而是将文件映射到进程的地址空间中，这么做并不会展示实际的内存
    NSData *jsonFileData = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary *jsonDataDic = [NSJSONSerialization JSONObjectWithData:jsonFileData options:NSJSONReadingAllowFragments error:&error];
    NSString *errorMsg1 = [NSString stringWithFormat:@"%@.json could not open !",fileName];
    NSAssert(jsonDataDic, errorMsg1);
    return jsonDataDic;
}


+ (NSDictionary *)gennerateDicitonaryWithPlistFile:(NSString *)fileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSMutableDictionary *channelGroupDic = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    return channelGroupDic;
}



+ (ChannelType)gennerateChannelGroupTypeWithChannelName:(NSString *)name
{
    if ([name isEqualToString:@"心情"] || [name isEqualToString:@"channelFeeling"])
    {
        return ChannelTypeFeeling;
    }
    else if ([name isEqualToString:@"语言"] || [name isEqualToString:@"channelLanguage"])
    {
        return ChannelTypeLanguage;
    }
    else if ([name isEqualToString:@"推荐"] || [name isEqualToString:@"channelRecomand"])
    {
        return ChannelTypeRecomand;
    }
    else if ([name isEqualToString:@"风格"] || [name isEqualToString:@"channelSongStyle"])
    {
        return ChannelTypeSongStyle;
        
    }
    else
    {
        NSString *errorMsg = [NSString stringWithFormat:@"%@ ERRORNAME, Can not find the corresponding ChannelType", name];
        //NSAssert如果为假则抛出异常
        NSAssert(FALSE, errorMsg);
    }
    return 0;
}

+ (NSString *)gennerateChannelGroupNameWithChannelType:(ChannelType)type isChineseLanguage:(BOOL)isChinese
{
    NSString *channelGroupName;
    switch (type)
    {
        case ChannelTypeFeeling:
            isChinese?(channelGroupName = @"心情"):(channelGroupName = @"channelFeeling");
            break;
        case ChannelTypeLanguage:
            isChinese?(channelGroupName = @"语言"):(channelGroupName = @"channelLanguage");
            break;
        case ChannelTypeRecomand:
            isChinese?(channelGroupName = @"推荐"):(channelGroupName = @"channelRecomand");
            break;
        case ChannelTypeSongStyle:
            isChinese?(channelGroupName = @"风格"):(channelGroupName = @"channelSongStyle");            
            break;
    }
    
    return channelGroupName;
}



@end
