//
//  PushViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/4/28.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "PushViewController.h"
#import "BLSNotificationService.h"
#import "BLDeviceService.h"
#import "BLTemplate.h"
#import "LinkageTemplate.h"
#import "BLTheme.h"
#import <Masonry/Masonry.h>

@interface PushViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITextView *deviceInfoView;
@property (nonatomic, strong) UITextView *resultTextView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, copy) NSArray<BLTemplateElement *> *templates;
@property (nonatomic, copy) NSArray *linkages;
@property (nonatomic, assign) BOOL isTemplates;
@end

@implementation PushViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Push";
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.isTemplates = YES;
    [self buildUI];
}

- (UIButton *)makeActionButtonWithTitle:(NSString *)title tag:(NSInteger)tag {
    UIButton *button = [BLTheme makePrimaryButtonWithTitle:title target:self action:@selector(buttonClick:)];
    button.tag = tag;
    return button;
}

- (void)buildUI {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scrollView];

    UIView *content = [[UIView alloc] init];
    [scrollView addSubview:content];

    UILabel *deviceTitle = [self sectionLabel:@"Device Profile"];
    UILabel *resultTitle = [self sectionLabel:@"Result"];
    UILabel *listTitle = [self sectionLabel:@"Templates / Linkages"];

    self.deviceInfoView = [[UITextView alloc] init];
    [BLTheme styleResultTextView:self.deviceInfoView];
    self.deviceInfoView.text = @"Select a device to load profile";

    self.resultTextView = [[UITextView alloc] init];
    [BLTheme styleResultTextView:self.resultTextView];

    UIStackView *buttonStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self makeActionButtonWithTitle:@"Report Token" tag:100],
        [self makeActionButtonWithTitle:@"Push Setting" tag:101],
        [self makeActionButtonWithTitle:@"User Logout" tag:102],
        [self makeActionButtonWithTitle:@"Query Template List" tag:103],
        [self makeActionButtonWithTitle:@"Query Linkage List" tag:104],
    ]];
    buttonStack.axis = UILayoutConstraintAxisVertical;
    buttonStack.spacing = 10;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [BLTheme cardColor];
    self.tableView.separatorColor = [BLTheme separatorColor];
    self.tableView.layer.cornerRadius = [BLTheme cardCornerRadius];
    self.tableView.layer.masksToBounds = YES;
    self.tableView.scrollEnabled = NO;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }

    [content addSubview:deviceTitle];
    [content addSubview:self.deviceInfoView];
    [content addSubview:resultTitle];
    [content addSubview:self.resultTextView];
    [content addSubview:buttonStack];
    [content addSubview:listTitle];
    [content addSubview:self.tableView];

    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
    }];
    [deviceTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(16);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
    }];
    [self.deviceInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(deviceTitle.mas_bottom).offset(8);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
        make.height.mas_equalTo(80);
    }];
    [resultTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deviceInfoView.mas_bottom).offset(16);
        make.left.right.equalTo(deviceTitle);
    }];
    [self.resultTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(resultTitle.mas_bottom).offset(8);
        make.left.right.equalTo(self.deviceInfoView);
        make.height.mas_equalTo(160);
    }];
    [buttonStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resultTextView.mas_bottom).offset(16);
        make.left.right.equalTo(self.deviceInfoView);
    }];
    [listTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(buttonStack.mas_bottom).offset(20);
        make.left.right.equalTo(deviceTitle);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(listTitle.mas_bottom).offset(8);
        make.left.right.equalTo(self.deviceInfoView);
        make.height.mas_equalTo(200);
        make.bottom.equalTo(content).offset(-24);
    }];
}

- (UILabel *)sectionLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    label.textColor = [BLTheme titleColor];
    return label;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateTableHeight];
}

- (void)updateTableHeight {
    [self.tableView layoutIfNeeded];
    CGFloat height = MAX(120, self.tableView.contentSize.height);
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

- (void)buttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 100:
            [self reportToken];
            break;
        case 101:
            [self pushSetting];
            break;
        case 102:
            [self userLogout];
            break;
        case 103:
            [self showDeviceList];
            break;
        case 104:
            [self queryLinkageList];
            break;
        default:
            break;
    }
}

