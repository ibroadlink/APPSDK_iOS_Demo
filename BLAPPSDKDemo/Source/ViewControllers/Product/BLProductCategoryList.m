//
//  BLProductCategoryList.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLProductCategoryList.h"
#import "BLProductCategoryModel.h"
#import "BLDeviceConfigureInfo.h"
@implementation BLProductCategoryList

// 声明自定义类参数类型
+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    return @{@"categorylist" : [BLProductCategoryModel class],
             @"hotproducts": [BLDeviceConfigureInfo class],
             @"productlist": [BLDeviceConfigureInfo class]
             };
}

@end
