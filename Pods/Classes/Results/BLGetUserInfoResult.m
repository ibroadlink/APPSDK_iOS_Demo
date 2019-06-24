//
//  GetUserInfoResult.m
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLGetUserInfoResult.h"

@implementation BLUserInfo

+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    return @{@"iconUrl":@"icon"
             };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userid = @"";
        self.nickname = @"";
        self.iconUrl = @"";
    }
    
    return self;
}

@end



@implementation BLGetUserInfoResult

+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    return @{@"info" : BLUserInfo.class};
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.info = [[NSArray alloc] init];
    }
    
    return self;
}

@end
