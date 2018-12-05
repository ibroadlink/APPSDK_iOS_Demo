//
//  Controller.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>
#import "BLConfigParam.h"
#import "BLDNADevice.h"

#import "BLDeviceConfigResult.h"
#import "BLPairResult.h"
#import "BLBindDeviceResult.h"
#import "BLProfileStringResult.h"
#import "BLStdData.h"
#import "BLStdControlResult.h"
#import "BLPassthroughResult.h"
#import "BLUpdateDeviceResult.h"
#import "BLFirmwareVersionResult.h"
#import "BLDeviceTimeResult.h"
#import "BLQueryTaskResult.h"
#import "BLTaskDataResult.h"
#import "BLSubDevAddResult.h"
#import "BLSubDevListResult.h"
#import "BLQueryResourceVersionResult.h"
#import "BLGetAPListResult.h"
#import "BLAPConfigResult.h"
#import "BLSubdevBaseResult.h"
#import "BLQueryDeviceStatusResult.h"

/**
 Device Controller Delegate. 
 You must call "startProbe" to get these infomations.
 */
@protocol BLControllerDelegate <NSObject>

@optional
/**
 Filter device when find new device.

 @param device      Filter device info
 @return            YES / NO.  Default is NO.
 */
- (Boolean)filterDevice:(BLDNADevice * _Nonnull)device;

/**
 Add device to sdk when find new device.

 @param device      Add device info
 @return            YES / NO.  Default is NO.
 */
- (Boolean)shouldAdd:(BLDNADevice * _Nonnull)device;

/**
 Update device info when find new device or device info change.

 @param device      Update device info
 @param isNewDevice Device is added to sdk or not
 */
- (void)onDeviceUpdate:(BLDNADevice * _Nonnull)device isNewDevice:(Boolean)isNewDevice;

/**
 Device status changed callback

 @param device      Device info
 @param status      Device status
 */
- (void)statusChanged:(BLDNADevice * _Nonnull)device status:(BLDeviceStatusEnum)status;

@end


/**
 Device Controller Class
 */
@interface BLController : NSObject

/**
 Account loginUserid
 */
@property (nonatomic, strong) NSString *loginUserid;

/**
 Account loginSession
 */
@property (nonatomic, strong) NSString *loginSession;

/** Obtain familyId from BLFamilyInfoResult */
@property (nonatomic, strong)NSString *currentFamilyId;

/**
 Device Controller Delegate
 */
@property (nonatomic, weak) id <BLControllerDelegate> _Nullable delegate;

/**
 Get BLController Instance Object With Config Param

 @param configParam     Config Param
 @return                BLController Instance
 */
+ (instancetype _Nullable)sharedControllerWithConfigParam:(BLConfigParam *_Nonnull)configParam;

/**
 * Set current family id
 * @param currentFamilyId currentFamilyId
 */
- (void)setCurrentFamilyId:(NSString *_Nullable)currentFamilyId;

/**
 Get DNASDK version

 @return                DNASDK version
 */
- (NSString *_Nonnull)getSDKVersion;

/**
 Set DNASDK device control only in lan.

 @param localMode       YES/NO
 @return                Set result
 */
- (Boolean)setSDKOnlyLocalControl:(Boolean)localMode;

/**
 Set DNASDK debug log level.

 @param logLevel        Log level
 @return                Set result.
 */
- (Boolean)setSDKRawDebugLevel:(BLDebugLevelEnum)logLevel;

/**
 *  Set SDK readBlock and writeBlock.
 */
- (void)setSDKRawWithReadBlock:(BLReadPrivateDataBlock _Nullable )readBlock writeBlock:(BLWritePrivateDataBlock _Nullable )writeBlock;

/**
 Set IRCode SDK

 @param ircodeBlock Common IRCode
 @param acBlock AC Code
 */
- (void)setIRCodeNetworkCallback:(IRCodeOperationBlock _Nullable)ircodeBlock acOperationBlock:(ACIRCodeOperationBlock _Nullable)acBlock;

