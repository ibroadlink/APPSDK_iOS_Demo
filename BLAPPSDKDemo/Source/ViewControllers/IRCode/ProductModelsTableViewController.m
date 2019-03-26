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
#import <BLLetIRCode/BLLetIRCode.h>

@interface ProductModelsTableViewController ()

@property (nonatomic, strong) BLIRCode *blircode;
@property(nonatomic, strong) NSMutableArray *modelsArray;

@end

@implementation ProductModelsTableViewController

+ (instancetype)viewController {
    ProductModelsTableViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modelsArray = [NSMutableArray arrayWithCapacity:0];
    self.blircode = [BLIRCode sharedIrdaCode];
    
    if (self.devtype == BL_IRCODE_DEVICE_AC) {
        [self queryDeviceVersionWithTypeId:self.devtype brandId:self.brandInfo.brandid];
    }else if (self.devtype == BL_IRCODE_DEVICE_TV) {
        [self queryDeviceCloudVersionWithTypeId:self.devtype brandId:self.brandInfo.brandid];
    }else if (self.devtype == BL_IRCODE_DEVICE_TV_BOX) {
        [self querySTBIRCodeDownloadUrl:self.provider];
    }
    
}

- (void)queryDeviceVersionWithTypeId:(NSInteger)typeId brandId:(NSInteger)brandId {
    
    [self.blircode requestIRCodeCloudScriptDownloadUrlWithType:typeId brand:brandId completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            [self.modelsArray removeAllObjects];
            
            NSLog(@"response:%@", result.responseBody);
            if (result.responseBody) {
                
                NSData *responseData = [result.responseBody dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                
                for (NSDictionary *pdic in responseDic[@"downloadinfo"]) {
                    IRCodeDownloadInfo *downloadinfo = [IRCodeDownloadInfo BLS_modelWithDictionary:pdic];
                    [self.modelsArray addObject: downloadinfo];
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

- (void)queryDeviceCloudVersionWithTypeId:(NSInteger)typeId brandId:(NSInteger)brandId {
    
    [self.blircode requestIRCodeScriptDownloadUrlWithType:typeId brand:brandId completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            [self.modelsArray removeAllObjects];

            NSLog(@"response:%@", result.responseBody);
            if (result.responseBody) {
                
                NSData *responseData = [result.responseBody dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                
                for (NSDictionary *pdic in responseDic[@"downloadinfo"]) {
                    IRCodeDownloadInfo *downloadinfo = [IRCodeDownloadInfo BLS_modelWithDictionary:pdic];
                    [self.modelsArray addObject: downloadinfo];
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
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"response:%@", result.responseBody);
            if (result.responseBody) {
                
                NSData *responseData = [result.responseBody dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                
                for (NSDictionary *pdic in responseDic[@"downloadinfo"]) {
                    IRCodeDownloadInfo *downloadinfo = [IRCodeDownloadInfo BLS_modelWithDictionary:pdic];
                    [self.modelsArray addObject: downloadinfo];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"SELECT_MODEL_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    self.downloadinfo = _modelsArray[indexPath.row];
    cell.textLabel.text = self.downloadinfo.name;
    cell.detailTextLabel.text = self.downloadinfo.downloadurl;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IRCodeDownloadInfo *downloadinfo = self.modelsArray[indexPath.row];
    downloadinfo.ircodeid = self.brandInfo.brandid;
    downloadinfo.devtype = self.devtype;
    [self performSegueWithIdentifier:@"RecoginzeIRCodeView" sender:downloadinfo];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RecoginzeIRCodeView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[RecoginzeIRCodeViewController class]]) {
            RecoginzeIRCodeViewController* opVC = (RecoginzeIRCodeViewController *)target;
            opVC.downloadinfo = (IRCodeDownloadInfo *)sender;
        }
    }
}
@end
