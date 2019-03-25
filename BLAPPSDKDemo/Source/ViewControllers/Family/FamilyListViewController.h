//
//  FamilyListViewController.h
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/6.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

@interface FamilyListViewController : BaseViewController

+ (instancetype)viewController;

@property (weak, nonatomic) IBOutlet UITableView *familyListTableView;

- (IBAction)addFamilyBtnClick:(UIBarButtonItem *)sender;

@end
