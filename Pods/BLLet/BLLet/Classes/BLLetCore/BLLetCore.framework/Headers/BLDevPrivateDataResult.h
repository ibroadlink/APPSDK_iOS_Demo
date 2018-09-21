//
//  BLPrivateDataResult.h
//  Let
//
//  Created by 白洪坤 on 2017/9/1.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>
#import "BLDevPrivateData.h"
@interface BLDevPrivateDataResult : BLBaseResult
@property (nonatomic, copy) NSMutableArray<BLDevPrivateData *> *dataList;
@property (nonatomic, strong) NSString *version;
@end
