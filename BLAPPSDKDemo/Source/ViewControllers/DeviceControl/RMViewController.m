//
//  RMViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/1.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "RMViewController.h"
#import <BLLetIRCode/BLLetIRCode.h>
#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import "Tools.h"
#import <Masonry/Masonry.h>

@interface RMViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) BLDNADevice *device;
@property (strong, nonatomic) NSString *irdaCodeStr;
@property (strong, nonatomic) NSString *irdaUnitCodeStr;
@property (strong, nonatomic) NSMutableArray *timerInfos;
@property (nonatomic, strong) UITextView *irdaCodeTextView;
@property (nonatomic, strong) UITableView *timerTableView;

@end

@implementation RMViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"RM Device Demo";
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    self.timerInfos = [NSMutableArray arrayWithCapacity:0];
    self.irdaCodeStr = @"26008c00959115351535153515111411141114111411143614361436141114111411141114111436143614361436141114111411141114111411141114111436153515351535150005f295921535153515351510151015101510151015351535153515101510151015101510153515351535153515101510151015101510151015101510153515351535153515000d05000000000000000000000000";
    [self buildUI];
}

- (void)buildUI {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.alwaysBounceVertical = YES;
    [self.view addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    [scroll addSubview:content];

    UIButton *learnBtn = [BLTheme makeSecondaryButtonWithTitle:@"Learn" target:self action:@selector(learnButton)];
    UIButton *getBtn = [BLTheme makeSecondaryButtonWithTitle:@"Get IR Code" target:self action:@selector(GetIrdaCode)];
    UIButton *sendBtn = [BLTheme makePrimaryButtonWithTitle:@"Send IR Code" target:self action:@selector(SendIrdaCode)];
    UIButton *waveToUnitBtn = [BLTheme makeSecondaryButtonWithTitle:@"Wave → Unit" target:self action:@selector(waveCode2UnitCode)];
    UIButton *unitToWaveBtn = [BLTheme makeSecondaryButtonWithTitle:@"Unit → Wave" target:self action:@selector(unitCode2WaveCode)];
    UIButton *timerBtn = [BLTheme makeSecondaryButtonWithTitle:@"Set Timer" target:self action:@selector(TimerBtn)];
    UIButton *queryTimerBtn = [BLTheme makeSecondaryButtonWithTitle:@"Query Timers" target:self action:@selector(queryTimer)];

    UIStackView *row1 = [[UIStackView alloc] initWithArrangedSubviews:@[learnBtn, getBtn]];
    row1.axis = UILayoutConstraintAxisHorizontal;
    row1.spacing = 10;
    row1.distribution = UIStackViewDistributionFillEqually;

    UIStackView *row2 = [[UIStackView alloc] initWithArrangedSubviews:@[sendBtn]];
    row2.axis = UILayoutConstraintAxisHorizontal;

    UIStackView *row3 = [[UIStackView alloc] initWithArrangedSubviews:@[waveToUnitBtn, unitToWaveBtn]];
    row3.axis = UILayoutConstraintAxisHorizontal;
    row3.spacing = 10;
    row3.distribution = UIStackViewDistributionFillEqually;

    UIStackView *row4 = [[UIStackView alloc] initWithArrangedSubviews:@[timerBtn, queryTimerBtn]];
    row4.axis = UILayoutConstraintAxisHorizontal;
    row4.spacing = 10;
    row4.distribution = UIStackViewDistributionFillEqually;

    UIStackView *actions = [[UIStackView alloc] initWithArrangedSubviews:@[row1, row2, row3, row4]];
    actions.axis = UILayoutConstraintAxisVertical;
    actions.spacing = 10;
    [content addSubview:actions];

    for (UIView *v in @[learnBtn, getBtn, sendBtn, waveToUnitBtn, unitToWaveBtn, timerBtn, queryTimerBtn]) {
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
        }];
    }

    self.irdaCodeTextView = [[UITextView alloc] init];
    self.irdaCodeTextView.editable = NO;
    [BLTheme styleResultTextView:self.irdaCodeTextView];
    self.irdaCodeTextView.text = self.irdaCodeStr;
    [content addSubview:self.irdaCodeTextView];

    self.timerTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.timerTableView.delegate = self;
    self.timerTableView.dataSource = self;
    self.timerTableView.backgroundColor = [BLTheme backgroundColor];
    self.timerTableView.separatorColor = [BLTheme separatorColor];
    if (@available(iOS 15.0, *)) {
        self.timerTableView.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.timerTableView];
    [content addSubview:self.timerTableView];

    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scroll);
        make.width.equalTo(scroll);
    }];
    [actions mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(12);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
    }];
    [self.irdaCodeTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(actions.mas_bottom).offset(12);
        make.left.right.equalTo(actions);
        make.height.mas_equalTo(120);
    }];
    [self.timerTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.irdaCodeTextView.mas_bottom).offset(12);
        make.left.right.equalTo(actions);
        make.height.mas_equalTo(220);
        make.bottom.equalTo(content).offset(-24);
    }];
}

