//
//  ChannelInfo.m
//  FunMusic
//
//  Created by frankie on 15/12/25.
//  Copyright © 2015年 Wang Bo. All rights reserved.
//

#import "ChannelInfo.h"

static NSString *kChannelID    = @"channelID";
static NSString *kChannelName  = @"channelName";
static NSString *kChannelIntro = @"channelIntro";
static NSString *kChannelImage = @"channelImage";

@implementation ChannelInfo


- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        _channelID        = dic[@"channelid"];
        _channelName      = dic[@"name"];
        _channelIntro     = dic[@"intro"];
        _channelImage     = dic[@"imagename"];
    }
    
    return self;
}

- (instancetype)initWithChannelInfo:(ChannelInfo *)channelInfo
{
    self = [super init];
    if (self)
    {
        _channelID    = channelInfo.channelID;
        _channelName  = channelInfo.channelName;
        _channelIntro = channelInfo.channelIntro;
        _channelImage = channelInfo.channelImage;
    }
    
    return self;
}


+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.channelID forKey:kChannelID];
    [aCoder encodeObject:self.channelName forKey:kChannelName];
    [aCoder encodeObject:self.channelIntro forKey:kChannelIntro];
    [aCoder encodeObject:self.channelImage forKey:kChannelImage];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.channelID    = [aDecoder decodeObjectOfClass:[NSString class] forKey:kChannelID];
        self.channelName  = [aDecoder decodeObjectOfClass:[NSString class] forKey:kChannelName];
        self.channelIntro = [aDecoder decodeObjectOfClass:[NSString class] forKey:kChannelIntro];
        self.channelImage = [aDecoder decodeObjectOfClass:[NSString class] forKey:kChannelImage];
    }
    
    return self;
}







@end
