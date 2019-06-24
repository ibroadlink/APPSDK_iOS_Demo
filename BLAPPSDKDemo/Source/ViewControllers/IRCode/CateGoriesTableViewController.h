//
//  CateGoriesTableViewController.h
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRCodeTestViewController.h"

#import "IRCodeSubAreaInfo.h"
#import "IRCodeBrandInfo.h"
#import "IRCodeProviderInfo.h"
#import "IRCodeLocationInfo.h"

@interface CateGoriesTableViewController : UITableViewController

@property(nonatomic, assign) NSInteger devtype;
@property(nonatomic, strong) IRCodeLocationInfo *currentLocation;

+ (instancetype)viewController;

@end
