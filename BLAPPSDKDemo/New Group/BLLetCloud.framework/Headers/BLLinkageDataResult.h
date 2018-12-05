//
//  BLLinkageDataResult.h
//  Let
//
//  Created by 白洪坤 on 2017/12/20.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLBaseResult.h>


@interface BLLinkageDataResult : BLBaseResult
@property (nonatomic, strong) NSArray *devinfo;
@property (nonatomic, strong) NSArray *linkages;
@property (nonatomic, strong) NSArray *modules;
@end
