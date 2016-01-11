//
//  LogInfo.h
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogInfo : NSObject

@property(nonatomic,copy) NSString *loginName;
@property(nonatomic,copy) NSString *passWord;

- (BOOL)isLoginSuccessfull:(NSDictionary *)loginData;

@end
