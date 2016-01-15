//
//  TitlebarView.h
//  FunMusic
//
//  Created by frankie on 15/12/26.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitlebarView : UIScrollView

@property (nonatomic, strong) NSMutableArray *titleButtonArray;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, copy) void (^titleButtonClicked)(NSInteger index);

- (instancetype)initWithFrame:(CGRect)frame titleNames:(NSArray *)titleArray;

- (void)dawnAndNightMode;

@end
