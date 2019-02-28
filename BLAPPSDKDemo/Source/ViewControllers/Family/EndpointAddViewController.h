//
//  EndpointAddViewController.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/21.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EndpointAddViewController : BaseViewController

@property (nonatomic, strong) BLDNADevice *selectDevice;
@property (nonatomic, copy) NSDictionary *h5param;

+ (EndpointAddViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
