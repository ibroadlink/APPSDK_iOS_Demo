//
//  FastconViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/14.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "FastconViewController.h"

#import "BLDeviceService.h"
#import "BLStatusBar.h"

@interface FastconViewController ()
@property (strong, nonatomic) BLDNADevice *device;
@property (nonatomic, strong)NSMutableArray *configArray;
@end

@implementation FastconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view.
    self.configArray = [NSMutableArray arrayWithCapacity:0];
}

- (IBAction)getFastconList:(id)sender {
    [self showIndicatorOnWindowWithMessage:@"Getting fastcon devices..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getFastconListWith:0];
    });
}

- (IBAction)fastconConfig:(id)sender {
    [self fastconNoConfig:self.configArray];
}

- (IBAction)getFastconStatus:(id)sender {
    [self getFastconStatusWithDevList:self.configArray];
}

//获取待配网设备列表
- (void)getFastconListWith:(NSUInteger)index {
    if (index == 0) {
        [self.configArray removeAllObjects];
    }
    
    NSDictionary *waitConfigDataDic = @{
                                        @"did": self.device.did,
                                        @"act":@(0),
                                        @"count":@(10),
                                        @"index":@(index),
                                        };
    NSString *waitConfigDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:waitConfigDataDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *waitConfigResult = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did subDevDid:nil dataStr:waitConfigDataStr command:@"fastcon_no_config" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[waitConfigResult dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    if ([dic[@"status"] integerValue] == 0) {
        NSDictionary *data = dic[@"data"];
        NSUInteger total = [data[@"total"] unsignedIntegerValue];
        NSArray *configList = data[@"devlist"];
        
        if (![BLCommonTools isEmptyArray:configList]) {
            [self.configArray addObjectsFromArray:configList];
            if (self.configArray.count < total) {
                [self getFastconListWith:++index];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideIndicatorOnWindow];
                    [self.tableView reloadData];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self.tableView reloadData];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [self.tableView reloadData];
        });
    }
}

//fastcon配网
- (void)fastconNoConfig:(NSArray *)configArray {
    NSDictionary *configDataDic = @{
                                    @"did": self.device.did,
                                    @"act":@(1),
                                    @"devlist":configArray
                                    };
    NSString *configDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:configDataDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *configResult = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did subDevDid:nil dataStr:configDataStr command:@"fastcon_no_config" scriptPath:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultView.text = configResult;
        });
        
    });
    
}

//配网结果查询
- (void)getFastconStatusWithDevList:(NSArray *)configList {
    NSDictionary *dic = @{
                          @"did": self.device.did,
                          @"act":@(2),
                          @"devlist":configList
                          };
    NSString *str = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did subDevDid:nil dataStr:str command:@"fastcon_no_config" scriptPath:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultView.text = result;
            NSLog(@"fastcon_no_config_result:%@",result);
        });
        
    });
    
    
}

#pragma mark - tabel delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.configArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"DEVICE_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *deviceDic = self.configArray[indexPath.row];
    cell.textLabel.text = deviceDic[@"did"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end
