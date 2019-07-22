//
//  BLESMDeviceViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/7/2.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLESMDeviceViewController.h"
#import "BLESMDataParser.h"


#import "BLStatusBar.h"
#import "AppMacro.h"

#define NOTIFY_MTU 150

@interface BLESMDeviceViewController () <CBPeripheralDelegate, UITextViewDelegate>

// 充值Token
@property (nonatomic, strong) NSString *token;
// 通讯地址
@property (nonatomic, strong) NSString *address;

// 特征列表
@property (nonatomic, strong) NSMutableArray *characteristics;
// 写特征
@property (nonatomic, strong) CBCharacteristic *characteristic;
// 读特征
@property (nonatomic, strong) CBCharacteristic *readCharacteristic;

// 发送数据Index
@property (nonatomic, assign) NSInteger sendDataIndex;
// 需要发送的数据
@property (nonatomic, strong) NSData *dataToSend;
// 发送是否成功
@property (nonatomic, assign) BOOL didSendSuccess;

@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation BLESMDeviceViewController {
    dispatch_semaphore_t sem;
}

+ (instancetype)viewController {
    BLESMDeviceViewController *vc = [[UIStoryboard storyboardWithName:@"BLE" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sem = dispatch_semaphore_create(0);
    
    self.title = self.currentPeripheral.name;
    self.address = self.currentPeripheral.name;
    self.currentPeripheral.delegate = self;
    
    // 扫描外设的服务
    /**
     外设的服务、特征、描述等方法是CBPeripheralDelegate的内容，所以要先设置代理peripheral.delegate = self
     参数表示你关心的服务的UUID，比如我关心的是"49535343-FE7D-4AE5-8FA9-9FAFD205E455",参数就可以为 @[[CBUUID UUIDWithString:@"49535343-FE7D-4AE5-8FA9-9FAFD205E455"]].那么didDiscoverServices方法回调内容就只有这两个UUID的服务，不会有其他多余的内容，提高效率。nil表示扫描所有服务
     成功发现服务，回调didDiscoverServices
     */
    [self.currentPeripheral discoverServices:@[[CBUUID UUIDWithString:BLE_SERVICE_UUID]]];
}

- (IBAction)buttonClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 100:
            [self smDeviceRecharge];
            break;
        case 101:
            [self smDeviceQueryBalance];
            break;
        case 102:
            [self smDeviceQueryAllInquiry];
            break;
        case 103:
            [self smDeviceAddress];
            break;
        case 104:
            [self sendFileToBLE];
            break;
        default:
            break;
    }
}

// 发送文件到蓝牙
- (void)sendFileToBLE {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSData* data = [[NSData alloc] init];
    data = [fm contentsAtPath:path];
    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    [self writeToPeripheralWithData:data];
}

// 获取表号
- (void)smDeviceAddress {
    NSData *data = [BLESMDataParser genGetAddress];
    [self writeToPeripheralWithData:data];
}

// 查询充值
- (void)smDeviceRecharge {
    
    NSString *message = @"请输入Token";
    if (self.token) {
        message = @"请确认token是否正确";
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self.token ? self.token : @"";
        textField.placeholder = @"token";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.token = alertController.textFields.firstObject.text;
        NSData *data = [BLESMDataParser genRechargeStringWithToken:self.token address:self.address];
        
        [self writeToPeripheralWithData:data];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 查询余额
- (void)smDeviceQueryBalance {
    NSData *data = [BLESMDataParser genBalanceWithAddress:self.address];
    [self writeToPeripheralWithData:data];
}

// 查询参数
- (void)smDeviceQueryAllInquiry {
    NSData *data = [BLESMDataParser genInquiryWithAddress:self.address];
    [self writeToPeripheralWithData:data];
}

// 写数据
- (void)writeToPeripheralWithData:(NSData *)data {
    
    if (!self.currentPeripheral || !self.characteristic) {
        [BLStatusBar showTipMessageWithStatus:@"无法找到写特征值"];
        return;
    }
    
    NSString *hex = [BLCommonTools data2hexString:data];
    NSLog(@"Write: %@", hex);
    
    self.sendDataIndex = 0;
    self.dataToSend = data;
    self.didSendSuccess = YES;
    
    [self showIndicatorOnWindowWithMessage:@"正在发送数据..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self _sendData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
        });
    });

//    [self.currentPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
}


/**
 * Sends the next amount of data to the connected central
 */
- (void)_sendData {
    
    // There's data left, so send until the callback fails, or we're done.
    
    while (self.didSendSuccess) {
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 150 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        NSString *hex = [BLCommonTools data2hexString:chunk];
        NSLog(@"Send %ld: %@", (long)self.sendDataIndex, hex);
        
        // Send it
        [self.currentPeripheral writeValue:chunk forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 1000*NSEC_PER_MSEC));
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            return;
        }
    }
}


#pragma mark - CBPeripheralDelegate

