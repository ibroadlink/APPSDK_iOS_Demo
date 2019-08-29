//
//  FastconGroupDeviceViewController.h
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/8/23.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface FastconGroupDeviceViewController : BaseViewController

+ (instancetype)viewController;

@property (nonatomic, copy) NSString *did;

@end

NS_ASSUME_NONNULL_END