/**
 Start probe devices in lan. Default one probe is 3000ms.
 */
- (void)startProbe:(NSInteger)probeInterval;

/**
 Stop probe devices in lan.
 */
- (void)stopProbe;

/**
 Config device to phone's WiFi. 
 This interface is Obstructed.

 @param ssid        WiFi ssid
 @param password    WiFi password,
 @param version     Config Version (1, 2, 3), rely to device profile. Default is 2.
 @param timeout     Config timeout
 @return            Config result
 */
- (BLDeviceConfigResult * _Nonnull)deviceConfig:(NSString *_Nonnull)ssid
                                       password:(NSString *_Nonnull)password
                                        version:(NSUInteger)version
                                        timeout:(NSInteger)timeout;

/**
 Config device to phone's WiFi. 
 This interface is Obstructed. Use default version(2) and timeout(75s).
 
 @param ssid        WiFi ssid
 @param password    WiFi password,
 @return            Config result
 */
- (BLDeviceConfigResult *_Nonnull)deviceConfig:(NSString *_Nonnull)ssid
                                      password:(NSString *_Nonnull)password;

/**
 Cancel config device.

 @return            Cancel result.
 */
- (BLBaseResult *_Nonnull)deviceConfigCancel;

/**
 Query device network state.

 @param did         Device did
 @return            Query result - BLDeviceStatusEnum
 */
- (BLDeviceStatusEnum)queryDeviceState:(NSString *_Nonnull)did;

/**
 Query device network Remotestate.
 
 @param did         Device did
 @return            Query result - BLDeviceRemoteStatusEnum
 */
- (BLDeviceStatusEnum)queryDeviceRemoteState:(NSString *_Nonnull)did;

/**
 Batch Query device network Remotestate.
 
 @param tempArray   Device
 @return            Query result
 */
- (BLQueryDeviceStatusResult *)queryDeviceOnServer:(NSArray<BLDNADevice *> *)tempArray;

/**
 Query device lan ip address.

 @param did         Device did
 @return            Query result - if device not in lan, retuen ""
 */
- (NSString *_Nonnull)queryDeviceIp:(NSString *_Nonnull)did;

/**
 Pair device to get control id and key.
 These id and key are used to control deivce in remote mode.

 @param did         Device did
 @return            Pair result - Include control id and key.
 */
- (BLPairResult *_Nonnull)pair:(NSString *_Nonnull)did;

/**
 Pair device to get control id and key.
 These id and key are used to control deivce in remote mode.
 
 @param device Device info
 @return Pair result - Include control id and key.
 */
- (BLPairResult *_Nonnull)pairWithDevice:(BLDNADevice *_Nonnull)device;

/**
 Add device list to sdk.
 Device must be added to sdk, if you want to control this deive.

 @param deviceArray Device info List
 */
- (void)addDeviceArray:(NSArray<BLDNADevice *> *_Nonnull)deviceArray;

/**
 Add a device to sdk.
 Device must be added to sdk, if you want to control this deive.

 @param device      Device info
 */
- (void)addDevice:(BLDNADevice *_Nonnull)device;

/**
 Query device is in sdk

 @param device Device info
 */
- (BOOL)existDevice:(BLDNADevice *_Nonnull)device;

/**
 Query device in sdk

 @param did device did
 @return  Device info
 */
- (BLDNADevice *)getDevice:(NSString *)did;

/**
 Remove device list from sdk.

 @param deviceArray Device info List
 */
- (void)removeDeviceArray:(NSArray<BLDNADevice *> *_Nonnull)deviceArray;

/**
 Remove a device from sdk.

 @param device      Device info
 */
- (void)removeDevice:(BLDNADevice *_Nonnull)device;

/**
 Remove all device infos from sdk.
 */
- (void)removeAllDevice;

/**
 Bind device to server for control device in remote mode.
 You need login first.

 @param device      Device info
 @return            Bind result
 */
- (BLBindDeviceResult *_Nonnull)bindDeviceWithServer:(BLDNADevice *_Nonnull)device;

