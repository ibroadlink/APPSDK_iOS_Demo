//
//  ModifyUserIconResult.m
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLModifyUserIconResult.h"

@implementation BLModifyUserIconResult

+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    return @{@"iconUrl":@"icon"
             };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.iconUrl = @"";
    }
    
    return self;
}

@end
