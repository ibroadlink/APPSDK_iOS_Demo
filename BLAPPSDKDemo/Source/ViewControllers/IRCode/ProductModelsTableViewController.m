//
//  ProductModelsTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "ProductModelsTableViewController.h"
#import "RecoginzeIRCodeViewController.h"

#import "BLStatusBar.h"
#import "BLTheme.h"
#import <BLLetIRCode/BLLetIRCode.h>
#import <Masonry/Masonry.h>

@interface ProductModelsTableViewController ()

@property (nonatomic, strong) BLIRCode *blircode;
@property (nonatomic, strong) NSMutableArray *modelsArray;

@end

@implementation ProductModelsTableViewController

+ (instancetype)viewController {
    return [[self alloc] initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Models";
    self.modelsArray = [NSMutableArray arrayWithCapacity:0];
    self.blircode = [BLIRCode sharedIrdaCode];

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

    if (self.devtype == BL_IRCODE_DEVICE_AC || self.devtype == BL_IRCODE_DEVICE_TV) {
        [self queryDeviceVersionWithTypeId:self.devtype brandId:self.brandInfo.brandid];
    } else if (self.devtype == BL_IRCODE_DEVICE_TV_BOX) {
        [self querySTBIRCodeDownloadUrl:self.provider];
    }
}

- (void)setupTableHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"IR Models";
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Select a model to download and test IR codes";
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

- (void)queryDeviceVersionWithTypeId:(NSInteger)typeId brandId:(NSInteger)brandId {
    [self.blircode requestIRCodeScriptDownloadUrlWithType:typeId brand:brandId version:0 completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        if ([result succeed]) {
            [self.modelsArray removeAllObjects];

            if (result.respbody) {
                NSArray *downloadInfos = result.respbody[@"downloadinfo"];

                if (![BLCommonTools isEmptyArray:downloadInfos]) {
                    for (NSDictionary *pdic in downloadInfos) {
                        IRCodeDownloadInfo *downloadinfo = [IRCodeDownloadInfo BLS_modelWithDictionary:pdic];
                        [self.modelsArray addObject:downloadinfo];
                    }
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [BLStatusBar showTipMessageWithStatus:result.msg];
            });
        }
    }];
}

- (void)querySTBIRCodeDownloadUrl:(IRCodeProviderInfo *)provider {
    [self.blircode requestSTBIRCodeScriptDownloadUrlWithLocateid:provider.locateid providerid:provider.providerid brandId:0 completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        [self.modelsArray removeAllObjects];
        if ([result succeed]) {
            if (result.respbody) {
                NSArray *downloadInfos = result.respbody[@"downloadinfo"];
                if (![BLCommonTools isEmptyArray:downloadInfos]) {
                    for (NSDictionary *pdic in downloadInfos) {
                        IRCodeDownloadInfo *downloadinfo = [IRCodeDownloadInfo BLS_modelWithDictionary:pdic];
                        [self.modelsArray addObject:downloadinfo];
                    }
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [BLStatusBar showTipMessageWithStatus:result.msg];
            });
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"SELECT_MODEL_CELL";
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
        detailLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
        detailLabel.textColor = [BLTheme subtitleColor];
        detailLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
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

    self.downloadinfo = _modelsArray[indexPath.row];
    titleLabel.text = self.downloadinfo.name;
    detailLabel.text = self.downloadinfo.downloadurl;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IRCodeDownloadInfo *downloadinfo = self.modelsArray[indexPath.row];
    downloadinfo.devtype = self.devtype;

    RecoginzeIRCodeViewController *vc = [RecoginzeIRCodeViewController viewController];
    vc.downloadinfo = downloadinfo;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