/**
 Query device bind to server status.

 @param device      Device info
 @return            Query result
 */
- (BLBindDeviceResult *_Nonnull)queryDeviceBinded:(BLDNADevice *_Nonnull)device;

/**
 Query device list bind to server status. Max support 16 devices.
 
 @param deviceArray Device info list
 @return            Query result
 */
- (BLBindDeviceResult *_Nonnull)queryDeviceArrayBinded:(NSArray<BLDNADevice *> *_Nonnull)deviceArray;

/**
 Query device's product profile in default store path.
 After first query, sdk will store profile info in cache.

 @param did         Device did
 @return            Query result
 */
- (BLProfileStringResult *_Nonnull)queryProfile:(NSString *_Nonnull)did;

/**
 Query device's product profile with specify the file.
 After first query, sdk will store profile info in cache.

 @param did             Device did
 @param profilePath     Specify profile
 @return                Query result
 */
- (BLProfileStringResult *_Nonnull)queryProfile:(NSString *_Nonnull)did
                                  profilePath:(NSString *_Nullable)profilePath;

/**
 Query product profile in default store path.
 After first query, sdk will store profile info in cache.
 
 @param pid             Device product pid
 @return                Query result
 */
- (BLProfileStringResult *_Nonnull)queryProfileByPid:(NSString *_Nonnull)pid;

/**
 Query product profile with specify the file.
 After first query, sdk will store profile info in cache.
 
 @param pid             Device product pid
 @param profilePath     Specify profile
 @return                Query result
 */
- (BLProfileStringResult *_Nonnull)queryProfileByPid:(NSString *_Nonnull)pid
                                         profilePath:(NSString *_Nullable)profilePath;

/**
 Clean sdk store cache.
 If profile has changed, you need clean cache first.
 
 @param identifier did / pid
 */
- (void)cleanProfileCahe:(NSString *_Nonnull)identifier;

/**
 Control device in default store path.

 @param did             Control device did
 @param stdData         Control data
 @param action          Control action - "get" / "set"
 @return                Control result
 */
- (BLStdControlResult *_Nonnull)dnaControl:(NSString *_Nonnull)did
                                   stdData:(BLStdData *_Nonnull)stdData
                                    action:(NSString *_Nonnull)action;

/**
 Control device with specify the script.
 
 @param did             Control device did
 @param stdData         Control data
 @param action          Control action - "get" / "set"
 @param scriptPath      Control device script. If scriptPath = nil, find device script in default store path.
 @return                Control result
 */
- (BLStdControlResult *_Nonnull)dnaControl:(NSString *_Nonnull)did
                                   stdData:(BLStdData *_Nonnull)stdData
                                    action:(NSString *_Nonnull)action
                                scriptPath:(NSString *_Nullable)scriptPath;

/**
 Control sub device in default store path.
 
 @param did             Control wifi device did
 @param sDid            Control sub device did. If sdid = nil, just control wifi device.
 @param stdData         Control data
 @param action          Control action - "get" / "set"
 @return                Control result
 */
- (BLStdControlResult *_Nonnull)dnaControl:(NSString *_Nonnull)did
                                 subDevDid:(NSString *_Nullable)sDid
                                   stdData:(BLStdData *_Nonnull)stdData
                                    action:(NSString *_Nonnull)action;

/**
 Control sub device with specify the script.
 
 @param did             Control wifi device did
 @param sDid            Control sub device did. If sdid = nil, just control wifi device.
 @param stdData         Control data
 @param action          Control action - "get" / "set"
 @param scriptPath      Control device script. If scriptPath = nil, find device script in default store path.
 @return                Control result
 */
- (BLStdControlResult *_Nonnull)dnaControl:(NSString *_Nonnull)did
                                 subDevDid:(NSString *_Nullable)sDid
                                   stdData:(BLStdData *_Nonnull)stdData
                                    action:(NSString *_Nonnull)action
                                scriptPath:(NSString *_Nullable)scriptPath;


