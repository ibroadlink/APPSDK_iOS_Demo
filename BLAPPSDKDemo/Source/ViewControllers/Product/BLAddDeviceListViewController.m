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
#import <BLLetAccount/BLLetAccount.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "Tools.h"

@interface BLAddDeviceListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *productCategoryList;
@end

@implementation BLAddDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getProductList:self.model.categoryid];
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
            self.productCategoryList = productCategoryList.productlist;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
}

#pragma mark - table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.productCategoryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"addDeviceListCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    BLDeviceConfigureInfo *model = self.productCategoryList[indexPath.row];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    [imageView sd_setImageWithURL:[NSURL URLWithString:model.iconUrlString]];
    UILabel *moduleName = (UILabel *)[cell viewWithTag:101];
    moduleName.text = model.moduleName;
    UILabel *deviceName = (UILabel *)[cell viewWithTag:102];
    deviceName.text = [NSString stringWithFormat:@"%@ %@",model.brand,model.deviceName] ;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLDeviceConfigureInfo *model = self.productCategoryList[indexPath.row];
    [self performSegueWithIdentifier:@"addDeviceToConfigStartView" sender:model];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addDeviceToConfigStartView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[BLConfigureStartViewController class]]) {
            BLConfigureStartViewController *vc = (BLConfigureStartViewController *)target;
            vc.model = (BLDeviceConfigureInfo *)sender;
        }
    }
}
@end
