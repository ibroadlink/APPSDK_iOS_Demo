//
//  EndpointDetailController.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/1.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BaseViewController.h"
#import "BLNewFamilyManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface EndpointDetailController : BaseViewController

+ (EndpointDetailController *)viewController;

@property (nonatomic, assign) BOOL isNeedDeviceControl;
@property (nonatomic, strong) BLSEndpointInfo *endpoint;

@end

NS_ASSUME_NONNULL_END