/**
 Control sub device with specify the script.
 
 @param did             Control wifi device did
 @param sDid            Control sub device did. If sdid = nil, just control wifi device.
 @param stdData         Control data
 @param action          Control action - "get" / "set"
 @param scriptPath      Control device script. If scriptPath = nil, find device script in default store path.
 @param sendcount       Control device send count. Default by BLConfigParam.controllerSendCount
 @return                Control result
 */
- (BLStdControlResult *_Nonnull)dnaControl:(NSString *_Nonnull)did
                                 subDevDid:(NSString *_Nullable)sDid
                                   stdData:(BLStdData *_Nonnull)stdData
                                    action:(NSString *_Nonnull)action
                                scriptPath:(NSString *_Nullable)scriptPath
                                 sendcount:(NSUInteger)sendcount;


/**
 Control device with data string composed by yourself.

 @param did             Control wifi device did
 @param sDid            Control sub device did. If sdid = nil, just control wifi device.
 @param dataStr         Control data string composed by yourself
 @param command         Control command composed by yourself
 @param scriptPath      Control device script. If scriptPath = nil, find device script in default store path.
 @return                Control result
 */
- (NSString *_Nonnull)dnaControl:(NSString *_Nonnull)did
                       subDevDid:(NSString *_Nullable)sDid
                         dataStr:(NSString *_Nonnull)dataStr
                         command:(NSString *_Nonnull)command
                      scriptPath:(NSString *_Nullable)scriptPath;

/**
 Control device with data string composed by yourself.
 
 @param did             Control wifi device did
 @param sDid            Control sub device did. If sdid = nil, just control wifi device.
 @param dataStr         Control data string composed by yourself
 @param command         Control command composed by yourself
 @param scriptPath      Control device script. If scriptPath = nil, find device script in default store path.
 @param sendcount       Control device send count. Default by BLConfigParam.controllerSendCount
 @return                Control result
 */
- (NSString *_Nonnull)dnaControl:(NSString *_Nonnull)did
                       subDevDid:(NSString *_Nullable)sDid
                         dataStr:(NSString *_Nonnull)dataStr
                         command:(NSString *_Nonnull)command
                      scriptPath:(NSString *_Nullable)scriptPath
                       sendcount:(NSUInteger)sendcount;

/**
 Control device with passthough raw data

 @param did             Control device did
 @param passthroughData Control raw data
 @return                Control result
 */
- (BLPassthroughResult *_Nonnull)dnaPassthrough:(NSString *_Nonnull)did
                              passthroughData:(NSData *_Nonnull)passthroughData;

/**
 Control sub device with passthough raw data
 
 @param did             Control device did
 @param sDid            Control sub device did
 @param passthroughData Control raw data
 @return                Control result
 */
- (BLPassthroughResult *_Nonnull)dnaPassthrough:(NSString *_Nonnull)did
                                      subDevDid:(NSString *_Nullable)sDid
                                passthroughData:(NSData *_Nonnull)passthroughData;

/**
 Get raw data from device script

 @param did             Control wifi device did
 @param sDid            Control sub device did. If sdid = nil, just control wifi device.
 @param stdData         Control data
 @param action          Control action - "get" / "set"
 @return                Get raw data
 */
- (NSData *_Nonnull)dnaControlData:(NSString *_Nonnull)did
                         subDevDid:(NSString *_Nullable)sDid
                           stdData:(BLStdData *_Nonnull)stdData
                            action:(NSString *_Nonnull)action;

/**
 Modify device info - name and lock status

 @param did             Device did
 @param name            Device new name
 @param locked          Device lock status
 @return                Modify result
 */
- (BLUpdateDeviceResult *_Nonnull)updateDeviceInfo:(NSString *_Nonnull)did
                                            name:(NSString *_Nonnull)name
                                            lock:(Boolean)locked;

/**
 Query device firmware version

 @param did             Device did
 @return                Query result
 */
- (BLFirmwareVersionResult *_Nonnull)queryFirmwareVersion:(NSString *_Nonnull)did;

/**
 Upgrade device firmware
 Only send url to device, and device will upgrade after.

 @param did             Device did
 @param url             New firmware download url
 @return                Result
 */
