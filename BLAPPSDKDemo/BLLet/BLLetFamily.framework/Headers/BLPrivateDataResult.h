//
//  BLPrivateDataResult.h
//  Let
//
//  Created by 白洪坤 on 2017/9/1.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>
#import "BLPrivateData.h"
@interface BLPrivateDataResult : BLBaseResult
@property (nonatomic, copy) NSMutableArray<BLPrivateData *> *dataList;
@property (nonatomic, strong) NSString *version;
@end
