//
//  BLSInvitedQrcodeResult.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLSInvitedQrcodeResult.h"

@implementation BLSInvitedQrcodeResult

+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    
    return @{
             @"qrcode":@"data.qrcode"
             };
}

@end