- (BLBaseResult *_Nonnull)upgradeFirmware:(NSString *_Nonnull)did
                                    url:(NSString *_Nonnull)url;

/**
 Query sub device firmware version
 
 @param did wifi device did
 @param sdid sub device did
 @return Query result
 */
- (BLFirmwareVersionResult *_Nonnull)querySubDeviceFirmwareVersion:(NSString *_Nonnull)did sdid:(NSString *_Nonnull)sdid;

/**
 Query device server time

 @param did             Device did
 @return                Query result
 */
- (BLDeviceTimeResult *_Nonnull)queryDeviceTime:(NSString *_Nonnull)did;

/**
 Query sub deivce all tasks, include timer tasks and period tasks.

 @param did             Query wifi device did
 @param sdid            Query sub device did. If sdid = nil, just control wifi device.
 @param scriptPath      Device script. If scriptPath = nil, find device script in default store path.
 @return                Query result
 */
- (BLQueryTaskResult *_Nonnull)queryTask:(NSString *_Nonnull)did sDid:(NSString *_Nullable)sdid scriptPath:(NSString *_Nullable)scriptPath;

/**
 Query deivce all tasks, include timer tasks and period tasks.

 @param did             Query device did
 @return                Query result
 */
- (BLQueryTaskResult *_Nonnull)queryTask:(NSString *_Nonnull)did;


/**
 add/update timer/Delay task to device

 @param did         wifi device did
 @param sdid        sub device did. If sdid = nil, just control wifi device.
 @param taskType    timer type,BL_TIMER_TYPE_LIST = 0;BL_DELAY_TYPE_LIST = 1.
 @param isNew       add or update .
 @param timerInfo   timer task info
 @param stdData     timer task do control data
 @param scriptPath  Device script. If scriptPath = nil, find device script in default store path.
 @return            result and query now all tasks
 */
- (BLQueryTaskResult *_Nonnull)updateTask:(NSString *_Nonnull)did
                                          sDid:(NSString *_Nullable)sdid
                                      taskType:(BLTimeTypeEnum)taskType
                                         isNew:(BOOL)isNew
                                     timerInfo:(BLTimerOrDelayInfo *_Nonnull)timerInfo
                                       stdData:(BLStdData *_Nonnull)stdData
                                    scriptPath:(NSString *_Nullable)scriptPath;


/**
 add/update timer/Delay task to device

 @param did         wifi device did
 @param sdid        sub device did. If sdid = nil, just control wifi device.
 @param taskType    timer type,BL_TIMER_TYPE_LIST = 0;BL_DELAY_TYPE_LIST = 1.
 @param isNew       add or update .
 @param timerInfo   timer task info
 @param stdData     timer task do control data
 @return            result and query now all tasks
 */
- (BLQueryTaskResult *_Nonnull)updateTask:(NSString *_Nonnull)did
                                     sDid:(NSString *_Nullable)sdid
                                 taskType:(BLTimeTypeEnum)taskType
                                    isNew:(BOOL)isNew
                                timerInfo:(BLTimerOrDelayInfo *_Nonnull)timerInfo
                                  stdData:(BLStdData *_Nonnull)stdData;




/**
 add/update period task to device
 
 @param did             wifi device did
 @param sdid            sub device did. If sdid = nil, just control wifi device.
 @param isNew           add or update .
 @param periodInfo      period task info
 @param stdData         period task do control data
 @param scriptPath      Device script. If scriptPath = nil, find device script in default store path.
 @return                result and query now all tasks
 */
- (BLQueryTaskResult *_Nonnull)updateTask:(NSString *_Nonnull)did
                                           sDid:(NSString *_Nullable)sdid
                                            isNew:(BOOL)isNew
                                     periodInfo:(BLPeriodInfo *_Nonnull)periodInfo
                                        stdData:(BLStdData *_Nonnull)stdData
                                     scriptPath:(NSString *_Nullable)scriptPath;
