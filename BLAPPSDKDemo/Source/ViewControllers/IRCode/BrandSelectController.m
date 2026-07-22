//
//  BrandSelectController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/4/3.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BrandSelectController.h"
#import "MatchTreeController.h"

#import "BLStatusBar.h"
#import "BLTheme.h"
#import "IRCodeBrandInfo.h"
#import "BLDeviceService.h"
#import <BLLetIRCode/BLLetIRCode.h>
#import <Masonry/Masonry.h>

@interface BrandSelectController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *ircodeBrandTable;
@property (strong, nonatomic) NSMutableArray *brandInfos;

@end

@implementation BrandSelectController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Brands";
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.brandInfos = [NSMutableArray arrayWithCapacity:0];

    self.ircodeBrandTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.ircodeBrandTable.delegate = self;
    self.ircodeBrandTable.dataSource = self;
    self.ircodeBrandTable.backgroundColor = [BLTheme backgroundColor];
    self.ircodeBrandTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.ircodeBrandTable.contentInset = UIEdgeInsetsMake(0, 0, 24, 0);
    self.ircodeBrandTable.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.ircodeBrandTable.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.ircodeBrandTable];
    [self.view addSubview:self.ircodeBrandTable];
    [self.ircodeBrandTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [self setupTableHeader];

    if (self.devtype == BL_IRCODE_DEVICE_TV_BOX) {
        [self querySTBBrandInfos];
    } else {
        [self queryTVBrandInfos];
    }
}

- (void)setupTableHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Match Tree Brands";
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Select a brand, then choose an RM device";
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

    self.ircodeBrandTable.tableHeaderView = header;
}

- (void)queryTVBrandInfos {
    BLIRCode *ircode = [BLIRCode sharedIrdaCode];

    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ircode requestIRCodeDeviceBrandsWithType:self.devtype completionHandler:^(BLBaseBodyResult * _Nonnull result) {
            [self handleBrandQueryResult:result];
        }];
    });
}

- (void)querySTBBrandInfos {
    BLIRCode *ircode = [BLIRCode sharedIrdaCode];

    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ircode requestSTBBrandsWithCompletionHandler:^(BLBaseBodyResult * _Nonnull result) {
            [self handleBrandQueryResult:result];
        }];
    });
}

- (void)handleBrandQueryResult:(BLBaseBodyResult *)result {
    if ([result succeed]) {
        [self.brandInfos removeAllObjects];
        NSArray *brands = result.respbody[@"brand"];
        for (NSDictionary *dictionary in brands) {
            [self.brandInfos addObject:[IRCodeBrandInfo BLS_modelWithDictionary:dictionary]];
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideIndicatorOnWindow];
        if ([result succeed]) {
            [self.ircodeBrandTable reloadData];
        } else {
            [self showErrorCode:result.error msg:result.msg];
        }
    });
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

    IRCodeBrandInfo *info = self.brandInfos[indexPath.row];
    titleLabel.text = info.brand;
    detailLabel.text = [NSString stringWithFormat:@"Brand ID: %ld", (long)info.brandid];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IRCodeBrandInfo *info = self.brandInfos[indexPath.row];
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];

    if (deviceService.manageDevices.count > 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Selection" message:@"Please RM Device" preferredStyle:UIAlertControllerStyleActionSheet];

        [deviceService.manageDevices enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull did, BLDNADevice * _Nonnull dev, BOOL * _Nonnull stop) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:did style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                MatchTreeController *vc = [MatchTreeController viewController];
                vc.devtype = self.devtype;
                vc.device = dev;
                vc.brand = info;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            [alertController addAction:action];
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];

        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [BLStatusBar showTipMessageWithStatus:@"Please add device into sdk first!"];
    }
}

@end
