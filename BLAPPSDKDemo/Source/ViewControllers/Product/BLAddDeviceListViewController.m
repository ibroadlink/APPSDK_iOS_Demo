//
//  BLAddDeviceListViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/27.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLAddDeviceListViewController.h"
#import "AppDelegate.h"
#import "BLProductCategoryList.h"
#import "BLDeviceConfigureInfo.h"
#import "BLConfigureStartViewController.h"
#import "BLUserDefaults.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import <BLLetAccount/BLLetAccount.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import "Tools.h"

@interface BLAddDeviceListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *productCategoryList;
@property (nonatomic, strong) UILabel *emptyLabel;
@end

@implementation BLAddDeviceListViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.model.name.length > 0 ? self.model.name : @"Products";
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.productCategoryList = @[];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [BLTheme backgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 24, 0);
    self.tableView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self setupEmptyState];
    [self getProductList:self.model.categoryid];
}

- (void)setupEmptyState {
    UILabel *empty = [[UILabel alloc] init];
    empty.text = @"No products in this category";
    empty.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    empty.textColor = [BLTheme subtitleColor];
    empty.textAlignment = NSTextAlignmentCenter;
    empty.numberOfLines = 0;
    empty.hidden = YES;
    [self.view addSubview:empty];
    self.emptyLabel = empty;

    [empty mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.left.equalTo(self.view).offset(40);
        make.right.equalTo(self.view).offset(-40);
    }];
}

- (void)updateEmptyState {
    BOOL empty = self.productCategoryList.count == 0;
    self.emptyLabel.hidden = !empty;
}

- (void)getProductList:(NSString *)categoryid {
    BLAccount *account = [BLAccount sharedAccount];
    NSString *userId = account.loginUserid;
    if (userId.length == 0) {
        userId = [[BLUserDefaults shareUserDefaults] getUserId];
    }
    if (userId.length == 0) {
        [BLStatusBar showTipMessageWithStatus:@"Please login first!!!"];
        return;
    }
    if (categoryid.length == 0) {
        categoryid = @"";
    }
    NSDictionary *headers = @{
                              @"countryCode": @"1",
                              @"userid": userId};
    NSDictionary *parameters = @{ @"brandid": @"",
                                  @"protocols": @[],
                                  @"categoryid": categoryid
                                  };
    NSString *url = [NSString stringWithFormat:@"https://%@bizappmanage.ibroadlink.com/ec4/v1/system/resource/productlist",[BLConfigParam sharedConfigParam].licenseId];

    [Tools postJSONToURL:url head:headers data:parameters timeout:[BLConfigParam sharedConfigParam].httpTimeout completionHandler:^(NSData *data, NSError *error) {
        if (data) {
            BLProductCategoryList *productCategoryList = [BLProductCategoryList BLS_modelWithJSON:data];
            self.productCategoryList = productCategoryList.productlist ?: @[];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self updateEmptyState];
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.productCategoryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"addDeviceListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView *card;
    UIImageView *imageView;
    UILabel *moduleName;
    UILabel *deviceName;

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        card = [[UIView alloc] init];
        card.tag = 200;
        [BLTheme styleCardView:card];
        [cell.contentView addSubview:card];

        imageView = [[UIImageView alloc] init];
        imageView.tag = 100;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [BLTheme primaryLightColor];
        imageView.layer.cornerRadius = 10;
        imageView.layer.masksToBounds = YES;
        [card addSubview:imageView];

        moduleName = [[UILabel alloc] init];
        moduleName.tag = 101;
        moduleName.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        moduleName.textColor = [BLTheme titleColor];
        [card addSubview:moduleName];

        deviceName = [[UILabel alloc] init];
        deviceName.tag = 102;
        deviceName.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        deviceName.textColor = [BLTheme subtitleColor];
        [card addSubview:deviceName];

        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView).offset(6);
            make.left.equalTo(cell.contentView).offset(16);
            make.right.equalTo(cell.contentView).offset(-16);
            make.bottom.equalTo(cell.contentView).offset(-6);
            make.height.mas_equalTo(72);
        }];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(card).offset(12);
            make.centerY.equalTo(card);
            make.width.mas_equalTo(56);
            make.height.mas_equalTo(40);
        }];
        [moduleName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right).offset(12);
            make.right.equalTo(card).offset(-12);
            make.top.equalTo(imageView);
        }];
        [deviceName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(moduleName);
            make.top.equalTo(moduleName.mas_bottom).offset(4);
        }];
    } else {
        card = [cell.contentView viewWithTag:200];
        imageView = (UIImageView *)[card viewWithTag:100];
        moduleName = (UILabel *)[card viewWithTag:101];
        deviceName = (UILabel *)[card viewWithTag:102];
    }

    BLDeviceConfigureInfo *model = self.productCategoryList[indexPath.row];
    [imageView sd_setImageWithURL:[NSURL URLWithString:model.iconUrlString]
                 placeholderImage:[UIImage imageNamed:@"default_module_icon"]];
    moduleName.text = model.moduleName;
    deviceName.text = [NSString stringWithFormat:@"%@ %@", model.brand, model.deviceName];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 84;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLDeviceConfigureInfo *model = self.productCategoryList[indexPath.row];
    BLConfigureStartViewController *vc = [[BLConfigureStartViewController alloc] init];
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
