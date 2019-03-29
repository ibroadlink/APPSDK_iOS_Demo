//
//  DeviceCheckViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/29.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "DeviceCheckViewController.h"
#import "BLCheckDevice.h"
#import "BLStatusBar.h"

@interface DeviceCheckViewController ()

@property (nonatomic, strong)BLCheckDevice *deviceCheck;

@property (nonatomic, strong)NSMutableArray *mainServerList;
@property (nonatomic, strong)NSMutableArray *backServerList;

@end

@implementation DeviceCheckViewController

+ (instancetype)viewController {
    DeviceCheckViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *mac = @"34:ea:34:43:ea:48";
    NSUInteger type = 10039;
    self.deviceCheck = [[BLCheckDevice alloc] initWithDeviceMac:mac devType:type];
    
    self.mainServerList = [NSMutableArray arrayWithCapacity:0];
    self.backServerList = [NSMutableArray arrayWithCapacity:0];
    
}

- (IBAction)buttonClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 100:
            [self startDeviceCheck];
            break;
        case 101:
            [self queryServiceList];
            break;
        case 102:
            [self sendHeartBeat];
            break;
        case 103:
            [self closeDeviceCheck];
            break;
        default:
            break;
    }
    
}

- (void)startDeviceCheck {
    [self.deviceCheck createDeviceCheckSocket];
}

- (void)queryServiceList {
    NSString *result = [self.deviceCheck queryServerList];
    NSLog(@"result: %@", result);
    
    NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    NSInteger status = [dic[@"status"] integerValue];
    if (status == 0) {
        
        [self.mainServerList removeAllObjects];
        [self.backServerList removeAllObjects];
        
        [self.mainServerList addObjectsFromArray:dic[@"main"]];
        [self.backServerList addObjectsFromArray:dic[@"back"]];
        
    } else {
        [BLStatusBar showTipMessageWithStatus:@"Query Service List failed!"];
    }
    
}

- (void)sendHeartBeat {
    
    if (self.mainServerList.count > 0) {
        
        NSDictionary *dic = self.mainServerList.firstObject;
        NSString *ipaddr = dic[@"ip"];
        NSUInteger port = [dic[@"port"] unsignedIntegerValue];
        
        NSString *result = [self.deviceCheck sendHeartbeatToHostIP:ipaddr port:port];
        NSLog(@"result: %@", result);
    }
    
}

- (void)closeDeviceCheck {
    [self.deviceCheck closedDeviceCheckSocket];
    self.deviceCheck = nil;
}


@end
