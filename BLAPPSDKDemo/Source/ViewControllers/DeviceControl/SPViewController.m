//
//  SPViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/7/26.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "SPViewController.h"
#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import "Tools.h"
#import <Masonry/Masonry.h>

@interface SPViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, strong) NSMutableArray *timerList;
@property (nonatomic, strong) UITableView *timerTableView;
@property (nonatomic, strong) UIButton *switchButton;

@end

@implementation SPViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SP Device Demo";
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    self.timerList = [[NSMutableArray alloc] init];
    [self buildUI];
    [self GetSpSwitch];
    [self GetTimerList];
}

- (void)buildUI {
    UIView *toolbarCard = [[UIView alloc] init];
    [BLTheme styleCardView:toolbarCard];
    [self.view addSubview:toolbarCard];

    self.switchButton = [BLTheme makePrimaryButtonWithTitle:@"OFF" target:self action:@selector(SPSwitch)];
    UIButton *addButton = [BLTheme makeSecondaryButtonWithTitle:@"Add Timer" target:self action:@selector(addTimerBtn)];

    UIStackView *toolbar = [[UIStackView alloc] initWithArrangedSubviews:@[self.switchButton, addButton]];
    toolbar.axis = UILayoutConstraintAxisHorizontal;
    toolbar.spacing = 12;
    toolbar.distribution = UIStackViewDistributionFillEqually;
    [toolbarCard addSubview:toolbar];

    self.timerTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.timerTableView.delegate = self;
    self.timerTableView.dataSource = self;
    self.timerTableView.backgroundColor = [BLTheme backgroundColor];
    self.timerTableView.separatorColor = [BLTheme separatorColor];
    if (@available(iOS 15.0, *)) {
        self.timerTableView.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.timerTableView];
    [self.view addSubview:self.timerTableView];

    [toolbarCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(8);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
    }];
    [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(toolbarCard).insets(UIEdgeInsetsMake(12, 12, 12, 12));
        make.height.mas_equalTo(48);
    }];
    [self.timerTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(toolbarCard.mas_bottom).offset(8);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-8);
    }];
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timerList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TIMERCELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [BLTheme cardColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        cell.textLabel.textColor = [BLTheme titleColor];
        cell.textLabel.numberOfLines = 0;
    }
    cell.textLabel.text = self.timerList[indexPath.row];
    return cell;
}

#pragma mark - Business

- (void)GetTimerList {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setParams:@[@"tmrtsk", @"pertsk", @"cyctsk", @"randtsk"] values:@[@[@{@"val": @"", @"idx": @(1)}], @[@{ @"val": @"", @"idx": @(1)}], @[@{ @"val": @"", @"idx": @(1)}], @[@{ @"val": @"", @"idx": @(1)}]]];
    BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"get"];
    if ([result succeed]) {
        NSDictionary *dic = [[result getData] toDictionary];
        NSArray *dicArray = dic[@"vals"];
        for (int j = 0; j < [dicArray count]; j++) {
            NSArray *switchTimerArray = dicArray[j];
            for (int i = 0; i < switchTimerArray.count; i++) {
                NSString *tmrtskTimer = dicArray[j][i][@"val"];
                [self.timerList addObject:tmrtskTimer];
            }
        }
        [self.timerTableView reloadData];
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
}

- (void)GetSpSwitch {
    [self dnaControlWithAction:@"get" param:@"pwr" val:nil];
}

- (void)SPSwitch {
    if ([self.switchButton.titleLabel.text isEqualToString:@"ON"]) {
        [self dnaControlWithAction:@"set" param:@"pwr" val:@"0"];
    } else {
        [self dnaControlWithAction:@"set" param:@"pwr" val:@"1"];
    }
}

- (void)addTimerBtn {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加定时" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *tmrtskAction = [UIAlertAction actionWithTitle:@"单次定时" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setParams:@[@"tmrtsk"] values:@[@[@{@"val": @"+0800@20180911-151426|1@null|0", @"idx": @(1)}]]];
        BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"set"];
        if ([result succeed]) {
            BLStdControlResult *getResult = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"get"];
            if ([getResult succeed]) {
                NSDictionary *dic = [[getResult getData] toDictionary];
                NSString *switchResult = dic[@"vals"][0][0][@"val"];
                [BLStatusBar showTipMessageWithStatus:switchResult];
            }
        } else {
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        }
    }];
    UIAlertAction *pertskAction = [UIAlertAction actionWithTitle:@"周期定时" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setParams:@[@"pertsk"] values:@[@[@{@"val": @"1|+0800-095700@null|null|0|0", @"idx": @(1)}, @{@"val": @"1|+0800-164420@null|null|0|0", @"idx": @(1)}]]];
        BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"set"];
        if ([result succeed]) {
            BLStdControlResult *getResult = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"get"];
            if ([getResult succeed]) {
                NSDictionary *dic = [[getResult getData] toDictionary];
                NSString *switchResult = dic[@"vals"][0][0][@"val"];
                [BLStatusBar showTipMessageWithStatus:switchResult];
            }
        } else {
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        }
    }];
    UIAlertAction *cyctskAction = [UIAlertAction actionWithTitle:@"循环定时" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setParams:@[@"cyctsk"] values:@[@[@{@"val": @"1|+0800-183037@183537|300|300|null", @"idx": @(1)}]]];
        BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"set"];
        if ([result succeed]) {
            BLStdControlResult *getResult = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"get"];
            if ([getResult succeed]) {
                NSDictionary *dic = [[getResult getData] toDictionary];
                NSString *switchResult = dic[@"vals"][0][0][@"val"];
                [BLStatusBar showTipMessageWithStatus:switchResult];
            }
        } else {
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        }
    }];
    UIAlertAction *randtskAction = [UIAlertAction actionWithTitle:@"防盗定时" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setParams:@[@"randtsk"] values:@[@[@{@"val": @"1|+0800-000000@235901|10|12347", @"idx": @(1)}]]];
        BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"set"];
        if ([result succeed]) {
            BLStdControlResult *getResult = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"get"];
            if ([getResult succeed]) {
                NSDictionary *dic = [[getResult getData] toDictionary];
                NSString *switchResult = dic[@"vals"][0][0][@"val"];
                [BLStatusBar showTipMessageWithStatus:switchResult];
            }
        } else {
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:tmrtskAction];
    [alertController addAction:pertskAction];
    [alertController addAction:cyctskAction];
    [alertController addAction:randtskAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)dnaControlWithAction:(NSString *)action param:(NSString *)param val:(NSString *)val {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setValue:val forParam:param];
        BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:action];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result succeed]) {
                NSDictionary *dic = [[result getData] toDictionary];
                NSString *switchResult = dic[@"vals"][0][0][@"val"];
                if ([switchResult integerValue]) {
                    [self.switchButton setTitle:@"ON" forState:UIControlStateNormal];
                } else {
                    [self.switchButton setTitle:@"OFF" forState:UIControlStateNormal];
                }
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
            }
        });
    });
}

@end
