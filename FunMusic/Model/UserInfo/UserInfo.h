//
//  UserInfo.h
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic, copy) NSString *isNotLogin;
@property (nonatomic, copy) NSString *cookies;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *banned;
@property (nonatomic, copy) NSString *liked;
@property (nonatomic, copy) NSString *plyaed;

- (instancetype) initWithDictionary:(NSDictionary *)dic;

@end
