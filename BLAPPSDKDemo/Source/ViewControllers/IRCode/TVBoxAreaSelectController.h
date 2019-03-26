//
//  TVBoxAreaSelectController.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BaseViewController.h"
#import "SubAreaInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface TVBoxAreaSelectController : BaseViewController

+ (instancetype)viewController;

@property (nonatomic, strong) SubAreaInfo *currentArea;

@end

NS_ASSUME_NONNULL_END
