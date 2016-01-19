//
//  UserHeaderView.h
//  FunMusic
//
//  Created by frankie on 16/1/19.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserHeaderView : UIView

- (void)dawnAndNightMode;
- (void)refreshHeaderViewWithUserName:(NSString *)userName imageName:(NSString *)imageName Login:(BOOL)isLogin;

@property (nonatomic, copy) void(^pushLoginView)();

@end
