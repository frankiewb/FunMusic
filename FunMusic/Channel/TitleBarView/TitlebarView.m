//
//  TitlebarView.m
//  FunMusic
//
//  Created by frankie on 15/12/26.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "TitlebarView.h"
#import "UIColor+Util.h"
#import "Common.h"

@implementation TitlebarView

static const CGFloat kContentSizeHeight  = 25;
static const CGFloat kTitleLabelFontSize = 15;
static const CGFloat kFirstButtonScale   = 1.2;

- (instancetype)initWithFrame:(CGRect)frame titleNames:(NSArray *)titleArray
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor themeColor];
        _currentIndex = 0;
        _titleButtonArray = [[NSMutableArray alloc] init];
        
        CGFloat buttonWidth = frame.size.width / titleArray.count;
        CGFloat buttonHeight = frame.size.height;
        
        [titleArray enumerateObjectsUsingBlock:^(NSString *titleName, NSUInteger idx, BOOL *stop)
         {
             UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
             button.backgroundColor = [UIColor themeColor];
             button.titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
             [button setTitleColor:[UIColor standerTextColor] forState:UIControlStateNormal];
             [button setTitle:titleName forState:UIControlStateNormal];
             
             button.frame = CGRectMake(buttonWidth * idx, 0, buttonWidth, buttonHeight);
             button.tag = idx;
             [button addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
             
             [_titleButtonArray addObject:button];
             [self addSubview:button];
             //将指定视图移动到它相邻视图的后面
             [self sendSubviewToBack:button];
         }];
        
        self.contentSize = CGSizeMake(frame.size.width, kContentSizeHeight);
        self.showsHorizontalScrollIndicator = NO;
        UIButton *firstTitle = _titleButtonArray[0];
        [firstTitle setTitleColor:[UIColor standerGreenTextColor] forState:UIControlStateNormal];
        //让firstbutton X轴Y轴放大
        firstTitle.transform = CGAffineTransformMakeScale(kFirstButtonScale, kFirstButtonScale);
    }
    
    return self;
}

- (void)onClicked:(UIButton *)button
{
    UIButton *oldFirstButton = _titleButtonArray[_currentIndex];
    [oldFirstButton setTitleColor:[UIColor standerTextColor] forState:UIControlStateNormal];
    //重置原坐标系
    oldFirstButton.transform = CGAffineTransformIdentity;
    
    [button setTitleColor:[UIColor standerGreenTextColor] forState:UIControlStateNormal];
    button.transform = CGAffineTransformMakeScale(kFirstButtonScale, kFirstButtonScale);
    
    _currentIndex = button.tag;
    //块函数实现回调处理titleClicked逻辑
    _titleButtonClicked(button.tag);
    
}








@end
