//
//  Util.m
//  FunMusic
//
//  Created by frankie on 16/1/13.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "UIColor+Util.h"
#import "AppDelegate.h"

@implementation UIColor (Util)

+ (UIColor *)themeColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).isNightMode)
    {
        return [UIColor colorWithRed:0.17 green:0.17 blue:0.17 alpha:1.0];
    }
    return [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1.0];
}

+ (UIColor *)standerTextColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).isNightMode)
    {
        return [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1.0];
    }
    return [UIColor colorWithRed:60/255.0 green:60/255.0 blue:60/255.0 alpha:1.0];
}

+ (UIColor *)standerGreyTextColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).isNightMode)
    {
        return [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    }
    return [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];
}

+ (UIColor *)standerGreenTextColor
{
    return [UIColor colorWithRed:85/255.0 green:185/255.0 blue:121/255.0 alpha:1.0];
}

+ (UIColor *)standerGreenFillColor
{
    return [UIColor colorWithRed:92/255.0 green:187/255.0 blue:125/255.0 alpha:1.0];
}

+ (UIColor *)standerTextBackGroudColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).isNightMode)
    {
        return [UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:1.0];
    }
    return [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
}

+ (UIColor *)navigationBarColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).isNightMode)
    {
        return [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];

    }
    return [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1.0];
    
}

+ (UIColor *)navigationBarTextColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).isNightMode)
    {
        return [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    }
    return [UIColor colorWithRed:60/255.0 green:60/255.0 blue:60/255.0 alpha:1.0];
}

+ (UIColor *)tabbarColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).isNightMode)
    {
        return [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
       
    }
    return [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1.0];
}

+ (UIColor *)tabbarTextColor
{
    return [UIColor colorWithRed:60/255.0 green:60/255.0 blue:60/255.0 alpha:1.0];
}

+ (UIColor *)titlebarColor
{    
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).isNightMode)
    {
        return [UIColor colorWithRed:0.17 green:0.17 blue:0.17 alpha:1.0];
    }
    return [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1.0];
}

+ (UIColor *)inputColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).isNightMode)
    {
        return [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    }
    return [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1.0];
}

@end
