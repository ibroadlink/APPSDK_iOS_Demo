//
//  BLProductCategoryList.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>
NS_ASSUME_NONNULL_BEGIN



@interface BLProductCategoryList : BLBaseResult
@property (nonatomic, strong) NSArray *hotproducts;
@property (nonatomic, strong) NSArray *categorylist;
@property (nonatomic, strong) NSArray *productlist;
@end

NS_ASSUME_NONNULL_END
