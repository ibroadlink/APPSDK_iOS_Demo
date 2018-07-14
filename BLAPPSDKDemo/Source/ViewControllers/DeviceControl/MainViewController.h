//
//  MainViewController.h
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/20.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

@interface MainViewController : BaseViewController

+ (instancetype)viewController;

@property (weak, nonatomic) IBOutlet UITableView *mainTabel;

@end
