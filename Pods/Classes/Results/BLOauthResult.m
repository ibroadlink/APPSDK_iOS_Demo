//
//  BLOauthResult.m
//  Let
//
//  Created by zhujunjie on 2017/8/1.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLOauthResult.h"

@implementation BLOauthResult

+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    return @{@"accessToken":@"access_token",
             @"refreshToken":@"refresh_token",
             @"expires":@"expires_in"
             };
}

@end
