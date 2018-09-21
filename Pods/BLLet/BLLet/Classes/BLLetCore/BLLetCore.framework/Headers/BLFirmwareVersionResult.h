//
//  FirmwareVersionResult.h
//  Let
//
//  Created by yzm on 16/5/17.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLFirmwareVersionResult : BLBaseResult

/**
 Firmware version
 */
@property (nonatomic, strong, getter=getVersion) NSString *version;


@end
