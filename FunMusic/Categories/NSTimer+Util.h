//
//  Util.h
//  FunMusic
//
//  Created by frankie on 16/1/1.
//  Copyright © 2016年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Util)

+ (NSTimer *)fmScheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)())block repeates:(BOOL)repeats;

@end
