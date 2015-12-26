//
//  Util.m
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "AFHTTPSessionManager+Util.h"

@implementation AFHTTPSessionManager (Util)


+ (instancetype)fmJSONManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return manager;
}


+ (instancetype)fmHTTPManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    return manager;
}

@end
