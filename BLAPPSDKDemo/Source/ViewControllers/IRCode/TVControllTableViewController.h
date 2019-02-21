//
//  TVControllTableViewController.h
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/15.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BLDNADevice;
@interface TVControllTableViewController : UITableViewController
@property (strong, nonatomic) BLDNADevice *device;
@property (nonatomic, strong) NSString *savePath;
@property (nonatomic, strong) NSArray *tvList;
@property(nonatomic, assign) NSInteger devtype;
@end
