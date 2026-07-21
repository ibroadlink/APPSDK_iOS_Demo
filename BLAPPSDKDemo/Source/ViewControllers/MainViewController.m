//
//  MainViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/25.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "MainViewController.h"
#import "LoginsTableViewController.h"
#import "UserViewController.h"
#import "FamilyListViewController.h"
#import "DeviceMainViewController.h"
#import "IRCodeTestViewController.h"
#import "ProductListViewController.h"
#import "PushViewController.h"

#import "BLUserDefaults.h"
#import "BLStatusBar.h"
#import "BLTheme.h"

@interface MainViewController ()

- (IBAction)buttonClick:(UIButton *)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    [self buildModernHomeUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.prefersLargeTitles = NO;
}

- (void)buildModernHomeUI {
    for (UIView *subview in self.view.subviews) {
        subview.hidden = YES;
    }

    self.view.backgroundColor = [BLTheme backgroundColor];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];

    UIView *content = [[UIView alloc] init];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:content];

    UILabel *brandLabel = [[UILabel alloc] init];
    brandLabel.translatesAutoresizingMaskIntoConstraints = NO;
    brandLabel.text = @"BLTool";
    brandLabel.font = [UIFont systemFontOfSize:34 weight:UIFontWeightBold];
    brandLabel.textColor = [BLTheme titleColor];
    [content addSubview:brandLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    subtitleLabel.text = @"BroadLink App SDK Demo";
    subtitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [BLTheme subtitleColor];
    [content addSubview:subtitleLabel];

    UIView *accentBar = [[UIView alloc] init];
    accentBar.translatesAutoresizingMaskIntoConstraints = NO;
    accentBar.backgroundColor = [BLTheme primaryColor];
    accentBar.layer.cornerRadius = 2;
    [content addSubview:accentBar];

    NSArray *items = @[
        @{@"title": @"Account", @"desc": @"Login & profile", @"symbol": @"person.crop.circle.fill", @"tag": @100},
        @{@"title": @"Family", @"desc": @"Homes & rooms", @"symbol": @"house.fill", @"tag": @101},
        @{@"title": @"Device", @"desc": @"Discover & control", @"symbol": @"wifi", @"tag": @102},
        @{@"title": @"IR Code", @"desc": @"Remote learning", @"symbol": @"tv.fill", @"tag": @103},
        @{@"title": @"Product", @"desc": @"Catalog & setup", @"symbol": @"cube.box.fill", @"tag": @104},
        @{@"title": @"Push", @"desc": @"Notifications", @"symbol": @"bell.badge.fill", @"tag": @105},
    ];

    UIStackView *grid = [[UIStackView alloc] init];
    grid.translatesAutoresizingMaskIntoConstraints = NO;
    grid.axis = UILayoutConstraintAxisVertical;
    grid.spacing = 14;
    [content addSubview:grid];

    for (NSInteger i = 0; i < items.count; i += 2) {
        UIStackView *row = [[UIStackView alloc] init];
        row.axis = UILayoutConstraintAxisHorizontal;
        row.spacing = 14;
        row.distribution = UIStackViewDistributionFillEqually;

        UIView *left = [self menuCardWithItem:items[i]];
        [row addArrangedSubview:left];

        if (i + 1 < items.count) {
            UIView *right = [self menuCardWithItem:items[i + 1]];
            [row addArrangedSubview:right];
        } else {
            UIView *spacer = [[UIView alloc] init];
            spacer.backgroundColor = [UIColor clearColor];
            [row addArrangedSubview:spacer];
        }
        [grid addArrangedSubview:row];
        [row.heightAnchor constraintEqualToConstant:132].active = YES;
    }

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [content.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor],
        [content.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor],
        [content.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor],
        [content.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor],
        [content.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor],

        [brandLabel.topAnchor constraintEqualToAnchor:content.topAnchor constant:20],
        [brandLabel.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:24],
        [brandLabel.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-24],

        [subtitleLabel.topAnchor constraintEqualToAnchor:brandLabel.bottomAnchor constant:6],
        [subtitleLabel.leadingAnchor constraintEqualToAnchor:brandLabel.leadingAnchor],
        [subtitleLabel.trailingAnchor constraintEqualToAnchor:brandLabel.trailingAnchor],

        [accentBar.topAnchor constraintEqualToAnchor:subtitleLabel.bottomAnchor constant:14],
        [accentBar.leadingAnchor constraintEqualToAnchor:brandLabel.leadingAnchor],
        [accentBar.widthAnchor constraintEqualToConstant:36],
        [accentBar.heightAnchor constraintEqualToConstant:4],

        [grid.topAnchor constraintEqualToAnchor:accentBar.bottomAnchor constant:28],
        [grid.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:20],
        [grid.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-20],
        [grid.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-32],
    ]];
}

