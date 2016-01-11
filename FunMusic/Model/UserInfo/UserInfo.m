//
//  UserInfo.m
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo


- (instancetype) init
{
    self = [super init];
    if (self)
    {
        _isLogin = FALSE;
        _userImage = @"userDefaultImage";
        _userName = @"未登录";
    }
    
    return self;
}



- (instancetype) initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        _isLogin = TRUE;
        _userImage = dic[@"image"];
        _userName = dic[@"name"];
    }
    
    return self;
}

@end
