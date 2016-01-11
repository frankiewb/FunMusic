//
//  LogInfo.m
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "LogInfo.h"

@implementation LogInfo

- (BOOL)isLoginSuccessfull:(NSDictionary *)loginData
{
    if ([_loginName isEqualToString:loginData[@"name"]] && [_passWord isEqualToString:loginData[@"password"]])
    {
        return TRUE;
    }
    return FALSE;
}


@end