- (UIView *)menuCardWithItem:(NSDictionary *)item {
    UIButton *card = [UIButton buttonWithType:UIButtonTypeCustom];
    card.tag = [item[@"tag"] integerValue];
    [card addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [BLTheme styleCardView:card];
    card.backgroundColor = [BLTheme cardColor];

    UIView *iconBg = [[UIView alloc] init];
    iconBg.translatesAutoresizingMaskIntoConstraints = NO;
    iconBg.userInteractionEnabled = NO;
    iconBg.backgroundColor = [BLTheme primaryLightColor];
    iconBg.layer.cornerRadius = 18;
    [card addSubview:iconBg];

    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.userInteractionEnabled = NO;
    iconView.tintColor = [BLTheme primaryColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium];
        iconView.image = [UIImage systemImageNamed:item[@"symbol"] withConfiguration:config];
    }
    [iconBg addSubview:iconView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.userInteractionEnabled = NO;
    titleLabel.text = item[@"title"];
    titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    titleLabel.textColor = [BLTheme titleColor];
    [card addSubview:titleLabel];

    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.translatesAutoresizingMaskIntoConstraints = NO;
    descLabel.userInteractionEnabled = NO;
    descLabel.text = item[@"desc"];
    descLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    descLabel.textColor = [BLTheme subtitleColor];
    descLabel.numberOfLines = 2;
    [card addSubview:descLabel];

    [NSLayoutConstraint activateConstraints:@[
        [iconBg.topAnchor constraintEqualToAnchor:card.topAnchor constant:16],
        [iconBg.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [iconBg.widthAnchor constraintEqualToConstant:40],
        [iconBg.heightAnchor constraintEqualToConstant:40],

        [iconView.centerXAnchor constraintEqualToAnchor:iconBg.centerXAnchor],
        [iconView.centerYAnchor constraintEqualToAnchor:iconBg.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:22],
        [iconView.heightAnchor constraintEqualToConstant:22],

        [titleLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [titleLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-12],
        [titleLabel.bottomAnchor constraintEqualToAnchor:descLabel.topAnchor constant:-4],

        [descLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [descLabel.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor],
        [descLabel.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-16],
    ]];

    return card;
}

- (IBAction)buttonClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 100:
            [self gotoAccountViewController];
            break;
        case 101:
            [self gotoFamilyViewController];
            break;
        case 102:
            [self gotoDeviceViewController];
            break;
        case 103:
            [self gotoIRCodeViewController];
            break;
        case 104:
            [self gotoProductViewController];
            break;
        case 105:
            [self gotoPushViewController];
            break;
        default:
            break;
    }
}

- (void)gotoAccountViewController {
    if ([self hasBeenLogined]) {
        UserViewController *vc = [UserViewController viewController];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        LoginsTableViewController *vc = [LoginsTableViewController viewController];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)gotoFamilyViewController {
    if ([self hasBeenLogined]) {
        FamilyListViewController *vc = [FamilyListViewController viewController];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [BLStatusBar showTipMessageWithStatus:@"Please login first!!!"];
    }
}

- (void)gotoDeviceViewController {
    DeviceMainViewController *vc = [DeviceMainViewController viewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoIRCodeViewController {
    if ([self hasBeenLogined]) {
        IRCodeTestViewController *vc = [IRCodeTestViewController viewController];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [BLStatusBar showTipMessageWithStatus:@"Please login first!!!"];
    }
}

- (void)gotoProductViewController {
    if ([self hasBeenLogined]) {
        ProductListViewController *vc = [ProductListViewController viewController];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [BLStatusBar showTipMessageWithStatus:@"Please login first!!!"];
    }
}

- (void)gotoPushViewController {
    if ([self hasBeenLogined]) {
        PushViewController *vc = [PushViewController viewController];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [BLStatusBar showTipMessageWithStatus:@"Please login first!!!"];
    }
}

- (BOOL)hasBeenLogined {
    BLUserDefaults *userDefaults = [BLUserDefaults shareUserDefaults];
    NSString *userId = [userDefaults getUserId];
    NSString *loginSession = [userDefaults getSessionId];
    if (userId && loginSession) {
        return YES;
    } else {
        return NO;
    }
    
}

@end
