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
#import "IRCodeBrandInfo.h"
#import "BLDeviceService.h"
#import <BLLetIRCode/BLLetIRCode.h>

@interface BrandSelectController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *ircodeBrandTable;

@property (strong, nonatomic) NSMutableArray *brandInfos;

@end

@implementation BrandSelectController

+ (instancetype)viewController {
    BrandSelectController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Brands";
    self.brandInfos = [NSMutableArray arrayWithCapacity:0];
    self.ircodeBrandTable.delegate = self;
    self.ircodeBrandTable.dataSource = self;
    [self setExtraCellLineHidden:self.ircodeBrandTable];
    
    if (self.devtype == BL_IRCODE_DEVICE_TV_BOX) {
        [self querySTBBrandInfos];
    } else {
        [self queryTVBrandInfos];
    }
    
}

- (void)queryTVBrandInfos {
    BLIRCode *ircode = [BLIRCode sharedIrdaCode];
    
    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ircode requestIRCodeDeviceBrandsWithType:self.devtype completionHandler:^(BLBaseBodyResult * _Nonnull result) {
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
                    [self hideIndicatorOnWindow];
                    [self.ircodeBrandTable reloadData];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideIndicatorOnWindow];
                    [BLStatusBar showTipMessageWithStatus:result.msg];
                });
            }
        }];
    });
}

- (void)querySTBBrandInfos {
    
    BLIRCode *ircode = [BLIRCode sharedIrdaCode];
    
    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ircode requestSTBBrandsWithCompletionHandler:^(BLBaseBodyResult * _Nonnull result) {
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
                    [self hideIndicatorOnWindow];
                    [self.ircodeBrandTable reloadData];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideIndicatorOnWindow];
                    [BLStatusBar showTipMessageWithStatus:result.msg];
                });
            }
        }];
    });
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
    
    IRCodeBrandInfo *info = self.brandInfos[indexPath.row];
    cell.textLabel.text = info.brand;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Brand ID: %ld", (long)info.brandid];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    IRCodeBrandInfo *info = self.brandInfos[indexPath.row];
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    
    if (deviceService.manageDevices.count > 0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Selection" message:@"Please RM Device" preferredStyle:UIAlertControllerStyleActionSheet];
        
        [deviceService.manageDevices enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull did, BLDNADevice *  _Nonnull dev, BOOL * _Nonnull stop) {
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
