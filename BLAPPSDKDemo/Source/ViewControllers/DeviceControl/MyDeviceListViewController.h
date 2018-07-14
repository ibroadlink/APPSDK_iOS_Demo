//
//  MyDeviceListViewController.h
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/20.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

@interface MyDeviceListViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSMutableArray *myDevices;

@property (weak, nonatomic) IBOutlet UITableView *MyDeviceTable;

@property (nonatomic,strong)NSMutableArray *devicearray;
@end
