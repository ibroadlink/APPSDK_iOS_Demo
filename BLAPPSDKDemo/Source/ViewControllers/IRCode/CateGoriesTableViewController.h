//
//  CateGoriesTableViewController.h
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRCodeTestViewController.h"

#import "SubAreaInfo.h"
#import "BrandInfo.h"
#import "ProviderInfo.h"

@interface CateGoriesTableViewController : UITableViewController

@property(nonatomic, assign) NSInteger devtype;
@property(nonatomic, strong) SubAreaInfo *subAreainfo;

+ (instancetype)viewController;

@end
