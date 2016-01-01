//
//  Util.m
//  FunMusic
//
//  Created by frankie on 16/1/1.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import "NSTimer+Util.h"

@implementation NSTimer (Util)

+ (NSTimer *)fmScheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void (^)())block repeates:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(fmBlcokInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}

+ (void)fmBlcokInvoke:(NSTimer *)timer
{
    void (^block)() = timer.userInfo;
    if (block)
    {
        block();
    }
}

@end
