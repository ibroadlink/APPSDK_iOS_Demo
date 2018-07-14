//
//  CloudTimerViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/12/14.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "CloudTimerViewController.h"
#import "AppDelegate.h"
#import "BLStatusBar.h"
@interface CloudTimerViewController (){
    BLCloudScene *_blCloudScene;
    BLCloudTime *_blCloudTime;
    BLCloudLinkage *_blCloudLinkage;
    
}
@property (nonatomic, strong) NSString *familyId;
@property (nonatomic, strong) NSString *moduleId;
@property (nonatomic, strong) BLFamilyAllInfo *familyAllInfo;
@end

@implementation CloudTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.familyId = @"007cde470f724312cc20307ea291c58f";
    self.moduleId =  @"3008140727659587469";
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _blCloudScene = delegate.blCloudScene;
    _blCloudTime = delegate.blCloudTime;
    _blCloudLinkage = delegate.blCloudLinkage;
    [self queryFamilyAllInfoWithId:self.familyId];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark -
- (void)queryFamilyAllInfoWithId:(NSString *)queryId {
    NSArray *idlist = @[queryId];
    BLFamilyController *manager = [BLFamilyController sharedManager];
    
    [self showIndicatorOnWindow];
    [manager queryFamilyInfoWithIds:idlist completionHandler:^(BLAllFamilyInfoResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                self.familyAllInfo = result.allFamilyInfoArray.firstObject;
                
            } else {
                NSLog(@"error:%ld msg:%@", (long)result.error, result.msg);
            }
        });
    }];
}

- (IBAction)addScene:(id)sender {
    [self addScene];
}

- (IBAction)sceneController:(id)sender {
    [self sceneController];
}

- (IBAction)querySceneHistory:(id)sender {
    [self querySceneHistory];
}

- (IBAction)querySceneDeteail:(id)sender {
    [self querySceneDeteail];
}
- (IBAction)querySceneRunningTask:(id)sender {
    [self querySceneRunningTask];
}
- (IBAction)addControlTimertask:(id)sender {
    [self addControlTimertask];
}
- (IBAction)addSceneTimertask:(id)sender {
    [self addSceneTimertask];
}
- (IBAction)queryControlTimerTask:(id)sender {
    [self queryControlTimerTask];
}
- (IBAction)querySceneTimerTask:(id)sender {
    [self querySceneTimerTask];
}
- (IBAction)addLinkageInfo:(id)sender {
    [self addLinkageInfo];
}
- (IBAction)queryLinkageInfoWithfromFamilyId:(id)sender {
    [self queryLinkageInfoWithfromFamilyId];
}
- (IBAction)upsetTriggerWithfromFamilyId:(id)sender {
    [self upsetTriggerWithfromFamilyId];
}

- (void)addScene {
    NSString *roomId;
    NSArray *roomInfos = self.familyAllInfo.roomBaseInfoArray;
    if (roomInfos && roomInfos.count > 0) {
        roomId = ((BLRoomInfo *)roomInfos.firstObject).roomId;
    }
    
    BLModuleInfo *module = [[BLModuleInfo alloc] init];
    module.familyId = self.familyId;
    module.roomId = roomId;
    module.name = @"Test Module";
    module.order = 1;
    module.flag = 0;
    module.moduleType = 1;
    module.followDev = 1;
    
    BLModuleIncludeDev *moduleDev;
    BLFamilyDeviceInfo *familyDeviceInfo;
    BLDNADevice *device;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.scanDevices && delegate.scanDevices.count > 0) {
        device = delegate.scanDevices.firstObject;
    }
    
    if (device) {
        moduleDev = [BLModuleIncludeDev new];
        moduleDev.did = device.did;
        moduleDev.order = 1;
        NSDictionary *contentDic =  @{
                                      @"name":@"打开插座",
                                      @"actions": @[
                                              @{
                                                  @"action": @{
                                                          @"name":device.name,
                                                          @"cmd": @{
                                                                  @"did": device.did,
                                                                  @"act":@"set",
                                                                  @"srv":@"",
                                                                  @"params":@[@"pwr"],
                                                                  @"vals":@[@[@{@"val":@"1",@"idx":@1}]],
                                                                  },
                                                          @"delay": @2, //延时时间, 单位为秒
                                                          }
                                                  }
                                              ]
                                      };
        moduleDev.content =  [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:contentDic options:0 error:nil]
                                                                  encoding:NSUTF8StringEncoding];
        
        NSArray *moduleDevs = @[moduleDev];
        module.moduleDevs = moduleDevs;
        
        familyDeviceInfo = [BLFamilyDeviceInfo new];
        familyDeviceInfo.familyId = self.familyId;
        familyDeviceInfo.roomId = roomId;
        familyDeviceInfo.pid = device.pid;
        familyDeviceInfo.did = device.did;
        familyDeviceInfo.name = device.name;
        familyDeviceInfo.mac = device.mac;
        familyDeviceInfo.terminalId = device.controlId;
        familyDeviceInfo.aesKey = device.getControlKey;
        familyDeviceInfo.password = device.password;
        familyDeviceInfo.type = device.type;
    }

    [_blCloudScene addScene:[module toDictionary] withDevice:[familyDeviceInfo toDictionary]  subDevice:nil fromFamilyId:self.familyId familyVersion:@"2017-12-27 17:21:03" completionHandler:^(BLSceneResult * _Nonnull result) {
        NSLog(@"BLModuleControlResult:%@",result.msg);
    }];
}

