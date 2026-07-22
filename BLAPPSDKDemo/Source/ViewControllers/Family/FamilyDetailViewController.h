//
//  FamilyDetailViewController.h
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/17.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"
#import <BLSFamily/BLSFamily.h>

@interface FamilyDetailViewController : BaseViewController

+ (instancetype)viewController;

@property (nonatomic, strong) BLSFamilyInfo *familyInfo;

@end