/**
 add/update period task to device
 
 @param did             wifi device did
 @param sdid            sub device did. If sdid = nil, just control wifi device.
 @param isNew           add or update .
 @param periodInfo      period task info
 @param stdData         period task do control data
 @return                result and query now all tasks
 */
- (BLQueryTaskResult *_Nonnull)updateTask:(NSString *_Nonnull)did
                                           sDid:(NSString *_Nullable)sdid
                                          isNew:(BOOL)isNew
                                     periodInfo:(BLPeriodInfo *_Nonnull)periodInfo
                                        stdData:(BLStdData *_Nonnull)stdData;


/**
 add/update Cycle/Random task to device

 @param did         wifi device did
 @param sdid        sub device did. If sdid = nil, just control wifi device.
 @param taskType    timer type,BL_CYCLE_TYPE_LIST = 3;BL_RANDOM_TYPE_LIST = 4.
 @param isNew       add or update .
 @param cycleInfo   cycle task info
 @param stdData1    period task do control data1
 @param stdData2    period task do control data2
 @param scriptPath  Device script. If scriptPath = nil, find device script in default store path.
 @return            result and query now all tasks
 */
- (BLQueryTaskResult *_Nonnull)updateTask:(NSString *_Nonnull)did
                                          sDid:(NSString *_Nullable)sdid
                                    taskType:(BLTimeTypeEnum)taskType
                                        isNew:(BOOL)isNew
                                     cycleInfo:(BLCycleOrRandomInfo *_Nonnull)cycleInfo
                                       stdData1:(BLStdData *_Nonnull)stdData1
                                      stdData2:(BLStdData *_Nonnull)stdData2
                                    scriptPath:(NSString *_Nullable)scriptPath;
/**
 add/update Cycle/Random task to device
 
 @param did         wifi device did
 @param sdid        sub device did. If sdid = nil, just control wifi device.
 @param taskType    timer type,BL_CYCLE_TYPE_LIST = 3;BL_RANDOM_TYPE_LIST = 4.
 @param isNew       add or update .
 @param cycleInfo   cycle task info
 @param stdData1    period task do control data1
 @param stdData2    period task do control data2
 @return            result and query now all tasks
 */
- (BLQueryTaskResult *_Nonnull)updateTask:(NSString *_Nonnull)did
                                     sDid:(NSString *_Nullable)sdid
                                    taskType:(BLTimeTypeEnum)taskType
                                        isNew:(BOOL)isNew
                                cycleInfo:(BLCycleOrRandomInfo *_Nonnull)cycleInfo
                                 stdData1:(BLStdData *_Nonnull)stdData1
                                 stdData2:(BLStdData *_Nonnull)stdData2;


/**
 delete task to device

 @param did         wifi device did
 @param sdid        sub device did. If sdid = nil, just control wifi device.
 @param taskType    timer type.
 @param index       task index
 @param scriptPath  Device script. If scriptPath = nil, find device script in default store path.
 @return            result
 */
- (BLQueryTaskResult *_Nonnull)delTask:(NSString *_Nonnull)did
                                  sDid:(NSString *_Nullable)sdid
                                taskType:(BLTimeTypeEnum)taskType
                                 index:(NSInteger)index
                            scriptPath:(NSString *_Nullable)scriptPath;

/**
 delete task to device
 
 @param did         wifi device did
 @param sdid        sub device did. If sdid = nil, just control wifi device.
 @param taskType    timer type.
 @param index       task index
 @return            result
 */
- (BLQueryTaskResult *_Nonnull)delTask:(NSString *_Nonnull)did
                                  sDid:(NSString *_Nullable)sdid
                              taskType:(BLTimeTypeEnum)taskType
                                 index:(NSInteger)index;


/**
 query task data

 @param did         wifi device did
 @param sdid        sub device did. If sdid = nil, just control wifi device.
 @param taskType    timer type.
 @param index       task index
 @param scriptPath  Device script. If scriptPath = nil, find device script in default store path.
 @return result
 */
