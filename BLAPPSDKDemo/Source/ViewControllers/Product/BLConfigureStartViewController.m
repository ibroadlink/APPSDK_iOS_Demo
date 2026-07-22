//
//  BLConfigureStartViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/27.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLConfigureStartViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import "BLDeviceResetViewController.h"
#import "BLWebViewController.h"
#import "BLDeviceConfigIntroduction.h"
#import "BLTheme.h"

@interface BLConfigureStartViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation BLConfigureStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Product Info";
    self.view.backgroundColor = [BLTheme backgroundColor];
    [self buildUI];
    [self reloadContent];
}

- (void)buildUI {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];

    UIView *content = [[UIView alloc] init];
    [scrollView addSubview:content];

    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [BLTheme cardColor];
    [content addSubview:self.imageView];

    self.label = [[UILabel alloc] init];
    self.label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    self.label.textColor = [BLTheme titleColor];
    self.label.numberOfLines = 0;
    [content addSubview:self.label];

    UIButton *resetButton = [BLTheme makePrimaryButtonWithTitle:@"The indicator is in other states"
                                                        target:self
                                                        action:@selector(deviceReset:)];
    UIButton *beforeConfigButton = [BLTheme makeSecondaryButtonWithTitle:@"Before the config"
                                                                  target:self
                                                                  action:@selector(beforecfgpurl:)];
    UIButton *failedButton = [BLTheme makeSecondaryButtonWithTitle:@"Config failure description"
                                                            target:self
                                                            action:@selector(cfgfailedurl:)];
    UIButton *manualButton = [BLTheme makeSecondaryButtonWithTitle:@"Product manual"
                                                            target:self
                                                            action:@selector(introduction:)];

    UIStackView *buttonStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        resetButton, beforeConfigButton, failedButton, manualButton
    ]];
    buttonStack.axis = UILayoutConstraintAxisVertical;
    buttonStack.spacing = 12;
    [content addSubview:buttonStack];

    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
    }];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(content);
        make.height.equalTo(self.imageView.mas_width).multipliedBy(32.0 / 58.0);
    }];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(16);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
    }];
    [buttonStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.label.mas_bottom).offset(24);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
        make.bottom.equalTo(content).offset(-28);
    }];
}

- (void)reloadContent {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.model.configPicUrlString]];
    self.label.text = self.model.configText;
}

- (void)deviceReset:(id)sender {
    BLDeviceResetViewController *vc = [[BLDeviceResetViewController alloc] init];
    vc.model = self.model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)beforecfgpurl:(id)sender {
    BLWebViewController *webViewVC = [[BLWebViewController alloc] init];
    webViewVC.url = self.model.beforeConfigHtml;
    [self.navigationController pushViewController:webViewVC animated:YES];
}

- (void)cfgfailedurl:(id)sender {
    BLWebViewController *webViewVC = [[BLWebViewController alloc] init];
    webViewVC.url = self.model.failedHtml;
    [self.navigationController pushViewController:webViewVC animated:YES];
}

- (void)introduction:(id)sender {
    NSArray *introductions = self.model.introduction;
    if (introductions.count == 1) {
        BLWebViewController *webViewVC = [[BLWebViewController alloc] init];
        BLDeviceConfigIntroduction *introduction = introductions[0];
        webViewVC.url = introduction.url;
        [self.navigationController pushViewController:webViewVC animated:YES];
    } else {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"分类" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (BLDeviceConfigIntroduction *introduction in introductions) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:introduction.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                BLWebViewController *webViewVC = [[BLWebViewController alloc] init];
                webViewVC.url = introduction.url;
                [self.navigationController pushViewController:webViewVC animated:YES];
            }];
            [alertView addAction:action];
        }
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertView addAction:cancelAction];
        [self presentViewController:alertView animated:YES completion:nil];
    }
}

@end
