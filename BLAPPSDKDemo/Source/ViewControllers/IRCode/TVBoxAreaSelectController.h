//
//  TVBoxAreaSelectController.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BaseViewController.h"
#import "IRCodeSubAreaInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface TVBoxAreaSelectController : BaseViewController

+ (instancetype)viewController;

@property (nonatomic, strong) IRCodeSubAreaInfo *currentArea;

@end

NS_ASSUME_NONNULL_END
