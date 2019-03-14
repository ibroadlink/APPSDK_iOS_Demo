//
//  LoginsTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/4.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "LoginsTableViewController.h"
#import "BLUserDefaults.h"

@implementation LoginsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *userId = [[BLUserDefaults shareUserDefaults] getUserId];
    NSString *logSession = [[BLUserDefaults shareUserDefaults] getSessionId];
    
    if (userId && logSession) {
        [self performSegueWithIdentifier:@"ListMainView" sender:nil];
    }
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
