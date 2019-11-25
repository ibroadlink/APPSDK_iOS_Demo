//
//  WebSocketManagerViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/11/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "WebSocketManagerViewController.h"
#import "BLDeviceService.h"
#import <BLSWebScoket/BLSWebScoket.h>
@interface WebSocketManagerViewController ()<BLWebSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextView *resultView;
@property (nonatomic, strong) BLSWebSocketClient *webSocket;
@end

@implementation WebSocketManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //     使用WebSocket连接
    BLSWebScoketUrlResult *urlResult = [[BLSWebSocketManager shareManager] apprelayGetUrl];
    for (NSString *urlPath in urlResult.data.url) {
        self.webSocket = [[BLSWebSocketManager shareManager] createLink:urlPath];
        self.webSocket.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.webSocket closeWebSocketActively];
}

- (IBAction)action:(UIButton *)sender {
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    if (sender.tag == 101) {
        //订阅
        [self devsubscription:[deviceService.manageDevices allValues]];
    }else if (sender.tag == 102) {
        //推送
        for (BLDNADevice *device in [deviceService.manageDevices allValues]) {
            [self devstatepush:device];
        }
    }else if (sender.tag == 103) {
        //取消订阅
        [self devunsubscription:[deviceService.manageDevices allValues]];
    }else if (sender.tag == 104) {
        //查询订阅
    }
}

- (void)didInitMessage:(id)message {
    if ([message isKindOfClass:[NSString class]]) {
        self.resultView.text = message;
    }
}

- (void)didReceiveMessage:(id)message {
    if ([message isKindOfClass:[NSString class]]) {
        self.resultView.text = message;
    }
}

- (void)didFailWithError:(NSError *)error {
    
}

- (void)didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
}



//设备订阅
- (void)devsubscription:(NSArray<BLDNADevice *> *)devArray{
    NSTimeInterval nowTimeInvterval = [[NSDate date] timeIntervalSince1970];
    NSString *msgId = [NSString stringWithFormat:@"%@-%f", [BLConfigParam sharedConfigParam].userid, nowTimeInvterval];
    NSMutableArray *devList = [NSMutableArray arrayWithCapacity:0];
    for (BLDNADevice *device in devArray) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        NSString *endpointId = device.did;
        NSString *gatewayId = device.pDid;
        [dict setObject:endpointId forKey:@"endpointId"];
        if (![BLCommonTools isEmpty:gatewayId]) {
            [dict setObject:gatewayId forKey:@"gatewayId"];
        }
        
        [devList addObject:dict];
    }
    NSDictionary *tempDict = @{
        @"msgtype":@"devsub",
        @"messageid":msgId,
        @"data":@{
            @"devList":devList
        }
    };
       
    NSString *sendString = [tempDict BLS_modelToJSONString];
    [self.webSocket sendMsg:sendString];
}

//设备推送
- (void)devstatepush:(BLDNADevice *)device{
    NSTimeInterval nowTimeInvterval = [[NSDate date] timeIntervalSince1970];
    NSString *msgId = [NSString stringWithFormat:@"%@-%f", [BLConfigParam sharedConfigParam].userid, nowTimeInvterval];

    NSDictionary *tempDict = @{
        @"msgtype":@"devstatepush",
        @"messageid":msgId,
        @"data":@{
            @"endpointId":device.did,
            @"property":@{},
            @"state":@{}
        }
    };
       
    NSString *sendString = [tempDict BLS_modelToJSONString];
    [self.webSocket sendMsg:sendString];
}

//取消订阅
- (void)devunsubscription:(NSArray<BLDNADevice *> *)devArray{
    NSTimeInterval nowTimeInvterval = [[NSDate date] timeIntervalSince1970];
    NSString *msgId = [NSString stringWithFormat:@"%@-%f", [BLConfigParam sharedConfigParam].userid, nowTimeInvterval];
    NSMutableArray *devList = [NSMutableArray arrayWithCapacity:0];
    for (BLDNADevice *device in devArray) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        NSString *endpointId = device.did;
        NSString *gatewayId = device.pDid;
        [dict setObject:endpointId forKey:@"endpointId"];
        if (![BLCommonTools isEmpty:gatewayId]) {
            [dict setObject:gatewayId forKey:@"gatewayId"];
        }
        [devList addObject:dict];
    }
    NSDictionary *tempDict = @{
        @"msgtype":@"devunsub",
        @"messageid":msgId,
        @"data":@{
            @"devList":devList
        }
    };
       
    NSString *sendString = [tempDict BLS_modelToJSONString];
    [self.webSocket sendMsg:sendString];
}
@end
