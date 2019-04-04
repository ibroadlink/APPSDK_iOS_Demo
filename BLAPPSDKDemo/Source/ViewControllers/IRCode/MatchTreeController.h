//
//  MatchTreeController.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/4/3.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class BLDNADevice;
@class IRCodeBrandInfo;

@interface MatchTreeController : BaseViewController

@property (nonatomic, assign) NSInteger devtype;
@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, strong) IRCodeBrandInfo *brand;

+ (instancetype)viewController;

@end

NS_ASSUME_NONNULL_END
