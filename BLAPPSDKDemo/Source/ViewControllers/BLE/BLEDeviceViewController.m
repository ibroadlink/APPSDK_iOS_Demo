//
//  BLEDeviceViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/6/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLEDeviceViewController.h"
#import "AppMacro.h"


@interface BLEDeviceViewController ()<CBPeripheralDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>

// 特征列表
@property (nonatomic, strong) NSMutableArray *characteristics;
// 写特征
@property(nonatomic, strong) CBCharacteristic *characteristic;
// 读特征
@property(nonatomic, strong) CBCharacteristic *readCharacteristic;

@property (weak, nonatomic) IBOutlet UITableView *characteristicsTable;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UITextView *showTextView;

@end

@implementation BLEDeviceViewController

+ (instancetype)viewController {
    BLEDeviceViewController *vc = [[UIStoryboard storyboardWithName:@"BLE" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.currentPeripheral.name;
    self.currentPeripheral.delegate = self;
    
    self.characteristicsTable.delegate = self;
    self.characteristicsTable.dataSource = self;
    
    self.inputTextView.delegate = self;
    self.showTextView.delegate = self;
    
    //4.扫描外设的服务
    /**
     --     外设的服务、特征、描述等方法是CBPeripheralDelegate的内容，所以要先设置代理peripheral.delegate = self
     --     参数表示你关心的服务的UUID，比如我关心的是"49535343-FE7D-4AE5-8FA9-9FAFD205E455",参数就可以为@[[CBUUID UUIDWithString:@"49535343-FE7D-4AE5-8FA9-9FAFD205E455"]].那么didDiscoverServices方法回调内容就只有这两个UUID的服务，不会有其他多余的内容，提高效率。nil表示扫描所有服务
     --     成功发现服务，回调didDiscoverServices
     */
    [self.currentPeripheral discoverServices:@[[CBUUID UUIDWithString:BLE_SERVICE_UUID]]];
}

- (IBAction)buttonClick:(UIButton *)sender {
    
    NSString *writeString = self.inputTextView.text;
    NSData *data = [writeString dataUsingEncoding:NSUTF8StringEncoding];
    [self.currentPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
    
}

/*
*    @constant CBCharacteristicPropertyBroadcast                        Permits broadcasts of the characteristic value using a characteristic configuration descriptor. Not allowed for local characteristics.
*    @constant CBCharacteristicPropertyRead                            Permits reads of the characteristic value.
*    @constant CBCharacteristicPropertyWriteWithoutResponse            Permits writes of the characteristic value, without a response.
*    @constant CBCharacteristicPropertyWrite                            Permits writes of the characteristic value.
*    @constant CBCharacteristicPropertyNotify                        Permits notifications of the characteristic value, without a response.
*    @constant CBCharacteristicPropertyIndicate                        Permits indications of the characteristic value.
*    @constant CBCharacteristicPropertyAuthenticatedSignedWrites        Permits signed writes of the characteristic value
*    @constant CBCharacteristicPropertyExtendedProperties            If set, additional characteristic properties are defined in the characteristic extended properties descriptor. Not allowed for local characteristics.
*    @constant CBCharacteristicPropertyNotifyEncryptionRequired        If set, only trusted devices can enable notifications of the characteristic value.
*    @constant CBCharacteristicPropertyIndicateEncryptionRequired    If set, only trusted devices can enable indications of the characteristic value.
*/
- (NSArray *)propertieArray:(CBCharacteristicProperties)properties {
    NSArray *array = @[@"Broadcast", @"Read", @"WriteWithoutResponse", @"Write", @"Notify", @"Indicate",
                       @"AuthenticatedSignedWrites", @"ExtendedProperties", @"NotifyEncryptionRequired", @"IndicateEncryptionRequired"];
    
    NSMutableArray *pArray = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < array.count; i++) {
        if ((properties >> i) & 0x0001) {
            [pArray addObject:array[i]];
        }
    }
    
    return [pArray copy];
}

#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.characteristics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"Characteristics_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    CBCharacteristic *characteristic = self.characteristics[indexPath.row];
    cell.textLabel.text = characteristic.UUID.UUIDString;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    NSArray *pArray = [self propertieArray:characteristic.properties];
    NSString *propertiesString = [pArray componentsJoinedByString:@" | "];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Properties : %@", propertiesString];
    
    return cell;
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.characteristicsTable reloadData];
    });
}

// 获取值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    // characteristic.value就是蓝牙给我们的值
    // 因为我们是两个特征 一个读 一个写 所以我读取数据，只要从读的特征中获取就可以了
    if (characteristic ==  self.readCharacteristic) {
        //characteristic.value 就是我们想要的数据了
        NSData *data = characteristic.value;
        
        if (data) {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"read : %@", string);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.showTextView.text = string;
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

- (NSMutableArray *)characteristics {
    if (_characteristics == nil) {
        _characteristics = [NSMutableArray arrayWithCapacity:0];
    }
    return _characteristics;
}

@end
