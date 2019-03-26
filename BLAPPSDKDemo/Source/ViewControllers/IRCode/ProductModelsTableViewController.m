//
//  ProductModelsTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//


#import "ProductModelsTableViewController.h"
#import "RecoginzeIRCodeViewController.h"
#import <BLLetIRCode/BLLetIRCode.h>

@interface Brand ()
@property(nonatomic, readwrite, assign) NSInteger cateGoryId;
@end

@implementation Brand

- (instancetype)initWithDic: (NSDictionary *)dic {
    self = [super init];
    if (self) {
        _name = dic[@"brand"];
        _brandId = [dic[@"brandid"] integerValue];
        NSNumber *famous = dic[@"famousstatus"];
        _famous = [famous boolValue];
    }
    return self;
}

@end

@implementation Model

- (instancetype)initWithDic: (NSDictionary *)dic {
    self = [super init];
    if (self) {
        _name = dic[@"version"];
        _modelId = [dic[@"versionid"] integerValue];
    }
    return self;
}

@end

@interface ProductModelsTableViewController ()

@property (nonatomic, strong) BLIRCode *blircode;
@property(nonatomic, strong) NSArray *modelsArray;
@end

@implementation ProductModelsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _modelsArray = [NSArray array];
    self.blircode = [BLIRCode sharedIrdaCode];
    
    if (_devtype == BL_IRCODE_DEVICE_AC) {
        [self queryDeviceVersionWithTypeId:_devtype brandId:_cateGory.brandid];
    }else if (_devtype == BL_IRCODE_DEVICE_TV){
        [self queryDeviceCloudVersionWithTypeId:_devtype brandId:_cateGory.brandid];
    }else if (_devtype == BL_IRCODE_DEVICE_TV_BOX){
        [self querySTBIRCodeDownloadUrl:_provider];
    }
    
}

- (void)queryDeviceVersionWithTypeId:(NSInteger)typeId brandId:(NSInteger)brandId {
    [self.blircode requestIRCodeCloudScriptDownloadUrlWithType:typeId brand:brandId completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"response:%@", result.responseBody);
            if (result.responseBody) {
                
                NSData *responseData = [result.responseBody dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                
                NSMutableArray *array = [NSMutableArray new];
                for (NSDictionary *pdic in responseDic[@"downloadinfo"]) {
                    IRCodeDownloadInfo *downloadinfo = [IRCodeDownloadInfo BLS_modelWithDictionary:pdic];
                    [array addObject: downloadinfo];
                }
                self.modelsArray = array;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    }];
}

- (void)queryDeviceCloudVersionWithTypeId:(NSInteger)typeId brandId:(NSInteger)brandId {
    [self.blircode requestIRCodeScriptDownloadUrlWithType:typeId brand:brandId completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"response:%@", result.responseBody);
            if (result.responseBody) {
                
                NSData *responseData = [result.responseBody dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                
                NSMutableArray *array = [NSMutableArray new];
                for (NSDictionary *pdic in responseDic[@"downloadinfo"]) {
                    IRCodeDownloadInfo *downloadinfo = [IRCodeDownloadInfo BLS_modelWithDictionary:pdic];
                    [array addObject: downloadinfo];
                }
                self.modelsArray = array;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    }];
}

- (void)querySTBIRCodeDownloadUrl:(ProviderInfo *)provider {
    [self.blircode requestSTBIRCodeScriptDownloadUrlWithLocateid:provider.locateid providerid:provider.providerid brandId:0 completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"response:%@", result.responseBody);
            if (result.responseBody) {
                
                NSData *responseData = [result.responseBody dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                
                NSMutableArray *array = [NSMutableArray new];
                for (NSDictionary *pdic in responseDic[@"downloadinfo"]) {
                    IRCodeDownloadInfo *downloadinfo = [IRCodeDownloadInfo BLS_modelWithDictionary:pdic];
                    [array addObject: downloadinfo];
                }
                self.modelsArray = array;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }

        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _modelsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"SELECT_MODEL_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    _downloadinfo = _modelsArray[indexPath.row];
    cell.textLabel.text = _downloadinfo.name;
    cell.detailTextLabel.text = _downloadinfo.downloadurl;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IRCodeDownloadInfo *downloadinfo = _modelsArray[indexPath.row];
    downloadinfo.brandId = _cateGory.brandid;
    downloadinfo.devtype = _devtype;
    [self performSegueWithIdentifier:@"RecoginzeIRCodeView" sender:downloadinfo];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RecoginzeIRCodeView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[RecoginzeIRCodeViewController class]]) {
            RecoginzeIRCodeViewController* opVC = (RecoginzeIRCodeViewController *)target;
            opVC.downloadinfo = (IRCodeDownloadInfo *)sender;
            opVC.device = self.device;
        }
    }
}
@end
