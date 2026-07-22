//
//  TVBoxAreaSelectController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "TVBoxAreaSelectController.h"
#import "CateGoriesTableViewController.h"
#import "IRCodeLocationInfo.h"

#import "BLStatusBar.h"
#import "BLTheme.h"
#import <BLLetIRCode/BLLetIRCode.h>
#import <Masonry/Masonry.h>

@interface TVBoxAreaSelectController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *areasTable;
@property (strong, nonatomic) NSMutableArray *locationInfos;
@property (strong, nonatomic) NSMutableArray *areaInfos;
@property (assign, nonatomic) NSUInteger step;
@property (strong, nonatomic) IRCodeLocationInfo *currentLocation;

@end

@implementation TVBoxAreaSelectController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Please Select Country";
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.locationInfos = [NSMutableArray arrayWithCapacity:0];
    self.areaInfos = [NSMutableArray arrayWithCapacity:0];
    self.currentLocation = [IRCodeLocationInfo new];

    self.areasTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.areasTable.delegate = self;
    self.areasTable.dataSource = self;
    self.areasTable.backgroundColor = [BLTheme backgroundColor];
    self.areasTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.areasTable.contentInset = UIEdgeInsetsMake(0, 0, 24, 0);
    self.areasTable.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.areasTable.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.areasTable];
    [self.view addSubview:self.areasTable];
    [self.areasTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [self setupTableHeader];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryAllLocations];
}

- (void)setupTableHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"TV Box Area";
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Select country, province and city for STB codes";
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

    self.areasTable.tableHeaderView = header;
}

- (void)queryAllLocations {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLIRCode *blircode = [BLIRCode sharedIrdaCode];

        [blircode getLocateListCompletionHandler:^(BLLocateInfoResult * _Nonnull result) {
            if ([result succeed]) {
                [self.locationInfos removeAllObjects];
                [self.locationInfos addObjectsFromArray:result.data];

                [self.areaInfos removeAllObjects];
                [self.areaInfos addObjectsFromArray:self.locationInfos];

                self.step = 0;
            } else {
                [BLStatusBar showTipMessageWithStatus:result.msg];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.areasTable reloadData];
                self.title = @"Please Select Country";
            });
        }];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.areaInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"TV_BOX_AREA_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    UIView *card;
    UILabel *titleLabel;
    UILabel *detailLabel;

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        card = [[UIView alloc] init];
        card.tag = 200;
        [BLTheme styleCardView:card];
        [cell.contentView addSubview:card];

        titleLabel = [[UILabel alloc] init];
        titleLabel.tag = 201;
        titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        titleLabel.textColor = [BLTheme titleColor];
        [card addSubview:titleLabel];

        detailLabel = [[UILabel alloc] init];
        detailLabel.tag = 202;
        detailLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        detailLabel.textColor = [BLTheme subtitleColor];
        [card addSubview:detailLabel];

        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView).offset(6);
            make.bottom.equalTo(cell.contentView).offset(-6);
            make.left.equalTo(cell.contentView).offset(16);
            make.right.equalTo(cell.contentView).offset(-16);
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(card).offset(14);
            make.top.equalTo(card).offset(14);
            make.right.equalTo(card).offset(-14);
        }];
        [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(titleLabel);
            make.top.equalTo(titleLabel.mas_bottom).offset(4);
        }];
    } else {
        card = [cell.contentView viewWithTag:200];
        titleLabel = (UILabel *)[card viewWithTag:201];
        detailLabel = (UILabel *)[card viewWithTag:202];
    }

    if (self.step == 0) {
        BLDatum *info = self.areaInfos[indexPath.row];
        titleLabel.text = info.country;
        detailLabel.text = [NSString stringWithFormat:@"code : %@", info.code];
    } else if (self.step == 1) {
        BLChild *info = self.areaInfos[indexPath.row];
        titleLabel.text = info.province;
        detailLabel.text = [NSString stringWithFormat:@"code : %@", info.code];
    } else if (self.step == 2) {
        BLSubchild *info = self.areaInfos[indexPath.row];
        titleLabel.text = info.city;
        detailLabel.text = [NSString stringWithFormat:@"code : %@", info.code];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.step == 0) {
        BLDatum *info = self.areaInfos[indexPath.row];
        self.currentLocation.country = info.country;
        self.currentLocation.countryCode = info.code;

        [self.areaInfos removeAllObjects];
        [self.areaInfos addObjectsFromArray:info.children];
        self.step++;

        self.title = @"Please Select Province";
        [self.areasTable reloadData];
    } else if (self.step == 1) {
        BLChild *info = self.areaInfos[indexPath.row];
        self.currentLocation.province = info.province;
        self.currentLocation.provinceCode = info.code;

        [self.areaInfos removeAllObjects];
        [self.areaInfos addObjectsFromArray:info.subchildren];
        self.step++;

        self.title = @"Please Select City";
        [self.areasTable reloadData];
    } else if (self.step == 2) {
        BLSubchild *info = self.areaInfos[indexPath.row];
        self.currentLocation.city = info.city;
        self.currentLocation.cityCode = info.code;

        CateGoriesTableViewController *vc = [CateGoriesTableViewController viewController];
        vc.currentLocation = self.currentLocation;
        vc.devtype = BL_IRCODE_DEVICE_TV_BOX;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