- (BLTaskDataResult *_Nonnull)queryTaskData:(NSString *_Nonnull)did
                                       sDid:(NSString *_Nullable)sdid
                                   taskType:(BLTimeTypeEnum)taskType
                                      index:(NSInteger)index
                                 scriptPath:(NSString *_Nullable)scriptPath;
/**
 query task data
 
 @param did         wifi device did
 @param sdid        sub device did. If sdid = nil, just control wifi device.
 @param taskType    timer type.
 @param index       task index
 @return result
 */
- (BLTaskDataResult *_Nonnull)queryTaskData:(NSString *_Nonnull)did
                                       sDid:(NSString *_Nullable)sdid
                                   taskType:(BLTimeTypeEnum)taskType
                                      index:(NSInteger)index;

/**
 Query one product ui version by pid

 @param pid             Product pid
 @return                Query result
 */
- (BLQueryResourceVersionResult *_Nonnull)queryUIVersion:(NSString *_Nonnull)pid;

/**
 Query products ui version by pids
 
 @param pidList         Product pids
 @return                Query result
 */
- (BLQueryResourceVersionResult *_Nonnull)queryUIVersionWithList:(NSArray *_Nonnull)pidList;

/**
 Query one product script version by pid
 
 @param pid             Product pid
 @return                Query result
 */
- (BLQueryResourceVersionResult *_Nonnull)queryScriptVersion:(NSString *_Nonnull)pid;

/**
 Query products script version by pids
 
 @param pidList         Product pids
 @return                Query result
 */
- (BLQueryResourceVersionResult *_Nonnull)queryScriptVersionWithList:(NSArray *_Nonnull)pidList;


/**
 Query device's ui store path by pid. Default is ../Let/ui/$(pid)/

 @param pid             Product pid
 @return                UI path
 */
- (NSString *_Nonnull)queryUIPath:(NSString *_Nonnull)pid;

/**
 Query ircode script store path. Default is ../Let/ircode/

 @return                IRCode script path
 */
- (NSString *_Nonnull)queryIRCodeScriptPath;


/**
 Query control script store path. Default is ../Let/script/

 @return                Control script path
 */
- (NSString *_Nonnull)queryScriptPath;

/**
 Query control script file name with full path by pid. Default is ../Let/script/$(pid).xx

 @param pid             Product pid
 @return                Full path
 */
- (NSString *_Nonnull)queryScriptFileName:(NSString *_Nonnull)pid;

/**
 Download device control ui.
 This ui is zip package, you must unzip this package in download path to ./$(pid)/ by yourself.

 @param pid                 Product pid
 @param completionHandler   Callback with download result
 */
- (void)downloadUI:(nonnull NSString *)pid completionHandler:(nullable void (^)(BLDownloadResult * _Nonnull result))completionHandler;

/**
 Download device control script.
 
 @param pid                 Product pid
 @param completionHandler   Callback with download result
 */
- (void)downloadScript:(nonnull NSString *)pid completionHandler:(nullable void (^)(BLDownloadResult * _Nonnull result))completionHandler;

/**
 Notice WiFi device to start scan sub devices

 @param did                 WiFi device did
 @param subPid              Scan sub device product pid. If subPid = nil, scan all sub devices.
 @return                    Notice result
 */
- (BLSubdevBaseResult *_Nonnull)subDevScanStartWithDid:(NSString *_Nonnull)did subPid:(NSString *_Nullable)subPid;

/**
 Notice WiFi device to stop scan sub devices
 
 @param did                 WiFi device did
 @return                    Notice result
 */
- (BLSubdevBaseResult *_Nonnull)subDevScanStopWithDid:(NSString *_Nonnull)did;

/**
 Query WiFi device new scan sub devices

 @param did                 WiFi device did
 @param index               Query page index
 @param count               Query page count
 @return                    Query result
 */
- (BLSubDevListResult *_Nullable)subDevNewListQueryWithDid:(NSString *_Nullable)did index:(NSInteger)index count:(NSInteger)count subPid:(NSString *_Nullable)subPid;

/**
 Notice WiFi device to add a sub device

 @param did                 WiFi device did
 @param subDevInfo          Sub device info
 @return                    Notice result
 */
