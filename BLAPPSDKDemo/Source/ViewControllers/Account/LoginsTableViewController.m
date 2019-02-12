//
//  LoginsTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/4.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "LoginsTableViewController.h"
#import "BLUserDefaults.h"
#import <BLLetAccount/BLLetAccount.h>
#import <WebKit/WebKit.h>
@interface LoginsTableViewController ()
@property (strong,nonatomic)BLAccount *account;
@end

@implementation LoginsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _account = [BLAccount sharedAccount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
