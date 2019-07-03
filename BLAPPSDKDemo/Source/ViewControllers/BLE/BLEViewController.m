//
//  BLEViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/6/25.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLEViewController.h"
#import "BLEDeviceViewController.h"
#import "BLESMDeviceViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEViewController ()<CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSMutableArray *deviceArray;
@property (nonatomic, strong) CBPeripheral *currentPeripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;

@property (weak, nonatomic) IBOutlet UITableView *deviceTable;
@property (weak, nonatomic) IBOutlet UITextView *showTextView;
@property (weak, nonatomic) IBOutlet UISwitch *scanSwitch;

@end

@implementation BLEViewController {
    dispatch_queue_t _queue;
}

+ (instancetype)viewController {
    BLEViewController *vc = [[UIStoryboard storyboardWithName:@"BLE" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"蓝牙扫描";
    
    self.deviceTable.delegate = self;
    self.deviceTable.dataSource = self;
    
    _queue = dispatch_queue_create("com.broadlink.blappsdkdemo.bluetooth", DISPATCH_QUEUE_SERIAL);
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:_queue];;
}

- (IBAction)switchClick:(UISwitch *)sender {
    
    if (sender.isOn) {
        // 开启扫描
        if(self.centralManager.state == 5){
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        }
    } else {
        // 停止扫描
        [self.centralManager stopScan];
    }
    
}

- (IBAction)btnClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 101:
            [self disconnectDevice];
            break;
        case 102:
            [self goToDeviceDetailView];
            break;
        case 103:
            [self goToSMDeviceDetailView];
            break;
        default:
            break;
    }
}

// 连接设备
- (void)connectDeviceWithPeripheral:(CBPeripheral *)peripheral {
    [self showIndicatorOnWindowWithMessage:@"正在连接蓝牙设备"];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

// 断开连接
- (void)disconnectDevice {
    if (self.currentPeripheral) {
        [self showIndicatorOnWindowWithMessage:@"正在断开连接"];
        [self.centralManager cancelPeripheralConnection:self.currentPeripheral];
    }
}

// 进入透传页面
- (void)goToDeviceDetailView {
    
    BLEDeviceViewController *vc = [BLEDeviceViewController viewController];
    vc.currentPeripheral = self.currentPeripheral;
    
    [self.navigationController showViewController:vc sender:nil];
}

// 进入透传页面
- (void)goToSMDeviceDetailView {
    
    BLESMDeviceViewController *vc = [BLESMDeviceViewController viewController];
    vc.currentPeripheral = self.currentPeripheral;
    
    [self.navigationController showViewController:vc sender:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"BLE_DEVICE_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    CBPeripheral *peripheral = self.deviceArray[indexPath.row];
    cell.textLabel.text = peripheral.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 停止扫描
    [self.centralManager stopScan];
    
    CBPeripheral *peripheral = self.deviceArray[indexPath.row];
    [self connectDeviceWithPeripheral:peripheral];
}


#pragma mark - CBCentralManagerDelegate
/**
 *  --  初始化成功自动调用
 *  --  必须实现的代理，用来返回创建的centralManager的状态。
 *  --  注意：必须确认当前是CBCentralManagerStatePoweredOn状态才可以调用扫描外设的方法：
 scanForPeripheralsWithServices
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            // 开始扫描周围的外设。
            /*
             -- 两个参数为Nil表示默认扫描所有可见蓝牙设备。
             -- 注意：第一个参数是用来扫描有指定服务的外设。然后有些外设的服务是相同的，比如都有FFF5服务，那么都会发现；而有些外设的服务是不可见的，就会扫描不到设备。
             -- 成功扫描到外设后调用didDiscoverPeripheral
             */
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        }
            break;
        default:
            break;
    }
}

// 连接外设--成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    self.currentPeripheral = peripheral;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideIndicatorOnWindow];
        self.showTextView.text = [NSString stringWithFormat:@"%@", self.currentPeripheral];
    });
}

// 连接外设——失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didFailToConnectPeripheral: %@", peripheral);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideIndicatorOnWindow];
        self.showTextView.text = [NSString stringWithFormat:@"didFailToConnectPeripheral Error: %@", error];
    });
}

// 取消与外设的连接回调
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didDisconnectPeripheral: %@", peripheral);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideIndicatorOnWindow];
        if (error) {
            self.showTextView.text = [NSString stringWithFormat:@"didDisconnectPeripheral Error: %@", error];
        } else {
            self.showTextView.text = @"";
        }
    });
}

// 发现外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if (![self.deviceArray containsObject:peripheral]) {
        if (peripheral != nil && peripheral.name != nil) {
            NSLog(@"Find device:%@", peripheral.name);
            
            [self.deviceArray addObject:peripheral];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.deviceTable reloadData];
            });
        }
    }
}

- (NSMutableArray *)deviceArray {
    if (_deviceArray == nil) {
        _deviceArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _deviceArray;
}

@end
