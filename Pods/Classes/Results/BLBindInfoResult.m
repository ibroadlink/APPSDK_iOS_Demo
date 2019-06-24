//
//  BLBindInfoResult.m
//  BLLetCore
//
//  Created by 白洪坤 on 2018/2/28.
//  Copyright © 2018年 朱俊杰. All rights reserved.
//

#import "BLBindInfoResult.h"

@implementation BLBindinfo

@end

@implementation BLBindInfoResult
+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    return @{@"bindinfos" : BLBindinfo.class};
}
@end
