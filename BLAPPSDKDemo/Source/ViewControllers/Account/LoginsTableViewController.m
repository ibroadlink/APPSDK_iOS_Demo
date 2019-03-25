//
//  LoginsTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/4.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "LoginsTableViewController.h"

@implementation LoginsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (instancetype)viewController {
    LoginsTableViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}


- (IBAction)passwordLogin:(id)sender {
    
}

- (IBAction)codeLogin:(id)sender {
    
}

- (IBAction)accountRegister:(id)sender {
    
}

- (IBAction)accountInfo:(id)sender {
    
}


@end
