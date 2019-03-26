//
//  ProductModelsTableViewController.h
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CateGoriesTableViewController.h"

#import "IRCodeBrandInfo.h"
#import "IRCodeProviderInfo.h"
#import "IRCodeModel.h"
#import "IRCodeDownloadInfo.h"

@interface ProductModelsTableViewController : UITableViewController

@property (nonatomic, assign) NSUInteger devtype;
@property (nonatomic, strong) IRCodeModel *model;
@property (nonatomic, strong) IRCodeDownloadInfo *downloadinfo;
@property (nonatomic, strong) IRCodeBrandInfo *brandInfo;
@property (nonatomic, strong) IRCodeProviderInfo *provider;

+ (instancetype)viewController;

@end
