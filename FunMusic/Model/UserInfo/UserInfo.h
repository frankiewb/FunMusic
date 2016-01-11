//
//  UserInfo.h
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, copy) NSString *userImage;
@property (nonatomic, copy) NSString *userName;

- (instancetype) initWithDictionary:(NSDictionary *)dic;

@end
