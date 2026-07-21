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
#import <Masonry/Masonry.h>

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
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];

    UIView *content = [[UIView alloc] init];
    [scrollView addSubview:content];

    UILabel *brandLabel = [[UILabel alloc] init];
    brandLabel.text = @"BLTool";
    brandLabel.font = [UIFont systemFontOfSize:34 weight:UIFontWeightBold];
    brandLabel.textColor = [BLTheme titleColor];
    [content addSubview:brandLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"BroadLink App SDK Demo";
    subtitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [BLTheme subtitleColor];
    [content addSubview:subtitleLabel];

    UIView *accentBar = [[UIView alloc] init];
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
        [row mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(132);
        }];
    }

    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
    }];
    [brandLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(20);
        make.left.equalTo(content).offset(24);
        make.right.equalTo(content).offset(-24);
    }];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(brandLabel.mas_bottom).offset(6);
        make.left.right.equalTo(brandLabel);
    }];
    [accentBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subtitleLabel.mas_bottom).offset(14);
        make.left.equalTo(brandLabel);
        make.width.mas_equalTo(36);
        make.height.mas_equalTo(4);
    }];
    [grid mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accentBar.mas_bottom).offset(28);
        make.left.equalTo(content).offset(20);
        make.right.equalTo(content).offset(-20);
        make.bottom.equalTo(content).offset(-32);
    }];
}

- (UIView *)menuCardWithItem:(NSDictionary *)item {
    UIButton *card = [UIButton buttonWithType:UIButtonTypeCustom];
    card.tag = [item[@"tag"] integerValue];
    [card addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [BLTheme styleCardView:card];
    card.backgroundColor = [BLTheme cardColor];

    UIView *iconBg = [[UIView alloc] init];
    iconBg.userInteractionEnabled = NO;
    iconBg.backgroundColor = [BLTheme primaryLightColor];
    iconBg.layer.cornerRadius = 18;
    [card addSubview:iconBg];

    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.userInteractionEnabled = NO;
    iconView.tintColor = [BLTheme primaryColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium];
        iconView.image = [UIImage systemImageNamed:item[@"symbol"] withConfiguration:config];
    }
    [iconBg addSubview:iconView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.userInteractionEnabled = NO;
    titleLabel.text = item[@"title"];
    titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    titleLabel.textColor = [BLTheme titleColor];
    [card addSubview:titleLabel];

    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.userInteractionEnabled = NO;
    descLabel.text = item[@"desc"];
    descLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    descLabel.textColor = [BLTheme subtitleColor];
    descLabel.numberOfLines = 2;
    [card addSubview:descLabel];

    [iconBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(card).offset(16);
        make.width.height.mas_equalTo(40);
    }];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(iconBg);
        make.width.height.mas_equalTo(22);
    }];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(card).offset(16);
        make.right.equalTo(card).offset(-12);
        make.bottom.equalTo(card).offset(-16);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(descLabel);
        make.bottom.equalTo(descLabel.mas_top).offset(-4);
    }];

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
