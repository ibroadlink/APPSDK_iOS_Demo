//
//  LoginsTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/4.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "LoginsTableViewController.h"
#import "BLTheme.h"
#import "Tools.h"

@implementation LoginsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Account";
    self.view.backgroundColor = [BLTheme backgroundColor];
    NSArray *items = @[
        @{@"title": @"Password Login", @"desc": @"Sign in with username & password", @"symbol": @"lock.fill", @"tag": @100},
        @{@"title": @"Code Login", @"desc": @"Phone / email verification code", @"symbol": @"message.fill", @"tag": @101},
        @{@"title": @"Register", @"desc": @"Create a new BroadLink account", @"symbol": @"person.badge.plus", @"tag": @102},
        @{@"title": @"Account Info", @"desc": @"View profile after login", @"symbol": @"person.crop.circle", @"tag": @103},
    ];
    [BLTheme installMenuListOnView:self.view
                             title:@"Account"
                          subtitle:@"Choose how you want to sign in"
                             items:items
                            target:self
                            action:@selector(menuAction:)];
}

+ (instancetype)viewController {
    return [Tools viewControllerFromMainStoryboard:self];
}

- (void)menuAction:(UIButton *)sender {
    switch (sender.tag) {
        case 100:
            [self performSegueWithIdentifier:@"passwordLogin" sender:nil];
            break;
        case 101:
            [self performSegueWithIdentifier:@"codeLogin" sender:nil];
            break;
        case 102:
            [self performSegueWithIdentifier:@"RegisterView" sender:nil];
            break;
        case 103:
            [self performSegueWithIdentifier:@"ListMainView" sender:nil];
            break;
        default:
            break;
    }
}

- (IBAction)passwordLogin:(id)sender {}
- (IBAction)codeLogin:(id)sender {}
- (IBAction)accountRegister:(id)sender {}
- (IBAction)accountInfo:(id)sender {}

@end
