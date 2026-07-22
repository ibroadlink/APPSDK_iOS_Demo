//
//  ProductListViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/25.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "ProductListViewController.h"
#import "AppDelegate.h"
#import <BLLetAccount/BLLetAccount.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import "BLProductCategoryList.h"
#import "BLProductCategoryModel.h"
#import "BLDeviceConfigureInfo.h"
#import "BLConfigureStartViewController.h"
#import "BLAddDeviceListViewController.h"
#import "BLTheme.h"
#import "BLUserDefaults.h"
#import "BLStatusBar.h"
#import "Tools.h"

static NSString * const kProductSectionHeaderId = @"ProductSectionHeader";
static NSString * const kDeviceCellId = @"deviceCell";
static NSString * const kCategoryCellId = @"categoryCell";

@interface ProductListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong, readwrite) NSArray<BLProductCategoryModel *> *categoryArray;
@property (nonatomic, strong, readwrite) NSArray<BLDeviceConfigureInfo *> *hotDeviceArray;
@property (nonatomic, strong) UILabel *emptyLabel;
@end

@implementation ProductListViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewInit];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getProductCategoryList];
}

- (void)viewInit {
    self.title = @"Product";
    self.view.backgroundColor = [BLTheme backgroundColor];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 12;
    flowLayout.minimumLineSpacing = 12;
    flowLayout.sectionInset = UIEdgeInsetsMake(8, 16, 20, 16);
    flowLayout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 44);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [BLTheme backgroundColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(4, 0, 24, 0);
    [self.view addSubview:self.collectionView];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kDeviceCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCategoryCellId];
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kProductSectionHeaderId];

    [self setupEmptyState];
}

- (void)setupEmptyState {
    UILabel *empty = [[UILabel alloc] init];
    empty.text = @"No products yet\nPull to refresh after login";
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
    BOOL empty = self.hotDeviceArray.count == 0 && self.categoryArray.count == 0;
    self.emptyLabel.hidden = !empty;
}

- (CGFloat)itemWidth {
    CGFloat inset = 16;
    CGFloat spacing = 12;
    NSInteger columns = 3;
    CGFloat total = self.collectionView.bounds.size.width - inset * 2 - spacing * (columns - 1);
    return floor(total / columns);
}

- (void)ensureProductCellContent:(UICollectionViewCell *)cell categoryStyle:(BOOL)categoryStyle {
    if ([cell.contentView viewWithTag:101]) {
        return;
    }

    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.tag = 101;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:imageView];

    UILabel *label = [[UILabel alloc] init];
    label.tag = 102;
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:label];

    CGFloat iconSize = categoryStyle ? 30 : 50;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(cell.contentView);
        make.top.equalTo(cell.contentView).offset(categoryStyle ? 18 : 16);
        make.width.height.mas_equalTo(iconSize);
    }];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(10);
        make.left.equalTo(cell.contentView).offset(5);
        make.right.equalTo(cell.contentView).offset(-5);
        make.bottom.lessThanOrEqualTo(cell.contentView).offset(-10);
    }];
}

#pragma mark - Navigation

