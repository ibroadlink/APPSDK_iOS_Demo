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
#import "BLProductCategoryList.h"
#import "BLProductCategoryModel.h"
#import "BLDeviceConfigureInfo.h"
#import "BLConfigureStartViewController.h"
#import "BLAddDeviceListViewController.h"


@interface ProductListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong, readwrite) NSArray<BLProductCategoryModel *> *categoryArray;
@property (nonatomic, strong, readwrite) NSArray<BLDeviceConfigureInfo *> *hotDeviceArray;
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
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGSize size = self.view.bounds.size;
    flowLayout.itemSize = CGSizeMake(size.width - 30, 65);
    flowLayout.minimumInteritemSpacing = 7;
    flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    self.collectionView.collectionViewLayout = flowLayout;
}

+ (instancetype)viewController {
    ProductListViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

//获取产品分类列表
- (void)getProductCategoryList {
    BLAccount *account = [BLAccount sharedAccount];
    NSDictionary *headers = @{@"countryCode": @"1",
                              @"userid": account.loginUserid};
    NSDictionary *parameters = @{ @"brandid": @"",
                                  @"protocols": @[]};
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:@"/ec4/v1/system/resource/categorylist"];
    
    [self showIndicatorOnWindow];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self generatePost:url head:headers data:parameters timeout:[BLConfigParam sharedConfigParam].httpTimeout completionHandler:^(NSData *data, NSError *error) {
            if (data) {
                BLProductCategoryList *productCategoryList = [BLProductCategoryList BLS_modelWithJSON:data];
                self.categoryArray = productCategoryList.categorylist;
                self.hotDeviceArray = productCategoryList.hotproducts;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self.collectionView reloadData];
            });
            
        }];
    });
}

- (void)generatePost:(NSString *)url
                head:(NSDictionary *)head
                data:(NSDictionary *)data
             timeout:(NSUInteger)timeout
   completionHandler:(void (^)(NSData * data, NSError * error))completionHandler
{
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    BLLogDebug(@"postData:%@",[BLCommonTools serializeMessage:data]);
    [httpAccessor post:url head:head data:[NSJSONSerialization dataWithJSONObject:data options:0 error:nil] timeout:timeout completionHandler:completionHandler];
}

#pragma mark --- UICollectionViewDelegate

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
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"deviceCell" forIndexPath:indexPath];
        BLDeviceConfigureInfo *model = self.hotDeviceArray[indexPath.row];
        UIImageView *imageView = [cell viewWithTag:101];
        UILabel *label = [cell viewWithTag:102];
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.iconUrlString]];
        label.text = model.moduleName;
        cell.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"categoryCell" forIndexPath:indexPath];
        BLProductCategoryModel *model = self.categoryArray[indexPath.row];
        UIImageView *imageView = [cell viewWithTag:101];
        UILabel *label = [cell viewWithTag:102];
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.link]];
        label.text = model.name;
        cell.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.hotDeviceArray.count;
    } else {
        return self.categoryArray.count;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 90);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return CGSizeMake(self.view.bounds.size.width, 50);
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
        if (section != 0) {
            return CGSizeMake(self.view.bounds.size.width, 10);
        }
    return CGSizeZero;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"configStartView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[BLConfigureStartViewController class]]) {
            BLConfigureStartViewController *vc = (BLConfigureStartViewController *)target;
            vc.model = (BLDeviceConfigureInfo *)sender;
        }
    }else if ([segue.identifier isEqualToString:@"addDeviceList"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[BLAddDeviceListViewController class]]) {
            BLAddDeviceListViewController *vc = (BLAddDeviceListViewController *)target;
            vc.model = (BLProductCategoryModel *)sender;
        }
    }
        
}

@end