#pragma mark - Actions

- (void)learnButton {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:nil forParam:@"irdastudy"];
    BLStdControlResult *studyResult = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"get"];
    if ([studyResult succeed]) {
        self.irdaCodeTextView.text = @"Learnning... Please click your remote control button!";
    } else {
        self.irdaCodeTextView.text = [NSString stringWithFormat:@"Start learn ircode failed: (%ld)%@", (long)studyResult.status, studyResult.msg];
    }
}

- (void)GetIrdaCode {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:nil forParam:@"irda"];
    BLStdControlResult *irdaResult = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"get"];
    if ([irdaResult succeed]) {
        NSDictionary *dic = [[irdaResult getData] toDictionary];
        if ([dic[@"vals"] count] != 0) {
            self.irdaCodeStr = dic[@"vals"][0][0][@"val"];
            UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
            pasteBoard.string = self.irdaCodeStr;
            [BLStatusBar showTipMessageWithStatus:@"Has been copied to the clipboard!"];
        } else {
            self.irdaCodeTextView.text = @"No ircode getted, please click again!";
        }
    } else {
        self.irdaCodeTextView.text = [NSString stringWithFormat:@"Get ircode failed: (%ld)%@", (long)irdaResult.status, irdaResult.msg];
    }
}

- (void)sendCodeWithType:(NSUInteger)type {
    BLStdData *stdData = [[BLStdData alloc] init];
    if (type == 1) {
        if ([BLCommonTools isEmpty:self.irdaUnitCodeStr]) {
            [BLStatusBar showTipMessageWithStatus:@"Please change wave code to unit code first!"];
            return;
        }
        [stdData setValue:self.irdaUnitCodeStr forParam:@"irda"];
    } else {
        [stdData setValue:self.irdaCodeStr forParam:@"irda"];
    }
    BLStdControlResult *sendResult = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"set"];
    if ([sendResult succeed]) {
        self.irdaCodeTextView.text = @"Send ircode success!";
    } else {
        self.irdaCodeTextView.text = [NSString stringWithFormat:@"Send ircode failed: (%ld)%@", (long)sendResult.status, sendResult.msg];
    }
}

- (void)SendIrdaCode {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Code chose" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Wave Code Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sendCodeWithType:0];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Unit Code Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sendCodeWithType:1];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)waveCode2UnitCode {
    BLIRCode *blircode = [BLIRCode sharedIrdaCode];
    NSString *unitCode = [blircode waveCodeChangeToUnitCode:self.irdaCodeStr];
    if (unitCode) {
        NSLog(@"unitCode:%@", unitCode);
        self.irdaUnitCodeStr = unitCode;
        self.irdaCodeTextView.text = unitCode;
    } else {
        self.irdaCodeTextView.text = @"Change Wave Code To Unit Code Failed!";
    }
}

