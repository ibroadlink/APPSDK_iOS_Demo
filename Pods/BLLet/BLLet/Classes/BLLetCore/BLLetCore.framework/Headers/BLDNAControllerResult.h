//
//  DNAControllerResult.h
//  Let
//
//  Created by yzm on 16/5/19.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLDNAControllerResult : BLBaseResult

/**
 Device control cookie
 */
@property (nonatomic, strong, getter=getCookie) NSString *cookie;

/**
 Device control data
 */
@property (nonatomic, strong, getter=getData) NSDictionary *data;

@end
