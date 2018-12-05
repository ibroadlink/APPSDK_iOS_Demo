//
//  RMSubDeviceTableViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/11/5.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import "RMSubDeviceTableViewController.h"
#import <BLLetIRCode/BLLetIRCode.h>
#import "BLStatusBar.h"
@interface RMSubDeviceTableViewController ()
@property (nonatomic, strong) NSArray *testList;
@end

@implementation RMSubDeviceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.testList = @[  @"queryAcStatus",
                      @"queryAcIRCode",
                      @"bindAcIRCode",
                      @"queryIRCodeList",
                      @"queryIRCodeFunction",
                      @"createIRCodeList",
                      @"updateIRCodeFunction",
                      @"delIRCodeList",
                      ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"IRCODETESTCELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.testList[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            [self queryAcStatus];
            break;
        case 1:
            [self queryAcIRCode];
            break;
        case 2:
            [self bindAcIRCode];
            break;
        case 3:
            [self queryIRCodeList];
            break;
        case 4:
            [self queryIRCodeFunction];
            break;
        case 5:
            [self createIRCodeList];
            break;
        case 6:
            [self updateIRCodeFunction];
            break;
        case 7:
            [self delIRCodeList];
            break;
        default:
            break;
    }
    
}
/**
 * 查询空调状态
 */
- (void)queryAcStatus {
    NSDictionary *paramDic = @{
                               @"did": @"00000000000000000000780f77757c81",
                               };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLIRCode sharedIrdaCode] queryAcStatus:param];
    [BLStatusBar showTipMessageWithStatus:result];
}
/**
 * 查询空调红外码
 */
- (void)queryAcIRCode {
    NSDictionary *paramDic = @{
                               @"did": @"00000000000000000000780f77757c81",
                               @"power":@1,
                               @"temp":@28,
                               @"mode":@1,
                               @"wind_speed":@0,
                               @"wdirect":@0,
                               @"key":@1,
                               @"freq":@38,
                               };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLIRCode sharedIrdaCode] queryAcIRCode:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

/**
 * 空调红外码绑定
 */
- (void)bindAcIRCode {
    NSDictionary *paramDic = @{
                               @"did": @"00000000000000000000780f77757c81",
                               @"codeUrl": @"https://d0f94faa04c63d9b7b0b034dcf895656rccode.ibroadlink.com/publicircode/v2/app/getfuncfilebyfixedid?fixedid=32273768&mkey=a887d345&mtag=gz",
                               @"brandId": @"1619",
                               };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLIRCode sharedIrdaCode] bindAcIRCode:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

/**
 * 获取电视/机顶盒红码列表
 */
- (void)queryIRCodeList {
    NSDictionary *paramDic = @{
                               @"did": @"00000000000000000000780f77757c81",
                               };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLIRCode sharedIrdaCode] queryIRCodeList:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

/**
 * 红外码function查询
 */
- (void)queryIRCodeFunction {
    NSDictionary *paramDic = @{
                               @"did": @"00000000000000000000780f77757c81",
                               @"function": @"power",
                               };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLIRCode sharedIrdaCode] queryIRCodeFunction:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

/**
 * 创建红外码
 */
- (void)createIRCodeList {
    NSDictionary *paramDic = @{
                               @"did": @"00000000000000000000780f77757c81",
                               @"irInfo":@{
                                       @"irId":@"303865",           //红码ID  可选
                                       @"brandId":@"天龙",       //红码品牌  可选
                                       @"provinceId":@"浙江",      //机顶盒红码所在省份  可选
                                       @"cityId":@"杭州",          //机顶盒红码所在城市  可选
                                       @"providerId":@"123",      //机顶盒运营商ID可选
                                       @"source":@"官方",         //红码来源 （用户库/官方）
                                       },
                               @"irDataList":@[
                                       @{
                                           @"code": @"3700380000027d7c123e123e123e123e121d121d123e121d123e121d123e121d121d121d121d121d123e123e121d123e121d123e121d123e1200051f",
                                           @"icon":@"ttianlong.png",  //可选
                                           @"name":@"名称",         //可选
                                           @"function": @"power"      //可选
                                           }
                                       ]
                               };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLIRCode sharedIrdaCode] createIRCodeList:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

/**
 * 红外码function更新
 */
- (void)updateIRCodeFunction {
    NSDictionary *paramDic = @{
                               @"did": @"00000000000000000000780f77757c81",
                               @"irDataList":@[
                                             @{
                                                 @"code": @"260058000001269413111313121114111",
                                                 @"icon":@"xxxxxxxxxxxxxx",  //可选
                                                 @"name":@"名称",         //可选
                                                 @"function": @"power"      //可选
                                             }
                                             ]
                               };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLIRCode sharedIrdaCode] updateIRCodeFunction:param];
    [BLStatusBar showTipMessageWithStatus:result];
}

/**
 * 删除红外码列表
 */
- (void)delIRCodeList {
    NSDictionary *paramDic = @{
                               @"did": @"00000000000000000000780f77757c81",
                               @"functionList":@[
                                               @"power"
                                               ]
                               };
    NSString *param = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLIRCode sharedIrdaCode] delIRCodeList:param];
    [BLStatusBar showTipMessageWithStatus:result];
}
@end
