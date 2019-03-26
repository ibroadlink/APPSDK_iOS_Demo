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
        [self querySTBProvider];
    }
}

- (void)queryIRCodeBrands {
    
    [self.blircode requestIRCodeDeviceBrandsWithType:self.devtype completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            [self.brandInfos removeAllObjects];
            
            NSLog(@"response:%@", result.responseBody);
            NSData *jsonData = [result.responseBody dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responseBodydic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                            options:NSJSONReadingMutableContainers
                                                                              error:nil];
            
            if (![BLCommonTools isEmptyArray:responseBodydic[@"brand"]]) {
                for (NSDictionary *dic in responseBodydic[@"brand"]) {
                    BrandInfo *info = [BrandInfo BLS_modelWithDictionary:dic];
                    [self.brandInfos addObject:info];
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

- (void)querySTBProvider {
    
    [self.blircode requestSTBProviderWithLocateid:_subAreainfo.locateid completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"response:%@", result.responseBody);
            if (result.responseBody) {
                [self.brandInfos removeAllObjects];
                
                NSData *jsonData = [result.responseBody dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responseBodydic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                options:NSJSONReadingMutableContainers
                                                                                  error:nil];

                if (![BLCommonTools isEmptyArray:responseBodydic[@"providerinfo"]]) {
                    for (NSDictionary *dic in responseBodydic[@"providerinfo"]) {
                        ProviderInfo *info = [ProviderInfo BLS_modelWithDictionary:dic];
                        [self.brandInfos addObject:info];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
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
        BrandInfo *info = _brandInfos[indexPath.row];
        cell.textLabel.text = info.brand;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Brand ID: %ld", info.brandid];
    }else if(self.devtype == BL_IRCODE_DEVICE_TV_BOX){
        ProviderInfo *info = _brandInfos[indexPath.row];
        cell.textLabel.text = info.providername;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Provider ID: %ld", info.providerid];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.devtype == BL_IRCODE_DEVICE_AC || self.devtype == BL_IRCODE_DEVICE_TV) {
        BrandInfo *cateGory = _brandInfos[indexPath.row];
        [self performSegueWithIdentifier:@"ProductModelsView" sender:cateGory];
    }else if(self.devtype == BL_IRCODE_DEVICE_TV_BOX){
        ProviderInfo *provider = _brandInfos[indexPath.row];
        provider.locateid = _subAreainfo.locateid;
        [self performSegueWithIdentifier:@"ProductModelsView" sender:provider];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ProductModelsView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[ProductModelsTableViewController class]]) {
            ProductModelsTableViewController* opVC = (ProductModelsTableViewController *)target;
            if (self.devtype == BL_IRCODE_DEVICE_AC || self.devtype == BL_IRCODE_DEVICE_TV) {
                opVC.cateGory = (BrandInfo *)sender;
            }else if(self.devtype == BL_IRCODE_DEVICE_TV_BOX){
                opVC.provider = (ProviderInfo *)sender;
            }
            
            opVC.devtype = self.devtype;
        }
    }
}
@end