- (void)pushConfigureStartWithModel:(BLDeviceConfigureInfo *)model {
    BLConfigureStartViewController *vc = [[BLConfigureStartViewController alloc] init];
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushAddDeviceListWithModel:(BLProductCategoryModel *)model {
    BLAddDeviceListViewController *vc = [BLAddDeviceListViewController viewController];
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Network

- (void)getProductCategoryList {
    BLAccount *account = [BLAccount sharedAccount];
    NSString *userId = account.loginUserid;
    if (userId.length == 0) {
        userId = [[BLUserDefaults shareUserDefaults] getUserId];
    }
    if (userId.length == 0) {
        [BLStatusBar showTipMessageWithStatus:@"Please login first!!!"];
        return;
    }

    NSDictionary *headers = @{@"countryCode": @"1",
                              @"userid": userId};
    NSDictionary *parameters = @{ @"brandid": @"",
                                  @"protocols": @[]};
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:@"/ec4/v1/system/resource/categorylist"];

    [self showIndicatorOnWindow];

    [Tools postJSONToURL:url head:headers data:parameters timeout:[BLConfigParam sharedConfigParam].httpTimeout completionHandler:^(NSData *data, NSError *error) {
        if (data) {
            BLProductCategoryList *productCategoryList = [BLProductCategoryList BLS_modelWithJSON:data];
            self.categoryArray = productCategoryList.categorylist ?: @[];
            self.hotDeviceArray = productCategoryList.hotproducts ?: @[];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [self.collectionView reloadData];
            [self updateEmptyState];
        });
    }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        BLDeviceConfigureInfo *model = self.hotDeviceArray[indexPath.row];
        [self pushConfigureStartWithModel:model];
    } else {
        BLProductCategoryModel *model = self.categoryArray[indexPath.row];
        [self pushAddDeviceListWithModel:model];
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL categorySection = indexPath.section != 0;
    NSString *reuseId = categorySection ? kCategoryCellId : kDeviceCellId;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    [self ensureProductCellContent:cell categoryStyle:categorySection];

    NSString *title = nil;
    NSString *iconURL = nil;

    if (!categorySection) {
        BLDeviceConfigureInfo *model = self.hotDeviceArray[indexPath.row];
        title = model.moduleName;
        iconURL = model.iconUrlString;
    } else {
        BLProductCategoryModel *model = self.categoryArray[indexPath.row];
        title = model.name;
        iconURL = model.link;
    }

    [self styleProductCell:cell title:title iconURL:iconURL];
    return cell;
}

- (void)styleProductCell:(UICollectionViewCell *)cell title:(NSString *)title iconURL:(NSString *)iconURL {
    cell.backgroundColor = [BLTheme cardColor];
    cell.layer.cornerRadius = [BLTheme cardCornerRadius];
    cell.layer.masksToBounds = NO;
    cell.clipsToBounds = NO;
    cell.layer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
    cell.layer.shadowOpacity = 0.06;
    cell.layer.shadowRadius = 8;
    cell.layer.shadowOffset = CGSizeMake(0, 3);
    cell.contentView.layer.cornerRadius = [BLTheme cardCornerRadius];
    cell.contentView.layer.masksToBounds = YES;
    cell.contentView.backgroundColor = [BLTheme cardColor];

    UIImageView *imageView = [cell.contentView viewWithTag:101];
    UILabel *label = [cell.contentView viewWithTag:102];

    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [BLTheme primaryLightColor];
    imageView.layer.cornerRadius = 14;
    imageView.layer.masksToBounds = YES;
    [imageView sd_setImageWithURL:[NSURL URLWithString:iconURL]
                 placeholderImage:[UIImage imageNamed:@"default_module_icon"]];

    label.text = title;
    label.textColor = [BLTheme titleColor];
    label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.hotDeviceArray.count;
    }
    return self.categoryArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = [self itemWidth];
    return CGSizeMake(width, width + 8);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    NSInteger count = (section == 0) ? self.hotDeviceArray.count : self.categoryArray.count;
    if (count == 0) {
        return CGSizeZero;
    }
    return CGSizeMake(collectionView.bounds.size.width, 48);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (![kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [[UICollectionReusableView alloc] init];
    }

    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                          withReuseIdentifier:kProductSectionHeaderId
                                                                                 forIndexPath:indexPath];
    for (UIView *sub in header.subviews) {
        [sub removeFromSuperview];
    }
    header.backgroundColor = [UIColor clearColor];

    UIView *accent = [[UIView alloc] init];
    accent.backgroundColor = [BLTheme primaryColor];
    accent.layer.cornerRadius = 2;
    [header addSubview:accent];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    titleLabel.text = (indexPath.section == 0) ? @"Popular Devices" : @"Categories";
    [header addSubview:titleLabel];

    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    countLabel.textColor = [BLTheme subtitleColor];
    NSInteger count = (indexPath.section == 0) ? self.hotDeviceArray.count : self.categoryArray.count;
    countLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    [header addSubview:countLabel];

    [accent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(header).offset(16);
        make.centerY.equalTo(header);
        make.width.mas_equalTo(4);
        make.height.mas_equalTo(16);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(accent.mas_right).offset(10);
        make.centerY.equalTo(header);
        make.right.lessThanOrEqualTo(countLabel.mas_left).offset(-8);
    }];
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(header).offset(-16);
        make.centerY.equalTo(header);
    }];
    [countLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    return header;
}

@end
