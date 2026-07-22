//
//  BLAddDeviceListViewController.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/27.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BaseViewController.h"
#import "BLProductCategoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLAddDeviceListViewController : BaseViewController

+ (instancetype)viewController;

@property (nonatomic, strong, readwrite) BLProductCategoryModel *model;

@end

NS_ASSUME_NONNULL_END
