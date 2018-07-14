//
//  DeviceListViewController.h
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

@interface DeviceListViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource,BLControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *deviceListTableView;

@end
