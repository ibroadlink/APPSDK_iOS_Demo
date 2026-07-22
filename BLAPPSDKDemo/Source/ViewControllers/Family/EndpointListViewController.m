//
//  EndpointListViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/21.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "EndpointListViewController.h"
#import "EndpointDetailController.h"
#import "EndpointAddViewController.h"
#import "BLTheme.h"
#import <BLSFamily/BLSFamily.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface EndpointListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *endpointListTable;
@property (nonatomic, copy) NSArray *endpointList;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation EndpointListViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Endpoints";
    self.endpointList = @[];
    self.view.backgroundColor = [BLTheme backgroundColor];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                          target:self
                                                                                          action:@selector(addEndpointButtonClick)];

    self.endpointListTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.endpointListTable.delegate = self;
    self.endpointListTable.dataSource = self;
    self.endpointListTable.backgroundColor = [BLTheme backgroundColor];
    self.endpointListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.endpointListTable.contentInset = UIEdgeInsetsMake(0, 0, 24, 0);
    self.endpointListTable.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.endpointListTable.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.endpointListTable];
    [self.view addSubview:self.endpointListTable];
    [self.endpointListTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self setupTableHeader];
    [self setupEmptyState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getFamilyEndpoints];
}

- (void)setupTableHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Family Endpoints";
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Devices bound to this home";
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

    self.endpointListTable.tableHeaderView = header;
}

- (void)setupEmptyState {
    UILabel *empty = [[UILabel alloc] init];
    empty.text = @"No endpoints yet\nTap + to add a device";
    empty.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    empty.textColor = [BLTheme subtitleColor];
    empty.textAlignment = NSTextAlignmentCenter;
    empty.numberOfLines = 0;
    empty.hidden = YES;
    [self.view addSubview:empty];
    self.emptyLabel = empty;

    [empty mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(20);
        make.left.equalTo(self.view).offset(40);
        make.right.equalTo(self.view).offset(-40);
    }];
}

- (void)updateEmptyState {
    BOOL empty = self.endpointList.count == 0;
    self.emptyLabel.hidden = !empty;
    self.endpointListTable.hidden = empty;
}

- (void)addEndpointButtonClick {
    EndpointAddViewController *vc = [EndpointAddViewController viewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)getFamilyEndpoints {
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
    [self showIndicatorOnWindow];

    [manager getEndpointsWithCompletionHandler:^(BLSQueryEndpointsResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];

            if ([result succeed]) {
                self.endpointList = result.endpoints;
                for (BLSEndpointInfo *info in self.endpointList) {
                    BLDNADevice *device = [info toDNADevice];
                    [[BLLet sharedLet].controller addDevice:device];
                }

                [self.endpointListTable reloadData];
                [self updateEmptyState];
            } else {
                [self showErrorCode:result.status msg:result.msg];
                [self updateEmptyState];
            }
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.endpointList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ENDPOINT_CARD_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView *card;
    UIImageView *icon;
    UILabel *nameLabel;
    UILabel *endpointIdLabel;
    UILabel *productLabel;

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        card = [[UIView alloc] init];
        card.tag = 200;
        [BLTheme styleCardView:card];
        [cell.contentView addSubview:card];

        UIView *iconBg = [[UIView alloc] init];
        iconBg.backgroundColor = [BLTheme primaryLightColor];
        iconBg.layer.cornerRadius = 16;
        iconBg.tag = 210;
        [card addSubview:iconBg];

        icon = [[UIImageView alloc] init];
        icon.tag = 211;
        icon.contentMode = UIViewContentModeScaleAspectFit;
        [iconBg addSubview:icon];

        nameLabel = [[UILabel alloc] init];
        nameLabel.tag = 201;
        nameLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        nameLabel.textColor = [BLTheme titleColor];
        [card addSubview:nameLabel];

        endpointIdLabel = [[UILabel alloc] init];
        endpointIdLabel.tag = 202;
        endpointIdLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        endpointIdLabel.textColor = [BLTheme subtitleColor];
        endpointIdLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [card addSubview:endpointIdLabel];

        productLabel = [[UILabel alloc] init];
        productLabel.tag = 203;
        productLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        productLabel.textColor = [BLTheme primaryColor];
        [card addSubview:productLabel];

        UIImageView *chevron = [[UIImageView alloc] init];
        chevron.tintColor = [BLTheme subtitleColor];
        if (@available(iOS 13.0, *)) {
            chevron.image = [UIImage systemImageNamed:@"chevron.right"];
        }
        [card addSubview:chevron];

        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView).offset(6);
            make.bottom.equalTo(cell.contentView).offset(-6);
            make.left.equalTo(cell.contentView).offset(16);
            make.right.equalTo(cell.contentView).offset(-16);
        }];
        [iconBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(card).offset(14);
            make.centerY.equalTo(card);
            make.width.height.mas_equalTo(52);
        }];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(iconBg).insets(UIEdgeInsetsMake(8, 8, 8, 8));
        }];
        [chevron mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(card).offset(-14);
            make.centerY.equalTo(card);
            make.width.mas_equalTo(10);
            make.height.mas_equalTo(14);
        }];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconBg.mas_right).offset(12);
            make.top.equalTo(iconBg).offset(4);
            make.right.equalTo(chevron.mas_left).offset(-8);
        }];
        [endpointIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(nameLabel);
            make.top.equalTo(nameLabel.mas_bottom).offset(4);
        }];
        [productLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(nameLabel);
            make.top.equalTo(endpointIdLabel.mas_bottom).offset(2);
        }];
    } else {
        card = [cell.contentView viewWithTag:200];
        icon = (UIImageView *)[card viewWithTag:211];
        nameLabel = (UILabel *)[card viewWithTag:201];
        endpointIdLabel = (UILabel *)[card viewWithTag:202];
        productLabel = (UILabel *)[card viewWithTag:203];
    }

    BLSEndpointInfo *info = self.endpointList[indexPath.row];
    nameLabel.text = info.friendlyName.length ? info.friendlyName : @"Unnamed Endpoint";
    endpointIdLabel.text = info.endpointId ?: @"--";
    productLabel.text = [NSString stringWithFormat:@"PID %@", info.productId ?: @"--"];
    [icon sd_setImageWithURL:[NSURL URLWithString:info.icon]
            placeholderImage:[UIImage imageNamed:@"default_module_icon"]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLSEndpointInfo *info = self.endpointList[indexPath.row];
    EndpointDetailController *vc = [EndpointDetailController viewController];
    vc.isNeedDeviceControl = YES;
    vc.endpoint = info;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
