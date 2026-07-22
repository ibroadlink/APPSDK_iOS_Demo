//
//  LoginsTableViewController.m
//  BLAPPSDKDemo
//

#import "LoginsTableViewController.h"
#import "LoginViewController.h"
#import "CodeLoginViewController.h"
#import "RegisterViewController.h"
#import "LoginByOauthViewController.h"
#import "UserViewController.h"
#import "BLTheme.h"

@implementation LoginsTableViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Account";

    NSArray *items = @[
        @{@"title": @"Password Login",
          @"desc": @"Sign in with phone / email & password",
          @"symbol": @"lock.fill",
          @"tag": @100},
        @{@"title": @"Code Login",
          @"desc": @"One-tap sign in with verification code",
          @"symbol": @"message.fill",
          @"tag": @101},
        @{@"title": @"Create Account",
          @"desc": @"Register a new BroadLink account",
          @"symbol": @"person.badge.plus",
          @"tag": @102},
        @{@"title": @"OAuth Login",
          @"desc": @"Sign in via OAuth authorization page",
          @"symbol": @"globe",
          @"tag": @104},
        @{@"title": @"My Profile",
          @"desc": @"View and manage account details",
          @"symbol": @"person.crop.circle",
          @"tag": @103},
    ];
    [BLTheme installMenuListOnView:self.view
                             title:@"Account"
                          subtitle:@"Sign in to unlock family, devices and more"
                             items:items
                            target:self
                            action:@selector(menuAction:)];
}

- (void)menuAction:(UIButton *)sender {
    UIViewController *vc = nil;
    switch (sender.tag) {
        case 100: vc = [LoginViewController viewController]; break;
        case 101: vc = [CodeLoginViewController viewController]; break;
        case 102: vc = [RegisterViewController viewController]; break;
        case 103: vc = [UserViewController viewController]; break;
        case 104: vc = [LoginByOauthViewController viewController]; break;
        default: break;
    }
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
