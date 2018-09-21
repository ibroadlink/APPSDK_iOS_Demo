//
//  BLSubdevBaseResult.h
//  Let
//
//  Created by zhujunjie on 2017/10/20.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLSubdevBaseResult : BLBaseResult

/**
 Subdev control control status. 0--success, others--failed.
 */
@property (nonatomic, assign) NSInteger subdevStatus;

@end
