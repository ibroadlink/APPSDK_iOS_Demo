//
//  ConfigParam.m
//  Let
//
//  Created by yzm on 16/5/13.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLConfigParam.h"
#import "BLApiUrls.h"

@interface BLConfigParam()

@end

@implementation BLConfigParam

static BLConfigParam *sharedConfigParam = nil;

+ (instancetype)sharedConfigParam {
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedConfigParam = [[BLConfigParam alloc] init];
    });
    
    return sharedConfigParam;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        self.sdkFileSavePath = [documentsDirectory stringByAppendingPathComponent:@"Let"];
        
        self.httpTimeout = 30 * 1000;
        self.controllerProbeInterval = 3000;
        self.controllerLocalTimeout = 2000;
        self.controllerRemoteTimeout = 4000;
        self.controllerNetMode = BL_NET_DEFAULT;
        self.controllerSendCount = 1;
        self.controllerEasyConfigTimeout = 75;
        self.controllerQueryCount = 8;
        self.controllerScriptDownloadVersion = 0;
        self.controllerResendMode = 0;
        self.dataReportCount = 20;
        self.ClientCertificate = nil;
        self.ServerCertificate = nil;
        
        // 添加本地通知接收
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLoginDic:) name:@"LetLoginSuccess" object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LetLoginSuccess" object:nil];
}

- (void)setLicenseId:(NSString *)licenseId {
    
    _licenseId = licenseId;
    
    if (licenseId != nil) {
        self.accountHost = [NSString stringWithFormat:@"https://%@bizaccount.ibroadlink.com", licenseId];
        self.appManageHost = [NSString stringWithFormat:@"https://%@bizappmanage.ibroadlink.com", licenseId];
        self.familyHost = [NSString stringWithFormat:@"https://%@bizihcv0.ibroadlink.com", licenseId];
        self.iRCodeHost = [NSString stringWithFormat:@"https://%@rccode.ibroadlink.com", licenseId];
        self.familyPrivateHost = [NSString stringWithFormat:@"https://%@bizpd.ibroadlink.com",licenseId];
        self.oauthHost = [NSString stringWithFormat:@"https://%@oauth.ibroadlink.com", licenseId];
        self.pickerHost = [NSString stringWithFormat:@"https://%@bizappdata.ibroadlink.com", licenseId];
        self.cloudHost = [NSString stringWithFormat:@"https://%@appfont.ibroadlink.com", licenseId];
        
        self.appServiceHost = [NSString stringWithFormat:@"https://%@appservice.ibroadlink.com", licenseId];
    }
}

- (void)setAccountHost:(NSString *)accountHost {
    [[BLApiUrls sharedApiUrl] setBaseUrl:accountHost];
    _accountHost = accountHost;
}

- (void)setAppManageHost:(NSString *)appManageHost {
    [[BLApiUrls sharedApiUrl] setBaseAppManageUrl:appManageHost];
    _appManageHost = appManageHost;
}

- (void)setIRCodeHost:(NSString *)iRCodeHost {
    [[BLApiUrls sharedApiUrl] setBaseIRCodeUrl:iRCodeHost];
    _iRCodeHost = iRCodeHost;
}

- (void)setFamilyHost:(NSString *)familyHost {
    [[BLApiUrls sharedApiUrl] setBaseFamilyUrl:familyHost];
    _familyHost = familyHost;
}

- (void)setFamilyPrivateHost:(NSString *)familyPrivateHost {
    [[BLApiUrls sharedApiUrl] setBaseFamilyPrivateUrl:familyPrivateHost];
    _familyPrivateHost = familyPrivateHost;
}

- (void)setOauthHost:(NSString *)oauthHost {
    [[BLApiUrls sharedApiUrl] setBaseOauthUrl:oauthHost];
    _oauthHost = oauthHost;
}

- (void)setDataServiceHost:(NSString *)dataServiceHost {
    [[BLApiUrls sharedApiUrl] setBaseDataServiceUrl:dataServiceHost];
    _dataServiceHost = dataServiceHost;
    
}

- (void)setPickerHost:(NSString *)pickerHost {
    [[BLApiUrls sharedApiUrl] setBasePickUrl:pickerHost];
    _pickerHost = pickerHost;
}

- (void)setCloudHost:(NSString *)cloudHost {
    [[BLApiUrls sharedApiUrl] setBaseCloudUrl:cloudHost];
    _cloudHost = cloudHost;
}

- (void)setAppServiceHost:(NSString *)appServiceHost {
    _appServiceHost = appServiceHost;
    
    if (self.appServiceEnable) {
        self.accountHost = _appServiceHost;
        self.appManageHost = _appServiceHost;
        self.familyHost = _appServiceHost;
        self.iRCodeHost = _appServiceHost;
        self.familyPrivateHost = _appServiceHost;
        self.oauthHost = _appServiceHost;
        self.pickerHost = _appServiceHost;
        self.cloudHost = _appServiceHost;
    }
}

- (void)setAppServiceEnable:(NSUInteger)appServiceEnable {
    _appServiceEnable = appServiceEnable;
    
    if (appServiceEnable) {
        self.accountHost = self.appServiceHost;
        self.appManageHost = self.appServiceHost;
        self.familyHost = self.appServiceHost;
        self.iRCodeHost = self.appServiceHost;
        self.familyPrivateHost = self.appServiceHost;
        self.oauthHost = self.appServiceHost;
        self.pickerHost = self.appServiceHost;
        self.cloudHost = self.appServiceHost;
    } else {
        self.accountHost = [NSString stringWithFormat:@"https://%@bizaccount.ibroadlink.com", self.licenseId];
        self.appManageHost = [NSString stringWithFormat:@"https://%@bizappmanage.ibroadlink.com", self.licenseId];
        self.familyHost = [NSString stringWithFormat:@"https://%@bizihcv0.ibroadlink.com", self.licenseId];
        self.iRCodeHost = [NSString stringWithFormat:@"https://%@rccode.ibroadlink.com", self.licenseId];
        self.familyPrivateHost = [NSString stringWithFormat:@"https://%@bizpd.ibroadlink.com",self.licenseId];
        self.oauthHost = [NSString stringWithFormat:@"https://%@oauth.ibroadlink.com", self.licenseId];
        self.pickerHost = [NSString stringWithFormat:@"https://%@bizappdata.ibroadlink.com", self.licenseId];
        self.cloudHost = [NSString stringWithFormat:@"https://%@appfont.ibroadlink.com", self.licenseId];
    }
    
    NSDictionary *dic = @{
                          @"AppServiceEnable" : @(appServiceEnable)
                          };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LetAppServiceEnable" object:nil userInfo:dic];
}

#pragma mark - notice method
- (void)getLoginDic:(NSNotification *)notify {
    NSDictionary *loginDic = notify.userInfo;
    
    self.userid = loginDic[@"loginUserid"];
    self.loginSession = loginDic[@"loginSession"];
}

@end
