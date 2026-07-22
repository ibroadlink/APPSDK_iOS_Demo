//
//  ConfigureViewController.h
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ConfigureViewController : BaseViewController <UITextFieldDelegate, CLLocationManagerDelegate>

+ (instancetype)viewController;

@end
