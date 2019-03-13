//
//  DNAControlViewController.h
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/25.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"
#import <BLLetCore/BLLetCore.h>


@interface DNAControlViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) BLDNADevice *device;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


- (IBAction)buttonClick:(UIButton *)sender;
@end
