//
//  RecoginzeIRCodeViewController.h
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/14.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

#import "IRCodeDownloadInfo.h"

@class BLDNADevice;

@interface RecoginzeIRCodeViewController : BaseViewController

@property (nonatomic, strong) IRCodeDownloadInfo *downloadinfo;
@property (nonatomic, strong) BLDNADevice *device;

+ (instancetype)viewController;

@end