- (void)reportToken {
    [[BLSNotificationService sharedInstance] registerDeviceCompletionHandler:^(NSString * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultTextView.text = result;
        });
    }];
}

- (void)pushSetting {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Enable" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[BLSNotificationService sharedInstance] setAllPushState:YES completionHandler:^(NSString * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultTextView.text = result;
            });
        }];
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Disable" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[BLSNotificationService sharedInstance] setAllPushState:NO completionHandler:^(NSString * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultTextView.text = result;
            });
        }];
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)userLogout {
    [[BLSNotificationService sharedInstance] userLogoutCompletionHandler:^(NSString * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultTextView.text = result;
        });
    }];
}

- (void)showDeviceList {
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Please Select Device" preferredStyle:UIAlertControllerStyleActionSheet];
    [deviceService.manageDevices enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull did, BLDNADevice * _Nonnull dev, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@%@", dev.name, did] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.device = dev;
            if (self.device) {
                NSString *profile = [self getDeviceProfile];
                [self showCatDialog:profile];
            }
        }];
        [alertController addAction:action];
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showCatDialog:(NSString *)profile {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Input category" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = profile;
        textField.placeholder = @"srvs";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *srvs = alertController.textFields.firstObject.text;
        NSArray *categorys = [NSArray arrayWithObject:srvs];
        [[BLSNotificationService sharedInstance] queryCategory:categorys TemplateWithCompletionHandler:^(BLTemplate * _Nonnull template) {
            if (template.status == 0) {
                self.templates = template.templates;
                self.isTemplates = YES;
            }
            NSDictionary *dic = [template BLS_modelToJSONObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self updateTableHeight];
                self.resultTextView.text = [BLCommonTools serializeMessage:dic];
            });
        }];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSString *)getDeviceProfile {
    BLProfileStringResult *result = [[BLLet sharedLet].controller queryProfileByPid:self.device.pid];
    if ([result succeed]) {
        NSString *profileStr = [result getProfile];
        self.deviceInfoView.text = profileStr;
        NSDictionary *dic = [BLCommonTools deserializeMessageJSON:profileStr];
        NSArray *srvStrArray = dic[@"srvs"];
        if (![BLCommonTools isEmptyArray:srvStrArray]) {
            return srvStrArray.firstObject;
        }
    }
    return nil;
}

- (void)queryLinkageList {
    [[BLSNotificationService sharedInstance] queryLinkageInfoWithCompletionHandler:^(LinkageTemplate * _Nonnull linkageTemplate) {
        if (linkageTemplate.status == 0) {
            self.linkages = linkageTemplate.linkages;
            self.isTemplates = NO;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self updateTableHeight];
            self.resultTextView.text = [linkageTemplate BLS_modelToJSONString];
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isTemplates) {
        return self.templates.count;
    }
    return self.linkages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TEMPLATES_LIST_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        cell.textLabel.textColor = [BLTheme titleColor];
    }

    if (self.isTemplates) {
        BLTemplateElement *template = self.templates[indexPath.row];
        cell.textLabel.text = template.templatename[0].name;
    } else {
        Linkage *linkage = self.linkages[indexPath.row];
        cell.textLabel.text = linkage.rulename;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isTemplates) {
        BLTemplateElement *template = self.templates[indexPath.row];
        NSDictionary *module = @{
                                 @"moduleid": @"",
                                 @"name": self.device.name,
                                 @"did": self.device.did
                                 };
        [[BLSNotificationService sharedInstance] addLinkageWithTemplate:template module:module CompletionHandler:^(BLBaseResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultTextView.text = [result BLS_modelToJSONString];
            });
        }];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isTemplates) {
        Linkage *linkage = self.linkages[indexPath.row];
        [[BLSNotificationService sharedInstance] deleteLinkageInfoWithRuleid:linkage.ruleid CompletionHandler:^(BLBaseResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultTextView.text = [result BLS_modelToJSONString];
            });
        }];
    }
}

@end
