//
//  UserInfo.m
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo



- (instancetype) initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        _isNotLogin = dic[@"r"];
        
        NSDictionary *tempUserInfoDic = dic[@"user_info"];
        _cookies = tempUserInfoDic[@"ck"];
        _userID = tempUserInfoDic[@"id"];
        _userName = tempUserInfoDic[@"name"];
        
        NSDictionary *tempPlayRecordDic = tempUserInfoDic[@"play_record"];
        _banned = [NSString stringWithFormat:@"%@",tempPlayRecordDic[@"banned"]];
        _liked = [NSString stringWithFormat:@"%@",tempPlayRecordDic[@"liked"]];
        _plyaed = [NSString stringWithFormat:@"%@",tempPlayRecordDic[@"played"]];

    }
    
    return self;
}

@end
