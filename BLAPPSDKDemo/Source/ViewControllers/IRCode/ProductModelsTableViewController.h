//
//  ProductModelsTableViewController.h
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CateGoriesTableViewController.h"

#import "IRCodeDownloadInfo.h"

@interface Brand : NSObject
@property(nonatomic, readonly, strong) NSString *name;
@property(nonatomic, readonly, assign) NSInteger brandId;
@property(nonatomic, readonly, assign) NSInteger cateGoryId;
@property(nonatomic, readonly, assign) BOOL famous;
@end

@interface Model : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) NSInteger modelId;
@property(nonatomic, assign) NSInteger brandId;
@property(nonatomic, assign) NSInteger devtype;
@end

@class BrandInfo;
@class ProviderInfo;
@class BLDNADevice;
@interface ProductModelsTableViewController : UITableViewController
@property (strong, nonatomic) BLDNADevice *device;
@property(nonatomic, strong) Model *model;
@property(nonatomic, strong) IRCodeDownloadInfo *downloadinfo;
@property(nonatomic, strong) BrandInfo *cateGory;
@property(nonatomic, strong) ProviderInfo *provider;
@property(nonatomic, assign) NSInteger devtype;
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, strong) NSString *randkey;
@property (nonatomic, strong) NSString *savePath;
@end
