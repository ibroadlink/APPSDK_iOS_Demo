//
//  OperateViewController.h
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

@class BLDNADevice;

@interface OperateViewController : BaseViewController

@property (strong, nonatomic) BLDNADevice *device;

@property (weak, nonatomic) IBOutlet UITextView *resultText;

@end
