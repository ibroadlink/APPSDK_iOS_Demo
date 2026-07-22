//
//  FastconViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/14.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "FastconViewController.h"
#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import "Tools.h"
#import <Masonry/Masonry.h>

@interface FastconViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) BLDNADevice *device;
@property (nonatomic, strong) NSMutableArray *configArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextView *resultView;

@end

@implementation FastconViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Fastcon Functions";
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    self.configArray = [NSMutableArray arrayWithCapacity:0];
    [self buildUI];
}

- (void)buildUI {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.alwaysBounceVertical = YES;
    [self.view addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    [scroll addSubview:content];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [BLTheme cardColor];
    self.tableView.layer.cornerRadius = [BLTheme cardCornerRadius];
    self.tableView.clipsToBounds = YES;
    self.tableView.separatorColor = [BLTheme separatorColor];
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.tableView];
    [content addSubview:self.tableView];

    UIButton *listBtn = [BLTheme makeSecondaryButtonWithTitle:@"Get The WaitConfigDev List" target:self action:@selector(getFastconList)];
    UIButton *configBtn = [BLTheme makePrimaryButtonWithTitle:@"Fastcon Config" target:self action:@selector(fastconConfig)];
    UIButton *statusBtn = [BLTheme makeSecondaryButtonWithTitle:@"Fastcon Config Result" target:self action:@selector(getFastconStatus)];

    UIStackView *actions = [[UIStackView alloc] initWithArrangedSubviews:@[listBtn, configBtn, statusBtn]];
    actions.axis = UILayoutConstraintAxisVertical;
    actions.spacing = 10;
    [content addSubview:actions];

    for (UIButton *btn in @[listBtn, configBtn, statusBtn]) {
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
        }];
    }

    self.resultView = [[UITextView alloc] init];
    self.resultView.editable = NO;
    [BLTheme styleResultTextView:self.resultView];
    [content addSubview:self.resultView];

    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scroll);
        make.width.equalTo(scroll);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(12);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
        make.height.mas_equalTo(180);
    }];
    [actions mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom).offset(12);
        make.left.right.equalTo(self.tableView);
    }];
    [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(actions.mas_bottom).offset(12);
        make.left.right.equalTo(self.tableView);
        make.height.mas_equalTo(200);
        make.bottom.equalTo(content).offset(-24);
    }];
}

#pragma mark - Actions

- (void)getFastconList {
    [self showIndicatorOnWindowWithMessage:@"Getting fastcon devices..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getFastconListWith:0];
    });
}

- (void)fastconConfig {
    [self fastconNoConfig:self.configArray];
}

- (void)getFastconStatus {
    [self getFastconStatusWithDevList:self.configArray];
}

- (void)getFastconListWith:(NSUInteger)index {
    if (index == 0) {
        [self.configArray removeAllObjects];
    }
    NSDictionary *waitConfigDataDic = @{
        @"did": [Tools controlDidForDevice:self.device],
        @"act": @(0),
        @"count": @(10),
        @"index": @(index),
    };
    NSString *waitConfigDataStr = [Tools jsonStringFromObject:waitConfigDataDic];
    NSString *waitConfigResult = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] subDevDid:nil dataStr:waitConfigDataStr command:@"fastcon_no_config" scriptPath:nil];
    NSDictionary *dic = [Tools dictionaryFromJSONString:waitConfigResult];
    if ([dic[@"status"] integerValue] == 0) {
        NSDictionary *data = dic[@"data"];
        NSUInteger total = [data[@"total"] unsignedIntegerValue];
        NSArray *configList = data[@"devlist"];
        if (![BLCommonTools isEmptyArray:configList]) {
            [self.configArray addObjectsFromArray:configList];
            if (self.configArray.count < total) {
                [self getFastconListWith:++index];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideIndicatorOnWindow];
                    [self.tableView reloadData];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self.tableView reloadData];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [self.tableView reloadData];
        });
    }
}

- (void)fastconNoConfig:(NSArray *)configArray {
    NSDictionary *configDataDic = @{
        @"did": [Tools controlDidForDevice:self.device],
        @"act": @(1),
        @"devlist": configArray ?: @[],
    };
    NSString *configDataStr = [Tools jsonStringFromObject:configDataDic];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *configResult = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] subDevDid:nil dataStr:configDataStr command:@"fastcon_no_config" scriptPath:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultView.text = configResult;
        });
    });
}

- (void)getFastconStatusWithDevList:(NSArray *)configList {
    NSDictionary *dic = @{
        @"did": [Tools controlDidForDevice:self.device],
        @"act": @(2),
        @"devlist": configList ?: @[],
    };
    NSString *str = [Tools jsonStringFromObject:dic];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *result = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] subDevDid:nil dataStr:str command:@"fastcon_no_config" scriptPath:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultView.text = result;
        });
    });
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.configArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DEVICE_LIST_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        cell.textLabel.textColor = [BLTheme titleColor];
    }
    NSDictionary *deviceDic = self.configArray[indexPath.row];
    cell.textLabel.text = deviceDic[@"did"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
