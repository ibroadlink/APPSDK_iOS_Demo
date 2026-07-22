//
//  APConfigTableViewController.m
//  SDKDemo
//
//  Created by 白洪坤 on 2017/7/25.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import "APConfigTableViewController.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import <Masonry/Masonry.h>

@interface APConfigTableViewController ()

@property (nonatomic, strong) UITextField *pubkeyTextField;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) NSMutableDictionary *apDict;

@end

@implementation APConfigTableViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"AP Config";
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.apDict = [NSMutableDictionary dictionary];
    [self buildUI];
}

- (void)buildUI {
    self.pubkeyTextField = [BLTheme makeTextFieldWithPlaceholder:@"Device AP Public Key"];
    self.pubkeyTextField.delegate = self;
    self.pubkeyTextField.returnKeyType = UIReturnKeyDone;

    UIButton *pubkeyButton = [BLTheme makeSecondaryButtonWithTitle:@"Get Pubkey"
                                                            target:self
                                                            action:@selector(getDeviceAPPubkey)];
    UIButton *refreshButton = [BLTheme makePrimaryButtonWithTitle:@"Scan AP List"
                                                           target:self
                                                           action:@selector(refresh)];

    UIStackView *actionRow = [[UIStackView alloc] initWithArrangedSubviews:@[pubkeyButton, refreshButton]];
    actionRow.axis = UILayoutConstraintAxisHorizontal;
    actionRow.spacing = 12;
    actionRow.distribution = UIStackViewDistributionFillEqually;
    [pubkeyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(48);
    }];
    [refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(48);
    }];

    UIView *header = [[UIView alloc] init];
    [header addSubview:self.pubkeyTextField];
    [header addSubview:actionRow];

    UILabel *listTitle = [[UILabel alloc] init];
    listTitle.text = @"Nearby Wi-Fi";
    listTitle.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    listTitle.textColor = [BLTheme titleColor];
    [header addSubview:listTitle];

    self.countLabel = [[UILabel alloc] init];
    self.countLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    self.countLabel.textColor = [BLTheme primaryColor];
    self.countLabel.textAlignment = NSTextAlignmentRight;
    self.countLabel.text = @"0 found";
    [header addSubview:self.countLabel];

    UILabel *hint = [[UILabel alloc] init];
    hint.text = @"Connect to device hotspot first, then scan and pick an SSID";
    hint.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    hint.textColor = [BLTheme subtitleColor];
    hint.numberOfLines = 0;
    [header addSubview:hint];

    [self.pubkeyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(header).offset(8);
        make.left.equalTo(header).offset(16);
        make.right.equalTo(header).offset(-16);
    }];
    [actionRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pubkeyTextField.mas_bottom).offset(12);
        make.left.right.equalTo(self.pubkeyTextField);
        make.height.mas_equalTo(48);
    }];
    [listTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(actionRow.mas_bottom).offset(20);
        make.left.equalTo(self.pubkeyTextField);
        make.right.equalTo(self.countLabel.mas_left).offset(-8);
    }];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(listTitle);
        make.right.equalTo(self.pubkeyTextField);
        make.width.mas_greaterThanOrEqualTo(56);
    }];
    [hint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(listTitle.mas_bottom).offset(4);
        make.left.right.equalTo(self.pubkeyTextField);
        make.bottom.equalTo(header).offset(-8);
    }];

    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    header.frame = CGRectMake(0, 0, width, 210);
    [header setNeedsLayout];
    [header layoutIfNeeded];
    CGSize size = [header systemLayoutSizeFittingSize:CGSizeMake(width, UILayoutFittingCompressedSize.height)];
    header.frame = CGRectMake(0, 0, width, size.height);

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [BLTheme backgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = header;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"No AP found yet\nTap Scan AP List to refresh";
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.emptyLabel.textColor = [BLTheme subtitleColor];
    [self.view addSubview:self.emptyLabel];
    [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(40);
        make.left.equalTo(self.view).offset(32);
        make.right.equalTo(self.view).offset(-32);
    }];
    [self updateEmptyState];
}

- (void)updateEmptyState {
    BOOL empty = self.apDict.count == 0;
    self.emptyLabel.hidden = !empty;
    self.countLabel.text = [NSString stringWithFormat:@"%lu found", (unsigned long)self.apDict.count];
}