// 发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    //NSLog(@"didDiscoverServices,Error:%@",error);
    CBService * __nullable findService = nil;
    // 遍历服务
    for (CBService *service in peripheral.services) {
        NSLog(@"UUID:%@",service.UUID);
        
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:BLE_SERVICE_UUID]]) {
            findService = service;
        }
    }
    
    NSLog(@"Find Service:%@",findService);
    if (findService)
        [peripheral discoverCharacteristics:NULL forService:findService];
}

// 发现特征回调
// 发现特征后，可以根据特征的properties进行：读readValueForCharacteristic、写writeValue、订阅通知setNotifyValue、扫描特征的描述discoverDescriptorsForCharacteristic。
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    [self.characteristics removeAllObjects];
    [self.characteristics addObjectsFromArray:service.characteristics];
    
    for (CBCharacteristic *characteristic in self.characteristics) {
        NSLog(@"UUID: %@", characteristic.UUID);
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CHARACTERISTIC_NOTIFY_UUID]]) {
            // 接收一次(是读一次信息还是数据经常变实时接收视情况而定, 再决定使用哪个)
            // [peripheral readValueForCharacteristic:characteristic];
            // 订阅, 实时接收
            self.readCharacteristic = characteristic;
            [self.currentPeripheral setNotifyValue:YES forCharacteristic:characteristic];
            
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CHARACTERISTIC_WRITE_UUID]]) {
            self.characteristic = characteristic;
        }
        
        /**
         -- 当发现characteristic有descriptor,回调didDiscoverDescriptorsForCharacteristic
         */
        [self.currentPeripheral discoverDescriptorsForCharacteristic:characteristic];
    }
    
}

// 获取值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    // characteristic.value就是蓝牙给我们的值
    // 因为我们是两个特征 一个读 一个写 所以我读取数据，只要从读的特征中获取就可以了

    NSData *data = characteristic.value;
    
    NSString *hex = [BLCommonTools data2hexString:data];
    NSLog(@"Read: %@", hex);
    
    if (data) {
        id info = [BLESMDataParser parseBytes:data];
        if (!info) {
            NSLog(@"Can not parse data");
        } else if ([info isKindOfClass:[RechargeInfo class]]) {
            // 充值
            RechargeInfo *rechargeInfo = (RechargeInfo *)info;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (rechargeInfo.state == 0) {
                    self.resultTextView.text = [NSString stringWithFormat:@"充值: %lf kWh\n余额: %lf kWh",
                                                rechargeInfo.rechargeValue, rechargeInfo.balance];
                } else {
                    self.resultTextView.text = @"充值失败";
                }
            });
            
        } else if ([info isKindOfClass:[BalanceInfo class]]) {
            // 余额查询
            BalanceInfo *balanceInfo = (BalanceInfo *)info;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (balanceInfo.state == 0) {
                    self.resultTextView.text = [NSString stringWithFormat:@"余额: %lf kWh", balanceInfo.balance];
                } else {
                    self.resultTextView.text = @"余额查询失败";
                }
            });
            
        } else if ([info isKindOfClass:[MeterInfo class]]) {
            // 参数查询
            MeterInfo *meterInfo = (MeterInfo *)info;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (meterInfo.state == 0) {
                    NSString *relayState = @"开闸turn on";
                    if (meterInfo.relayState == RELAY_STATE_DISCONNECTED) {
                        relayState = @"合闸 turn off";
                    }
                    
                    self.resultTextView.text = [NSString stringWithFormat:@"时间: %@\n状态: %@\n余额: %lf kWh\n正向总功率: %lfkW\n正向总能量: %lfkWh\n秘钥版本号: %d\n费率: %lf",
                                                meterInfo.time, relayState, meterInfo.balance, meterInfo.positiveActivePower,
                                                meterInfo.positiveActiveEnergy, meterInfo.secretKeyVision, meterInfo.rate];
                    
                } else {
                    self.resultTextView.text = @"查询失败";
                }
            });
            
            
        } else if ([info isKindOfClass:[AddressInfo class]]) {
            // 通讯地址查询
            
            AddressInfo *addrInfo = (AddressInfo *)info;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (addrInfo.state == 0) {
                    self.addressLabel.text = [NSString stringWithFormat:@"表号: %@", addrInfo.address];
                    self.address = addrInfo.address;
                } else {
                    self.addressLabel.text = @"表号查询失败";
                }
            });
        }
    }
    
}

// 中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
    } else {
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        NSLog(@"%@", characteristic);
    }
}

// 写入函数回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    dispatch_semaphore_signal(sem);
    
    NSLog(@"didWriteValueForCharacteristic:%@", [characteristic.UUID UUIDString]);
    
    if (error) {
        self.didSendSuccess = NO;
        NSLog(@"didWriteValueForCharacteristic error：%@",[error localizedDescription]);
    }
    
}

- (NSMutableArray *)characteristics {
    if (_characteristics == nil) {
        _characteristics = [NSMutableArray arrayWithCapacity:0];
    }
    return _characteristics;
}
@end
