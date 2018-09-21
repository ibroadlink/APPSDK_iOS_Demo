//
//  BLSceneHistroyResult.h
//  Let
//
//  Created by 白洪坤 on 2017/12/12.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLBaseResult.h>
#import "BLSceneData.h"
@interface BLSceneHistroyResult : BLBaseResult
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, copy) NSMutableArray<BLSceneData *> *scenelist;
@end