- (void)getDeviceAPPubkey {
    // SDK pubkey API currently disabled in demo; keep entry for future use.
    [BLStatusBar showTipMessageWithStatus:@"Get Pubkey is not available in this demo build"];
}

- (void)refresh {
    [self.view endEditing:YES];
    [self showIndicatorOnWindow];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLGetAPListResult *apconfigResult = [[BLLet sharedLet].controller deviceAPList:7000];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([apconfigResult succeed]) {
                [self.apDict removeAllObjects];
                for (BLAPInfo *info in apconfigResult.list) {
                    if (info.ssid.length > 0) {
                        [self.apDict setObject:info forKey:info.ssid];
                    }
                }
                [self.tableView reloadData];
                [self updateEmptyState];
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"deviceAPList status:%ld,msg:%@", (long)apconfigResult.status, apconfigResult.msg]];
            }
        });
    });
}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apDict.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 84;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AP_LIST_CARD_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UILabel *titleLabel;
    UILabel *detailLabel;

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        UIView *card = [[UIView alloc] init];
        card.tag = 200;
        [BLTheme styleCardView:card];
        [cell.contentView addSubview:card];

        UIView *iconBg = [[UIView alloc] init];
        iconBg.backgroundColor = [BLTheme primaryLightColor];
        iconBg.layer.cornerRadius = 14;
        [card addSubview:iconBg];

        UIImageView *icon = [[UIImageView alloc] init];
        icon.tintColor = [BLTheme primaryColor];
        if (@available(iOS 13.0, *)) {
            icon.image = [UIImage systemImageNamed:@"wifi"];
        }
        [iconBg addSubview:icon];

        titleLabel = [[UILabel alloc] init];
        titleLabel.tag = 201;
        titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        titleLabel.textColor = [BLTheme titleColor];
        [card addSubview:titleLabel];

        detailLabel = [[UILabel alloc] init];
        detailLabel.tag = 202;
        detailLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        detailLabel.textColor = [BLTheme primaryColor];
        [card addSubview:detailLabel];

        UIImageView *chevron = [[UIImageView alloc] init];
        chevron.tintColor = [BLTheme subtitleColor];
        if (@available(iOS 13.0, *)) {
            chevron.image = [UIImage systemImageNamed:@"chevron.right"];
        }
        [card addSubview:chevron];

        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(6, 16, 6, 16));
        }];
        [iconBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(card).offset(14);
            make.centerY.equalTo(card);
            make.width.height.mas_equalTo(36);
        }];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(iconBg);
            make.width.height.mas_equalTo(18);
        }];
        [chevron mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(card).offset(-14);
            make.centerY.equalTo(card);
            make.width.mas_equalTo(10);
            make.height.mas_equalTo(14);
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(card).offset(18);
            make.left.equalTo(iconBg.mas_right).offset(12);
            make.right.equalTo(chevron.mas_left).offset(-8);
        }];
        [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(4);
            make.left.right.equalTo(titleLabel);
        }];
    } else {
        titleLabel = (UILabel *)[cell.contentView viewWithTag:201];
        detailLabel = (UILabel *)[cell.contentView viewWithTag:202];
    }

    NSArray *apListArray = [self.apDict allValues];
    BLAPInfo *APinfo = apListArray[indexPath.row];
    titleLabel.text = APinfo.ssid ?: @"Unknown SSID";
    detailLabel.text = [NSString stringWithFormat:@"Type %ld · Tap to configure", (long)APinfo.type];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *apListArray = [self.apDict allValues];
    BLAPInfo *APinfo = apListArray[indexPath.row];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AP Config"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = APinfo.ssid;
        textField.placeholder = @"SSID";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Config" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *ssidtxt = alertController.textFields.firstObject;
        UITextField *passwordtxt = alertController.textFields.lastObject;

        [self showIndicatorOnWindow];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BLAPConfigResult *apconfigResult = [[BLLet sharedLet].controller deviceAPConfig:ssidtxt.text
                                                                                   password:passwordtxt.text
                                                                                       type:APinfo.type];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                if ([apconfigResult succeed]) {
                    NSLog(@"apconfig success:did--%@,pid--%@,devkey--%@", apconfigResult.did, apconfigResult.pid, apconfigResult.devkey);
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"deviceAPConfig status:%ld,msg:%@", (long)apconfigResult.status, apconfigResult.msg]];
                }
            });
        });
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
