//
//  FastconGroupDeviceViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/8/23.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "FastconGroupDeviceViewController.h"
#import "DNAControlViewController.h"
#import "BLDeviceService.h"
#import "BLStatusBar.h"

@interface FastconGroupDeviceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) BLDNADevice *device;
@property (nonatomic, strong) NSMutableArray<BLDNADevice *>* subDevicelist;

@property (weak, nonatomic) IBOutlet UITextField *pidText;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation FastconGroupDeviceViewController

+ (instancetype)viewController {
    FastconGroupDeviceViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.subDevicelist = [NSMutableArray arrayWithCapacity:0];
    [self subDevListQuery:0];
    
    
}

- (IBAction)getGroupDeviceList:(id)sender {
    [self subDevListQuery:0];
}

- (void)subDevListQuery:(NSUInteger)index {
    if (index == 0) {
        [self.subDevicelist removeAllObjects];
    }
   BLSubDevListResult *result = [[BLLet sharedLet].controller subDevListQueryWithDid:self.device.did index:index count:10];
     if ([result succeed]) {
         self.resultTextView.text = [result BLS_modelToJSONString];
         __block int n = 0;
         if (result.list.count > 0) {
             [result.list enumerateObjectsUsingBlock:^(BLDNADevice * _Nonnull subDevice, NSUInteger idx, BOOL * _Nonnull stop) {
                 if ([subDevice.pid isEqualToString:self.pidText.text]) {
                     [self.subDevicelist addObject:subDevice];
                 }else {
                     n = n + 1;
                 }
             }];
         }
         
         if (self.subDevicelist.count + n < result.total) {
             [self subDevListQuery:++index];
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
             [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
         });
     }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subDevicelist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"SUB_DEVICE_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    BLDNADevice *subDevice = self.subDevicelist[indexPath.row];
    cell.textLabel.text = subDevice.did;
    cell.detailTextLabel.text = subDevice.pid;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLDNADevice *subDevice = self.subDevicelist[indexPath.row];
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Control" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
        deviceService.gatewayDevice = deviceService.selectDevice;
        deviceService.selectDevice = subDevice;
        [[BLLet sharedLet].controller addDevice:subDevice];
        [self performSegueWithIdentifier:@"DNAControlView" sender:nil];
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
        deviceService.gatewayDevice = deviceService.selectDevice;
        deviceService.selectDevice = subDevice;
        [[BLLet sharedLet].controller addDevice:subDevice];
        [self performSegueWithIdentifier:@"groupDeviceEdit" sender:nil];
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
    [self presentViewController:alertView animated:YES completion:nil];
}
@end
