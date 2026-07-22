//
//  RMSubDeviceTableViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/11/5.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import "RMSubDeviceTableViewController.h"
#import <BLLetIRCode/BLLetIRCode.h>
#import "BLStatusBar.h"
#import "BLTheme.h"
#import <Masonry/Masonry.h>

@interface RMSubDeviceTableViewController ()

@property (nonatomic, strong) NSArray *testList;

@end

@implementation RMSubDeviceTableViewController

+ (instancetype)viewController {
    return [[self alloc] initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"RM Sub Device";
    self.testList = @[
        @"queryAcStatus",
        @"queryAcIRCode",
        @"bindAcIRCode",
        @"queryIRCodeList",
        @"queryIRCodeFunction",
        @"createIRCodeList",
        @"updateIRCodeFunction",
        @"delIRCodeList",
    ];

    self.view.backgroundColor = [BLTheme backgroundColor];
    self.tableView.backgroundColor = [BLTheme backgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 24, 0);
    self.tableView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    UIView *footer = [UIView new];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    [self setupTableHeader];
}

- (void)setupTableHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"IR Code Management";
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"RM sub-device IR code API smoke tests";
    subtitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [BLTheme subtitleColor];
    subtitleLabel.numberOfLines = 2;
    [header addSubview:subtitleLabel];

    UIView *accent = [[UIView alloc] init];
    accent.backgroundColor = [BLTheme primaryColor];
    accent.layer.cornerRadius = 2;
    [header addSubview:accent];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(header).offset(12);
        make.left.equalTo(header).offset(20);
        make.right.equalTo(header).offset(-20);
    }];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(4);
        make.left.right.equalTo(titleLabel);
    }];
    [accent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subtitleLabel.mas_bottom).offset(12);
        make.left.equalTo(titleLabel);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(3);
        make.bottom.equalTo(header).offset(-8);
    }];

    self.tableView.tableHeaderView = header;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"IRCODETESTCELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView *card;
    UILabel *titleLabel;

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        card = [[UIView alloc] init];
        card.tag = 200;
        [BLTheme styleCardView:card];
        [cell.contentView addSubview:card];

        titleLabel = [[UILabel alloc] init];
        titleLabel.tag = 201;
        titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        titleLabel.textColor = [BLTheme titleColor];
        [card addSubview:titleLabel];

        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView).offset(4);
            make.bottom.equalTo(cell.contentView).offset(-4);
            make.left.equalTo(cell.contentView).offset(16);
            make.right.equalTo(cell.contentView).offset(-16);
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(card).offset(14);
            make.right.equalTo(card).offset(-14);
            make.centerY.equalTo(card);
        }];
    } else {
        card = [cell.contentView viewWithTag:200];
        titleLabel = (UILabel *)[card viewWithTag:201];
    }

    titleLabel.text = self.testList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: [self queryAcStatus]; break;
        case 1: [self queryAcIRCode]; break;
        case 2: [self bindAcIRCode]; break;
        case 3: [self queryIRCodeList]; break;
        case 4: [self queryIRCodeFunction]; break;
        case 5: [self createIRCodeList]; break;
        case 6: [self updateIRCodeFunction]; break;
        case 7: [self delIRCodeList]; break;
        default: break;
    }
}

- (void)queryAcStatus {
    NSDictionary *paramDic = @{ @"did": @"00000000000000000000780f77757c81" };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *result = [[BLIRCode sharedIrdaCode] queryAcStatus:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

- (void)queryAcIRCode {
    NSDictionary *paramDic = @{
        @"did": @"00000000000000000000780f77757c81",
        @"power": @1,
        @"temp": @28,
        @"mode": @1,
        @"wind_speed": @0,
        @"wdirect": @0,
        @"key": @1,
        @"freq": @38,
    };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *result = [[BLIRCode sharedIrdaCode] queryAcIRCode:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

- (void)bindAcIRCode {
    NSDictionary *paramDic = @{
        @"did": @"00000000000000000000780f77757c81",
        @"codeUrl": @"https://d0f94faa04c63d9b7b0b034dcf895656rccode.ibroadlink.com/publicircode/v2/app/getfuncfilebyfixedid?fixedid=32273768&mkey=a887d345&mtag=gz",
        @"brandId": @"1619",
    };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *result = [[BLIRCode sharedIrdaCode] bindAcIRCode:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

- (void)queryIRCodeList {
    NSDictionary *paramDic = @{ @"did": @"00000000000000000000780f77757c81" };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *result = [[BLIRCode sharedIrdaCode] queryIRCodeList:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

- (void)queryIRCodeFunction {
    NSDictionary *paramDic = @{
        @"did": @"00000000000000000000780f77757c81",
        @"function": @"power",
    };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *result = [[BLIRCode sharedIrdaCode] queryIRCodeFunction:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

- (void)createIRCodeList {
    NSDictionary *paramDic = @{
        @"did": @"00000000000000000000780f77757c81",
        @"irInfo": @{
            @"irId": @"303865",
            @"brandId": @"天龙",
            @"provinceId": @"浙江",
            @"cityId": @"杭州",
            @"providerId": @"123",
            @"source": @"官方",
        },
        @"irDataList": @[@{
            @"code": @"3700380000027d7c123e123e123e123e121d121d123e121d123e121d123e121d121d121d121d121d123e123e121d123e121d123e121d123e1200051f",
            @"icon": @"ttianlong.png",
            @"name": @"名称",
            @"function": @"power",
        }],
    };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *result = [[BLIRCode sharedIrdaCode] createIRCodeList:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

- (void)updateIRCodeFunction {
    NSDictionary *paramDic = @{
        @"did": @"00000000000000000000780f77757c81",
        @"irDataList": @[@{
            @"code": @"260058000001269413111313121114111",
            @"icon": @"xxxxxxxxxxxxxx",
            @"name": @"名称",
            @"function": @"power",
        }],
    };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *result = [[BLIRCode sharedIrdaCode] updateIRCodeFunction:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

- (void)delIRCodeList {
    NSDictionary *paramDic = @{
        @"did": @"00000000000000000000780f77757c81",
        @"functionList": @[@"power"],
    };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *result = [[BLIRCode sharedIrdaCode] delIRCodeList:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

@end