- (BLSubdevBaseResult *_Nonnull)subDevAddWithDid:(NSString *_Nonnull)did subDevInfo:(BLDNADevice *_Nonnull)subDevInfo;

/**
 Query add new sub device to WiFi device result
 
 @param did                 WiFi device did
 @param sDid                Sub device did
 @return                    Add result
 */
- (BLSubDevAddResult *_Nonnull)subDevAddResultQueryWithDid:(NSString *_Nonnull)did subDevDid:(NSString *_Nonnull)sDid;

/**
 Delete sub deivce from WiFi device

 @param did                 WiFi device did
 @param sDid                Sub device did
 @return                    Delete result
 */
- (BLSubdevBaseResult *_Nonnull)subDevDelWithDid:(NSString *_Nonnull)did subDevDid:(NSString *_Nonnull)sDid;

/**
 Modify sub device info from WiFi device

 @param did                 WiFi device did
 @param sDid                Sub device did
 @param name                Sub device new name
 @return                    Modify result
 */
- (BLSubdevBaseResult *_Nonnull)subDevModifyDid:(NSString *_Nonnull)did subDevDid:(NSString *_Nonnull)sDid name:(NSString *_Nonnull)name;

/**
 Query sub devices have added in WiFi device
 
 @param did                 WiFi device did
 @param index               Query page index
 @param count               Query page count
 @return                    Query result
 */
- (BLSubDevListResult *_Nonnull)subDevListQueryWithDid:(NSString *_Nonnull)did index:(NSInteger)index count:(NSInteger)count;

/**
 Config device AP setting mode.
 
 @param ssid                AP SSID
 @param password            AP password
 @param type                AP type
 @param timeout             AP config timeout
 @return                    Config result
 */
- (BLAPConfigResult *_Nonnull)deviceAPConfig:(NSString *_Nonnull)ssid password:(NSString *_Nonnull)password type:(NSInteger)type timeout:(NSUInteger)timeout;

/**
 Config device AP setting mode. Default config timeout 10s
 
 @param ssid                AP SSID
 @param password            AP password
 @param type                AP type
 @return                    Config result
 */
- (BLAPConfigResult *_Nonnull)deviceAPConfig:(NSString *_Nonnull)ssid password:(NSString *_Nonnull)password type:(NSInteger)type;

/**
 Get AP List
 
 @param timeout             Get timeout
 @return                    Get result
 */
- (BLGetAPListResult *_Nonnull)deviceAPList:(NSInteger)timeout;

/**
 Query device dna control raw data
 
 @param did                 Device did
 @return                    Raw data list
 */
- (NSArray *_Nonnull)queryDnacontrolDataWithDid:(NSString *_Nonnull)did;

/**
 Query device data reporting

 @param did Device did
 @param familyId familyId can be nil
 @param startTime query device data startTime
 @param endTime query device data endTime
 @return result
 */
- (BLBaseBodyResult *_Nonnull)queryDeviceDataWithDid:(NSString *_Nonnull)did familyId:(NSString *_Nullable)familyId startTime:(NSString *_Nonnull)startTime endTime:(NSString*_Nonnull)endTime type:(NSString *_Nonnull)type;


/**
 Query RMAC ircode script infomation.

 @param script              Ircode script store path
 @return                    Callback with query result
 */
- (BLIRCodeInfoResult *_Nonnull)queryRMACIRCodeInfomationWithScript:(NSString *_Nonnull)script;


/**
 Query RMAC ircode hex string

 @param script              Ircode script store path
 @param params              AC status to change
 @return                    Query result with ircode hex string
 */
- (BLIRCodeDataResult *_Nonnull)queryRMACIRCodeDataWithScript:(NSString *_Nonnull)script params:(BLQueryIRCodeParams *_Nonnull)params;


/**
 startDeviceRemoteHttpControl
 */
- (void)startDeviceRemoteHttpControl;


/**
 stopDeviceRemoteHttpControl
 */
- (void)stopDeviceRemoteHttpControl;
@end