- (void)sceneController {
    [_blCloudScene controlScene:self.moduleId fromFamilyId:self.familyId completionHandler:^(BLSceneControlResult * _Nonnull result) {
        //{"status":0,"msg":"ok","data":{"taskid":"29"}}
        NSLog(@"BLSceneControlResult:{status:%ld,msg:%@,data:{taskid:%@}}",(long)result.error,result.msg,result.taskid);
    }];
}

- (void)querySceneHistory {
    [_blCloudScene querySceneHistory:self.moduleId index:0 count:10 fromFamilyId:self.familyId completionHandler:^(BLSceneHistroyResult * _Nonnull result) {
        //{"status":0,"msg":"ok","data":{"count":9,"scenelist":[{"taskid":"29","moduleid":"3008703514331485426","name":"派对","result":"fail","tasktime":"2017-12-23 15:11:22.958","nextdelay":0}]}}
        BLSceneData *scenedata = result.scenelist[0];
        NSLog(@"BLSceneHistroyResult:{status:%ld,msg:%@,data:{count:%ld,scenelist:[{taskid:%@,moduleid:%@,name:%@,result:%@,tasktime:%@,nextdelay:%ld}]}}",(long)result.error,result.msg,(long)result.count,scenedata.taskid,scenedata.moduleid,scenedata.name,scenedata.result,scenedata.tasktime,(long)scenedata.nextdelay);
    }];
}

- (void)querySceneDeteail {
    [_blCloudScene querySceneDeteail:@[@"24"] fromFamilyId:self.familyId completionHandler:^(BLSceneDeteailResult * _Nonnull result) {
        //{"status":0,"msg":"ok","scenedetail":[{"taskid":"24","moduleid":"3008703514331485426","name":"派对","result":"fail","tasktime":"2017-12-23 10:57:56.226","nextdelay":0,"detail":[{"order":0,"delay":500,"name":"热水器0907白,电源开关开 ","result":"fail","excutetime":"2017-12-23 10:57:56.885"}]}]}
        BLSceneDeteailData *sceneDeteailData = result.scenedetailList[0];
        BLSceneDeteail *sceneDeteail = sceneDeteailData.deteail[0];
        NSLog(@"BLSceneDeteailResult:{status:%ld,msg:%@,scenedetail:[{taskid:%@,moduleid:%@,name:%@,result:%@,tasktime:%@,nextdelay:%ld,detail:[{order:%@,delay:%ld,name:%@,result:%@,excutetime:%@}]}]}",(long)result.error,result.msg,sceneDeteailData.sceneData.taskid,sceneDeteailData.sceneData.moduleid,sceneDeteailData.sceneData.name,sceneDeteailData.sceneData.result,sceneDeteailData.sceneData.tasktime,(long)sceneDeteailData.sceneData.nextdelay,sceneDeteail.order,(long)sceneDeteail.delay,sceneDeteail.name,sceneDeteail.name,sceneDeteail.result,sceneDeteail.executtime);
    }];
}

- (void)querySceneRunningTask {
    [_blCloudScene querySceneRuning:self.familyId completionHandler:^(BLSceneDeteailResult * _Nonnull result) {
        //{"status":0,"msg":"ok","tasklist":null}
        BLSceneDeteailData *sceneDeteailData = result.scenedetailList[0];
        BLSceneDeteail *sceneDeteail = sceneDeteailData.deteail[0];
        NSLog(@"BLSceneDeteailResult:{status:%ld,msg:%@,scenedetail:[{taskid:%@,moduleid:%@,name:%@,result:%@,tasktime:%@,nextdelay:%ld,detail:[{order:%@,delay:%ld,name:%@,result:%@,excutetime:%@}]}]}",(long)result.error,result.msg,sceneDeteailData.sceneData.taskid,sceneDeteailData.sceneData.moduleid,sceneDeteailData.sceneData.name,sceneDeteailData.sceneData.result,sceneDeteailData.sceneData.tasktime,(long)sceneDeteailData.sceneData.nextdelay,sceneDeteail.order,(long)sceneDeteail.delay,sceneDeteail.name,sceneDeteail.name,sceneDeteail.result,sceneDeteail.executtime);
    }];
}

