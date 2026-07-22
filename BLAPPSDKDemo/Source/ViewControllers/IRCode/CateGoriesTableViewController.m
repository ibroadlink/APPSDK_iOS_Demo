//
//  CateGoriesTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "CateGoriesTableViewController.h"
#import "ProductModelsTableViewController.h"
#import "Tools.h"

#import "BLStatusBar.h"
#import "BLTheme.h"
#import <BLLetIRCode/BLLetIRCode.h>
#import <Masonry/Masonry.h>

@interface CateGoriesTableViewController ()

@property (nonatomic, strong) BLIRCode *blircode;
@property (nonatomic, strong) NSMutableArray *brandInfos;

@end

@implementation CateGoriesTableViewController

+ (instancetype)viewController {
    return [[self alloc] initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Brands";
    self.brandInfos = [NSMutableArray arrayWithCapacity:0];
    self.blircode = [BLIRCode sharedIrdaCode];

    self.view.backgroundColor = [BLTheme backgroundColor];
    self.tableView.backgroundColor = [BLTheme backgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 24, 0);
    self.tableView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self bl_hideExtraCellLinesOnTableView:self.tableView];
    [self setupTableHeader];
}

- (void)bl_hideExtraCellLinesOnTableView:(UITableView *)tableView {
    UIView *footer = [UIView new];
    footer.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = footer;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self queryDeviceTypes];
    });
}

- (void)setupTableHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Select Brand";
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Choose a brand or provider to browse IR models";
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

- (void)queryDeviceTypes {
    if (self.devtype == BL_IRCODE_DEVICE_AC || self.devtype == BL_IRCODE_DEVICE_TV) {
        [self queryIRCodeBrands];
    } else if (self.devtype == BL_IRCODE_DEVICE_TV_BOX) {
        [self querySTBProvider_V3];
    }
}

- (void)queryIRCodeBrands {
    [self.blircode requestIRCodeDeviceBrandsWithType:self.devtype completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        if ([result succeed]) {
            [self.brandInfos removeAllObjects];

            if (result.respbody) {
                NSArray *brands = result.respbody[@"brand"];
                if (![BLCommonTools isEmptyArray:brands]) {
                    for (NSDictionary *dic in brands) {
                        IRCodeBrandInfo *info = [IRCodeBrandInfo BLS_modelWithDictionary:dic];
                        [self.brandInfos addObject:info];
                    }
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showErrorCode:result.error msg:result.msg];
            });
        }
    }];
}

- (void)querySTBProvider_V3 {
    [self.blircode requestV3STBProviderWithCountrycode:self.currentLocation.countryCode provincecode:self.currentLocation.provinceCode citycode:self.currentLocation.cityCode completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        if ([result succeed]) {
            [self.brandInfos removeAllObjects];

            if (result.respbody) {
                NSArray *providers = result.respbody[@"providerinfo"];

                if (![BLCommonTools isEmptyArray:providers]) {
                    for (NSDictionary *dic in providers) {
                        IRCodeProviderInfo *info = [IRCodeProviderInfo BLS_modelWithDictionary:dic];
                        [self.brandInfos addObject:info];
                    }
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showErrorCode:result.error msg:result.msg];
            });
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.brandInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"IRCODE_BRAND_CELL";
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

    if (self.devtype == BL_IRCODE_DEVICE_AC || self.devtype == BL_IRCODE_DEVICE_TV) {
        IRCodeBrandInfo *info = _brandInfos[indexPath.row];
        titleLabel.text = info.brand;
        detailLabel.text = [NSString stringWithFormat:@"Brand ID: %ld", (long)info.brandid];
    } else if (self.devtype == BL_IRCODE_DEVICE_TV_BOX) {
        IRCodeProviderInfo *info = _brandInfos[indexPath.row];
        titleLabel.text = info.providername;
        detailLabel.text = [NSString stringWithFormat:@"Provider ID: %ld", (long)info.providerid];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductModelsTableViewController *vc = [ProductModelsTableViewController viewController];
    vc.devtype = self.devtype;

    if (self.devtype == BL_IRCODE_DEVICE_AC || self.devtype == BL_IRCODE_DEVICE_TV) {
        vc.brandInfo = self.brandInfos[indexPath.row];
    } else if (self.devtype == BL_IRCODE_DEVICE_TV_BOX) {
        IRCodeProviderInfo *provider = self.brandInfos[indexPath.row];
        vc.provider = provider;
    }

    [self.navigationController pushViewController:vc animated:YES];
}

@end