- (void)unitCode2WaveCode {
    if (!self.irdaUnitCodeStr) {
        [BLStatusBar showTipMessageWithStatus:@"Please get unit code first!"];
        return;
    }
    BLIRCode *blircode = [BLIRCode sharedIrdaCode];
    NSString *waveCode = [blircode unitCodeChangeToWaveCode:self.irdaUnitCodeStr];
    if (waveCode) {
        NSLog(@"waveCode:%@", waveCode);
        self.irdaCodeTextView.text = [NSString stringWithFormat:@"%@\n\n%@", self.irdaCodeStr, waveCode];
    } else {
        self.irdaCodeTextView.text = @"Change Unit Code To Wave Code Failed!";
    }
}

- (void)TimerBtn {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please input timer info" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"0|1|19|30|1|openTV|2|32:100@64:500|";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *timerInfo = alertController.textFields.firstObject.text;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self setRMTimer:timerInfo];
        });
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)delTimer:(NSString *)timerInfo {
    if ([BLCommonTools isEmpty:timerInfo]) {
        [BLStatusBar showTipMessageWithStatus:@"Please input timer info"];
        return;
    }
    NSInteger index = 0;
    NSArray *infos = [timerInfo componentsSeparatedByString:@"|"];
    if (infos && infos.count > 0) {
        index = [infos[0] integerValue];
    }
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@(index) forParam:@"delrmtimer"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showIndicatorOnWindow];
    });
    BLStdControlResult *delResult = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"set"];
    if ([delResult succeed]) {
        [self queryTimerList:0];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            self.irdaCodeTextView.text = [NSString stringWithFormat:@"Set RM Timer failed: (%ld)%@", (long)delResult.status, delResult.msg];
        });
    }
}

- (void)setRMTimer:(NSString *)timerInfo {
    if ([BLCommonTools isEmpty:timerInfo]) {
        [BLStatusBar showTipMessageWithStatus:@"Please input timer info"];
        return;
    }
    NSString *value = [timerInfo stringByAppendingString:self.irdaCodeStr];
    NSLog(@"RM timer value: %@", value);
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:value forParam:@"rmtimer"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showIndicatorOnWindow];
    });
    BLStdControlResult *sendResult = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"set"];
    if ([sendResult succeed]) {
        [self queryTimerList:0];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            self.irdaCodeTextView.text = [NSString stringWithFormat:@"Set RM Timer failed: (%ld)%@", (long)sendResult.status, sendResult.msg];
        });
    }
}

- (void)queryTimerList:(NSUInteger)index {
    if (index == 0) {
        [self.timerInfos removeAllObjects];
    }
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@(0) forParam:@"rmtimer"];
    [stdData setValue:@(0) forParam:@"count"];
    [stdData setValue:@(index) forParam:@"index"];
    BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:@"get"];
    if ([result succeed]) {
        NSDictionary *dic = [result.data toDictionary];
        NSArray *vals = dic[@"vals"][0];
        if (vals.count > 0) {
            for (NSDictionary *info in vals) {
                NSString *val = info[@"val"];
                [self.timerInfos addObject:val];
            }
            NSNumber *totalvals = [result.data valueForParam:@"count"];
            NSInteger total = totalvals ? [totalvals integerValue] : 0;
            if (self.timerInfos.count < total) {
                [self queryTimerList:self.timerInfos.count];
                return;
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideIndicatorOnWindow];
        [self.timerTableView reloadData];
    });
}

- (void)queryTimer {
    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self queryTimerList:0];
    });
}

- (void)setIrdaCodeStr:(NSString *)irdaCodeStr {
    _irdaCodeStr = irdaCodeStr;
    self.irdaCodeTextView.text = irdaCodeStr;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timerInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"RM_TIMER_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        cell.textLabel.textColor = [BLTheme titleColor];
        cell.textLabel.numberOfLines = 0;
    }
    cell.textLabel.text = self.timerInfos[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *timerInfo = self.timerInfos[indexPath.row];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self delTimer:timerInfo];
        });
    }
}

@end