- (void)addControlTimertask {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@"1" forParam:@"pwr"];
//    BLCloudTimerParam *timer = [[BLCloudTimerParam alloc]init];
//    timer.weekdays = @"123";
//    timer.time = @"2017-11-22T19:10:43.845667579+08:00";
    [_blCloudTime addCloudTimer:[_device getBaseDictionary] fromFamilyId:self.familyId completionHandler:^(BLCloudTimerResult * _Nonnull result) {
        //{"status":0,"msg":"SUCCESS成功","jobid":"2ce64a6e9c58e75184493a6feec5eb8f"}
        NSLog(@"BLCloudTimerResult:{status:%ld,msg:%@,jobid:%@}",(long)result.error,result.msg,result.jobid);
    }];
}

- (void)addSceneTimertask {
//    BLCloudTimerParam *timer = [[BLCloudTimerParam alloc]init];
//    timer.weekdays = @"123";
//    timer.time = @"2017-11-22T19:10:43.845667579+08:00";
    [_blCloudTime addCloudTimer:[_device getBaseDictionary] fromFamilyId:self.familyId completionHandler:^(BLCloudTimerResult * _Nonnull result) {
        //{"status":0,"msg":"SUCCESS成功","jobid":"5315b2e975c5df0cd796a79afd0f5f2b"}
        NSLog(@"BLCloudTimerResult:{status:%ld,msg:%@,jobid:%@}",(long)result.error,result.msg,result.jobid);
    }];
}

- (void)queryControlTimerTask {
    [_blCloudTime queryDeviceCloudTimer:_device.did subdevice:nil fromFamilyId:self.familyId completionHandler:^(BLCouldTimerQueryResult * _Nonnull result) {
        //{"status":0,"msg":"SUCCESS成功","devtimers":[{"jobid":"2ce64a6e9c58e75184493a6feec5eb8f","did":"00000000000000000000b4430d96b5f8","devctrltimer":{"action":{"act":"set","did":"00000000000000000000b4430d96b5f8","license":"CceFpDt7d+r4pZ8KP74tbpNSf9Ug9pP+ytpIXApsCYpvvDEid0s8SdJtKgQMc5QmUsWWVwAAAACvEX37zpG5Wgi/Mlnda1pd2B9J96AQz9N0vO6WstfgR9yEgbkpFXFyJbsnfyHXt8pOdkTVo81rQrPhkOnhmpQBsEkbxXTfoUSQjDzWcfVjcAAAAAA=","params":["pwr"],"pid":"00000000000000000000000028270000","rmflag":false,"srv":"","subdevdid":"","subdevpid":"","tpid":"","type":0,"vals":[[{"idx":1,"val":"1"}]]},"owner":{"bizsys":"","familyid":"007cde470f724312cc20307ea291c58f","userid":"7930aa6e3c9a9ec086905c23d527edc9"},"timer":{"time":"2017-11-22T19:10:43.845667579+08:00","weekdays":"123"}},"pushurl":"http://172.16.10.169:15343/taskmanage/v1/timertask/execute","extern":"","DeletedAt":"","jobhistory":null}]}
        NSLog(@"BLDevtimersResult:{status:%ld,msg:%@}",(long)result.error,result.msg);
    }];
}

- (void)querySceneTimerTask {
    [_blCloudTime querySceneCloudTimers:self.moduleId fromfamilyId:self.familyId completionHandler:^(BLCouldTimerQueryResult * _Nonnull result) {
        //{"status":0,"msg":"SUCCESS成功","scenetimers":[{"jobid":"5315b2e975c5df0cd796a79afd0f5f2b","sceneid":"3008703514331485426","scenetimer":{"action":{"license":"CceFpDt7d+r4pZ8KP74tbpNSf9Ug9pP+ytpIXApsCYpvvDEid0s8SdJtKgQMc5QmUsWWVwAAAACvEX37zpG5Wgi/Mlnda1pd2B9J96AQz9N0vO6WstfgR9yEgbkpFXFyJbsnfyHXt8pOdkTVo81rQrPhkOnhmpQBsEkbxXTfoUSQjDzWcfVjcAAAAAA=","sceneid":"3008703514331485426","token":"","type":1},"owner":{"bizsys":"","familyid":"007cde470f724312cc20307ea291c58f","userid":"7930aa6e3c9a9ec086905c23d527edc9"},"timer":{"time":"2017-11-22T19:10:43.845667579+08:00","weekdays":"123"}},"pushurl":"http://172.16.10.169:15343/taskmanage/v1/timertask/execute","extern":"","DeletedAt":"","jobhistory":null}]}
        NSLog(@"BLScenetimersResult:{status:%ld,msg:%@}",(long)result.error,result.msg);
    }];
}

