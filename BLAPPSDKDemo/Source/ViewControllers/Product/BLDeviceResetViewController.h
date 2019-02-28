//
//  BLDeviceResetViewController.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/27.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLDeviceConfigureInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface BLDeviceResetViewController : UIViewController
@property (nonatomic, strong, readwrite) BLDeviceConfigureInfo *model;
@end

NS_ASSUME_NONNULL_END
