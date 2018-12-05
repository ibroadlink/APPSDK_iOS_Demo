//
//  BLGatewayTranslateResult.h
//  Let
//
//  Created by 白洪坤 on 2017/8/31.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLGatewayTranslateResult : BLBaseResult

@property (nonatomic, strong) NSString *data;

@property (nonatomic, assign) NSInteger eventcode;

@property (nonatomic, copy) NSArray *keys;

@property (nonatomic, copy) NSArray *privatedatas;

@end
