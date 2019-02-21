//
//  CateGoriesTableViewController.h
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRCodeTestViewController.h"
@interface CateGory : NSObject
@property(nonatomic, assign) NSInteger brandid;
@property(nonatomic, strong) NSString *brand;
@end

@interface Provider : NSObject
@property(nonatomic, assign) NSInteger providerid;
@property(nonatomic, strong) NSString *providername;
@property(nonatomic, assign) NSInteger locateid;
@end

@class SubAreaInfo;
@class BLDNADevice;
@interface CateGoriesTableViewController : UITableViewController
@property (strong, nonatomic) BLDNADevice *device;
@property(nonatomic, assign) NSInteger devtype;
@property(nonatomic, strong) SubAreaInfo *subAreainfo;
@end
