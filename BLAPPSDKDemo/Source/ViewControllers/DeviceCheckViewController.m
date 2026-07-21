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
#import "Tools.h"

@interface DeviceCheckViewController ()

@property (nonatomic, strong)BLCheckDevice *deviceCheck;

@property (nonatomic, strong)NSMutableArray *mainServerList;
@property (nonatomic, strong)NSMutableArray *backServerList;

@end

@implementation DeviceCheckViewController

+ (instancetype)viewController {
    return [Tools viewControllerFromMainStoryboard:self];
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
    if (!self.deviceCheck) {
        [BLStatusBar showTipMessageWithStatus:@"Device check is unavailable."];
        return;
    }
    [self.deviceCheck createDeviceCheckSocket];
}

- (void)queryServiceList {
    NSString *result = [self.deviceCheck queryServerList];
    NSDictionary *dic = [Tools dictionaryFromJSONString:result];
    if (![dic isKindOfClass:[NSDictionary class]]) {
        [BLStatusBar showTipMessageWithStatus:@"Query Service List failed!"];
        return;
    }
    
    NSInteger status = [dic[@"status"] integerValue];
    NSArray *main = dic[@"main"];
    NSArray *back = dic[@"back"];
    if (status == 0 && [main isKindOfClass:[NSArray class]] && [back isKindOfClass:[NSArray class]]) {
        
        [self.mainServerList removeAllObjects];
        [self.backServerList removeAllObjects];
        
        [self.mainServerList addObjectsFromArray:main];
        [self.backServerList addObjectsFromArray:back];
        
    } else {
        [BLStatusBar showTipMessageWithStatus:@"Query Service List failed!"];
    }
    
}

- (void)sendHeartBeat {
    if (self.mainServerList.count > 0) {
        NSDictionary *dic = self.mainServerList.firstObject;
        if (![dic isKindOfClass:[NSDictionary class]]) {
            [BLStatusBar showTipMessageWithStatus:@"Heartbeat target is invalid."];
            return;
        }
        NSString *ipaddr = dic[@"ip"];
        NSUInteger port = [dic[@"port"] unsignedIntegerValue];
        if (ipaddr.length == 0 || port == 0 || !self.deviceCheck) {
            [BLStatusBar showTipMessageWithStatus:@"Heartbeat target is unavailable."];
            return;
        }
        [self.deviceCheck sendHeartbeatToHostIP:ipaddr port:port];
    } else {
        [BLStatusBar showTipMessageWithStatus:@"Please query the service list first."];
    }
}

- (void)closeDeviceCheck {
    if (!self.deviceCheck) {
        return;
    }
    [self.deviceCheck closedDeviceCheckSocket];
    self.deviceCheck = nil;
}


@end
