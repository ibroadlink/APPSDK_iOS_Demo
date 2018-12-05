//
//  BLSceneDeteailResult.h
//  Let
//
//  Created by 白洪坤 on 2017/12/12.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLBaseResult.h>
#import "BLSceneDeteailData.h"
@interface BLSceneDeteailResult : BLBaseResult
@property (nonatomic, copy) NSMutableArray<BLSceneDeteailData*> *scenedetailList;
@end
