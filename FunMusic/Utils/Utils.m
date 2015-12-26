//
//  Utils.m
//  FunMusic
//
//  Created by frankie on 15/12/26.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSDictionary *)gennerateDicitonaryWithJsonFile:(NSString *)fileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    //NSDataReadingMappedIfSafe:使用该参数后，IOS就不会把整个文件全部读取到内存
    //而是将文件映射到进程的地址空间中，这么做并不会展示实际的内存
    NSData *jsonFileData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
    NSDictionary *jsonDataDic = [NSJSONSerialization JSONObjectWithData:jsonFileData options:NSJSONReadingAllowFragments error:nil];
    return jsonDataDic;
}


@end

