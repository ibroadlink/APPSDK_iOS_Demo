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
@property (nonatomic, copy)NSArray *configArray;

@end

@implementation FastconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view.
    _configArray = [NSArray array];
}
- (IBAction)getFastconList:(id)sender {
    [self getFastconList];
}

- (IBAction)fastconConfig:(id)sender {
    [self fastconNoConfig:_configArray];
}

- (IBAction)getFastconStatus:(id)sender {
    [self getFastconStatusWithDevList:_configArray];
}

//获取待配网设备列表
- (void)getFastconList {
    NSDictionary *waitConfigDataDic = @{
                                        @"did": _device.did,
                                        @"act":@0,
                                        @"count":@10,
                                        @"index":@0,
                                        
                                        };
    NSString *waitConfigDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:waitConfigDataDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *waitConfigResult = [[BLLet sharedLet].controller dnaControl:_device.did subDevDid:nil dataStr:waitConfigDataStr command:@"fastcon_no_config" scriptPath:nil];
    [BLStatusBar showTipMessageWithStatus:waitConfigResult];
    _resultView.text = waitConfigResult;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[waitConfigResult dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    if ([dic[@"status"]integerValue] == 0) {
        NSArray *configList = dic[@"data"][@"devlist"];
        _configArray = [configList copy];
        [self.tableView reloadData];
    }
}

//fastcon配网
- (void)fastconNoConfig:(NSArray *)configArray {
    NSDictionary *configDataDic = @{
                                    @"did": _device.did,
                                    @"act":@1,
                                    @"devlist":configArray
                                    
                                    };
    NSString *configDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:configDataDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *configResult = [[BLLet sharedLet].controller dnaControl:_device.did subDevDid:nil dataStr:configDataStr command:@"fastcon_no_config" scriptPath:nil];
    _resultView.text = configResult;
}

//配网结果查询
- (void)getFastconStatusWithDevList:(NSArray *)configList {
    NSDictionary *dic = @{
                          @"did": _device.did,
                          @"act":@2,
                          @"devlist":configList
                          
                          };
    NSString *str = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *result = [[BLLet sharedLet].controller dnaControl:_device.did subDevDid:nil dataStr:str command:@"fastcon_no_config" scriptPath:nil];
    _resultView.text = result;
    NSLog(@"fastcon_no_config_result:%@",result);
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
    
    NSDictionary *deviceDic = _configArray[indexPath.row];
    cell.textLabel.text = deviceDic[@"did"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end