- (void)addLinkageInfo {
//    BLLinkageInfo *linkageinfo = [[BLLinkageInfo alloc]init];
//    linkageinfo.rulename = @"";
//    linkageinfo.enable = YES;
//    linkageinfo.delay = 2;
//    linkageinfo.moduleid = self.moduleId;
//
//    BLDateTimeData *datetime = [[BLDateTimeData alloc]init];
//    datetime.weekdays = @"1234567";
//    datetime.validperiod = @"08:12:30‐09:20:40";
//    datetime.timezone = 8;
//    linkageinfo.datetimes = @[datetime];
//
//    BLDevControlData *property = [[BLDevControlData alloc]init];
//    property.dev_name = @"台灯";
//    property.idev_did = @"00000000000000000000b4430d96b5f8";
//    property.ikey = @"pwr";
//    property.ref_value = 1;
//    property.ref_value_name = @"台灯开";
//    linkageinfo.propertys = @[property];
//
//    BLDevControlData *event = [[BLDevControlData alloc]init];
//    event.dev_name = @"热水器";
//    event.idev_did = @"00000000000000000000b4430dba8c59";
//    event.ikey = @"pwr";
//    event.ref_value = 1;
//    event.ref_value_name = @"热水器开";
//    linkageinfo.events = @[event];
    NSDictionary *linkageinfo = [[NSDictionary alloc]init];
    [_blCloudLinkage addCloudLinkage:linkageinfo fromFamilyId:self.familyId completionHandler:^(BLLinkageInfoResult * _Nonnull result) {
        //{"error":0,"status":0,"msg":"ok","ruleid":"5008995513783916692"}
        NSLog(@"BLLinkageInfoResult:{status:%ld,msg:%@,ruleid:%@}",(long)result.error,result.msg,result.ruleid);
    }];
}

- (void)queryLinkageInfoWithfromFamilyId {
    [_blCloudLinkage queryCloudLinkageInfo:self.familyId completionHandler:^(BLLinkageDataResult * _Nonnull result) {
        //{"error":0,"status":0,"msg":"ok","devinfo":[{"did":"0000000000000000000034ea34c1767b","pid":"0000000000000000000000003e750000","sdid":"","spid":"","aeskey":"88136f34b73e326a145e4778707d5c06","terminalid":1,"relatestatus":1}],"linkages":[{"rulename":"","ruletype":1,"ruleid":"5008898742176994667","enable":1,"delay":2,"characteristicinfo":{"conditionsinfo":{"datetime":[{"timezone":8,"validperiod":["08:12:30‐09:20:40"],"weekdays":"1234567"}],"property":[{"dev_name":"电饭锅","idev_did":"","ikey":"pwr","keeptime":0,"ref_value":1,"ref_value_name":"","trend_type":4,"type":0}]},"events":[{"dev_name":"电饭锅","idev_did":"","ikey":"pwr","keeptime":0,"ref_value":1,"ref_value_name":"","trend_type":4,"type":0}]},"locationinfo":{},"moduleinfo":[{"moduleid":"3008703514331485426"}],"createtime":"2017-12-22 16:52:38"}],"modules":[{"moduleid":"3008703514331485426","userid":"","familyid":"","version":"","roomid":"","name":"派对","icon":"","flag":0,"moduledev":[{"did":"0000000000000000000034ea34c1767b","sdid":"","order":0,"content":"{\"cmdParamList\":[{\"act\":\"set\",\"delay\":0,\"params\":[\"pwr\"],\"vals\":[[{\"idx\":0,\"val\":1}]]}],\"delay\":500,\"name\":\"热水器0907白,电源开关开 \"}","devmoduleid":""}]}
        NSLog(@"BLLinkageDataResult:{status:%ld,msg:%@}",(long)result.error,result.msg);
    }];
}

- (void)upsetTriggerWithfromFamilyId {
    [_blCloudLinkage executeCloudLinkage:self.familyId completionHandler:^(BLBaseResult * _Nonnull result) {
        //{"status":-2, "msg":"数据错误"}
        NSLog(@"BLBaseResult:{status:%ld,msg:%@}",(long)result.error,result.msg);
    }];
}
@end
