//
//  BLCloudTimerResult.h
//  Let
//
//  Created by 白洪坤 on 2017/12/14.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLBaseResult.h>

@interface BLCloudTimerResult : BLBaseResult
@property (nonatomic, strong, getter=getJobid) NSString *jobid;
@end
