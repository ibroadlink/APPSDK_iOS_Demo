//
//  ProfileStringResult.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLProfileStringResult : BLBaseResult

/**
 Product profile info string.
 */
@property (nonatomic, strong, getter=getProfile) NSString *profile;

@end
