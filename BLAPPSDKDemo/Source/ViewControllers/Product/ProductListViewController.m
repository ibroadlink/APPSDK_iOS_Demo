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

@interface ProductListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong, readwrite) NSArray<BLProductCategoryModel *> *categoryArray;
@property (nonatomic, strong, readwrite) NSArray<BLDeviceConfigureInfo *> *hotDeviceArray;
@property (nonatomic, strong) UILabel *emptyLabel;
@end

@implementation ProductListViewController

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
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [BLTheme backgroundColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(4, 0, 24, 0);

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 12;
    flowLayout.minimumLineSpacing = 12;
    flowLayout.sectionInset = UIEdgeInsetsMake(8, 16, 20, 16);
    flowLayout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 44);
    self.collectionView.collectionViewLayout = flowLayout;

    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kProductSectionHeaderId];

    [self setupEmptyState];
}

+ (instancetype)viewController {
    return [Tools viewControllerFromMainStoryboard:self];
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
        [self performSegueWithIdentifier:@"configStartView" sender:model];
    } else {
        BLProductCategoryModel *model = self.categoryArray[indexPath.row];
        [self performSegueWithIdentifier:@"addDeviceList" sender:model];
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    NSString *title = nil;
    NSString *iconURL = nil;

    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"deviceCell" forIndexPath:indexPath];
        BLDeviceConfigureInfo *model = self.hotDeviceArray[indexPath.row];
        title = model.moduleName;
        iconURL = model.iconUrlString;
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"categoryCell" forIndexPath:indexPath];
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

    UIImageView *imageView = [cell viewWithTag:101];
    UILabel *label = [cell viewWithTag:102];

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"configStartView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[BLConfigureStartViewController class]]) {
            BLConfigureStartViewController *vc = (BLConfigureStartViewController *)target;
            vc.model = (BLDeviceConfigureInfo *)sender;
        }
    } else if ([segue.identifier isEqualToString:@"addDeviceList"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[BLAddDeviceListViewController class]]) {
            BLAddDeviceListViewController *vc = (BLAddDeviceListViewController *)target;
            vc.model = (BLProductCategoryModel *)sender;
        }
    }
}

@end
