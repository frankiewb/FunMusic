//
//  Util.m
//  FunMusic
//
//  Created by frankie on 16/1/2.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "NSDate+Util.h"

@implementation NSDate (Util)

+ (NSString *)gennerateCurrentTimeString
{
    //获取系统当前时间
    NSDate *date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    
    //设置时间输出格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH小时mm分ss秒"];
    NSString *currentTIme = [formatter stringFromDate:currentDate];
    
    return currentTIme;
}

@end
