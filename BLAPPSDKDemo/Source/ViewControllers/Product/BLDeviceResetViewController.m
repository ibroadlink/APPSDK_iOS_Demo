//
//  BLDeviceResetViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/27.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLDeviceResetViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import "BLTheme.h"

@interface BLDeviceResetViewController ()
@property (nonatomic, strong) UIImageView *resetImageView;
@property (nonatomic, strong) UILabel *resetIntroductionLabel;
@end

@implementation BLDeviceResetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Reset Device";
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

    self.resetImageView = [[UIImageView alloc] init];
    self.resetImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.resetImageView.backgroundColor = [BLTheme cardColor];
    [content addSubview:self.resetImageView];

    self.resetIntroductionLabel = [[UILabel alloc] init];
    self.resetIntroductionLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    self.resetIntroductionLabel.textColor = [BLTheme subtitleColor];
    self.resetIntroductionLabel.numberOfLines = 0;
    [content addSubview:self.resetIntroductionLabel];

    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
    }];
    [self.resetImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(content);
        make.height.equalTo(self.resetImageView.mas_width);
    }];
    [self.resetIntroductionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resetImageView.mas_bottom).offset(20);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
        make.bottom.equalTo(content).offset(-28);
    }];
}

- (void)reloadContent {
    [self.resetImageView sd_setImageWithURL:[NSURL URLWithString:self.model.resetPic]];
    self.resetIntroductionLabel.text = self.model.resetText;
}

@end
