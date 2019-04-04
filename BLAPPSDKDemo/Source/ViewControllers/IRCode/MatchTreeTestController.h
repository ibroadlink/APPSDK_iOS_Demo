//
//  MatchTreeTestController.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/4/3.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class BLDNADevice, TreeInfo;

@interface MatchTreeTestController : BaseViewController

+ (instancetype)viewController;

@property (nonatomic, assign) NSInteger devtype;
@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, strong) TreeInfo *treeInfo;

@end

NS_ASSUME_NONNULL_END
