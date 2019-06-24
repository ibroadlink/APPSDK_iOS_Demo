//
//  CateGoriesTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "CateGoriesTableViewController.h"
#import "ProductModelsTableViewController.h"

#import "BLStatusBar.h"
#import <BLLetIRCode/BLLetIRCode.h>

@interface CateGoriesTableViewController ()

@property (nonatomic, strong) BLIRCode *blircode;
@property (nonatomic, strong) NSMutableArray *brandInfos;

@end

@implementation CateGoriesTableViewController

+ (instancetype)viewController {
    CateGoriesTableViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.brandInfos = [NSMutableArray arrayWithCapacity:0];
    self.blircode = [BLIRCode sharedIrdaCode];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self queryDeviceTypes];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryDeviceTypes {
    if (self.devtype == BL_IRCODE_DEVICE_AC || self.devtype == BL_IRCODE_DEVICE_TV) {
        [self queryIRCodeBrands];
    } else if(self.devtype == BL_IRCODE_DEVICE_TV_BOX){
        [self querySTBProvider_V3];
    }
}

- (void)queryIRCodeBrands {
    
    [self.blircode requestIRCodeDeviceBrandsWithType:self.devtype completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
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
                 [BLStatusBar showTipMessageWithStatus:result.msg];
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
                [BLStatusBar showTipMessageWithStatus:result.msg];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"IRCODE_BRAND_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    if (self.devtype == BL_IRCODE_DEVICE_AC || self.devtype == BL_IRCODE_DEVICE_TV) {
        IRCodeBrandInfo *info = _brandInfos[indexPath.row];
        cell.textLabel.text = info.brand;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Brand ID: %ld", (long)info.brandid];
    }else if(self.devtype == BL_IRCODE_DEVICE_TV_BOX){
        IRCodeProviderInfo *info = _brandInfos[indexPath.row];
        cell.textLabel.text = info.providername;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Provider ID: %ld", (long)info.providerid];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ProductModelsTableViewController *vc = [ProductModelsTableViewController viewController];
    vc.devtype = self.devtype;
    
    if (self.devtype == BL_IRCODE_DEVICE_AC || self.devtype == BL_IRCODE_DEVICE_TV) {
        vc.brandInfo = self.brandInfos[indexPath.row];
    }else if(self.devtype == BL_IRCODE_DEVICE_TV_BOX){
        IRCodeProviderInfo *provider = self.brandInfos[indexPath.row];
        vc.provider = provider;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
