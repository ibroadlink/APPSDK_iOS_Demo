//
//  ApiUrls.m
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLApiUrls.h"
#import "BLCommonTools.h"
#include <netdb.h>
#include <sys/socket.h>
#include <arpa/inet.h>
@interface BLApiUrls ()

@property (nonatomic, copy) NSString *baseUrl;

@property (nonatomic, copy) NSString *baseProxyUrl;

@property (nonatomic, copy) NSString *baseAppManageUrl;

@property (nonatomic, copy) NSString *baseFamilyUrl;

@property (nonatomic, copy) NSString *baseFamilyPrivateUrl;

@property (nonatomic, copy) NSString *basePickUrl;

@property (nonatomic, copy) NSString *baseOauthUrl;

@property (nonatomic, copy) NSString *baseDataServiceUrl;

@property (nonatomic, copy) NSString *baseCloudUrl;
@end

@implementation BLApiUrls

static BLApiUrls *apiUrl = nil;

+ (instancetype)sharedApiUrl {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apiUrl = [[BLApiUrls alloc] init];
    });
    return apiUrl;
}

- (NSString *)getTimestampUrl {
    return [_baseUrl stringByAppendingString:@"/account/api"];
}

- (NSString *)getLoginUrl {
    return [_baseUrl stringByAppendingString:@"/account/login"];
}

- (NSString *)getRegVCodeUrl {
    return [_baseUrl stringByAppendingString:@"/account/newregcode"];
}

- (NSString *)getRegisterUrl {
    return [_baseUrl stringByAppendingString:@"/account/register"];
}

- (NSString *)getModifyGenderUrl {
    return [_baseUrl stringByAppendingString:@"/account/modifysexandbirth"];
}

- (NSString *)getModifyUserIconUrl {
    return [_baseUrl stringByAppendingString:@"/account/modifyicon"];
}

- (NSString *)getModifyNicknameUrl {
    return [_baseUrl stringByAppendingString:@"/account/modifynickname"];
}

- (NSString *)getUserinfoUrl {
    return [_baseUrl stringByAppendingString:@"/account/usersketchyinfo"];
}

- (NSString *)getModifyPasswordUrl {
    return [_baseUrl stringByAppendingString:@"/account/modifypwd"];
}

- (NSString *)getModifyVCodeUrl {
    return [_baseUrl stringByAppendingString:@"/account/modifycode"];
}

- (NSString *)getModifyPhoneEmailUrl {
    return [_baseUrl stringByAppendingString:@"/account/modifyinfo"];
}

- (NSString *)getFindPasswordUrl {
    return [_baseUrl stringByAppendingString:@"/account/retrivecode"];
}

- (NSString *)getRetrivePasswordurl {
    return [_baseUrl stringByAppendingString:@"/account/retrivepwd"];
}

- (NSString *)getCheckUserPasswordUrl {
    return [_baseUrl stringByAppendingString:@"/account/checkinfo"];
}

- (NSString *)getUserPhoneEmailUrl {
    return [_baseUrl stringByAppendingString:@"/account/getuserinfo"];
}

- (NSString *)thirdAuthUrl {
    return [_baseUrl stringByAppendingString:@"/account/thirdauth"];
}

- (NSString *)fastLoginUrl {
    return [_baseUrl stringByAppendingString:@"/account/fastlogin"];
}

- (NSString *)fastLoginVCodeUrl {
    return [_baseUrl stringByAppendingString:@"/account/fastlogincode"];
}

- (NSString *)fastLoginModifyVCodeUrl {
    return [_baseUrl stringByAppendingString:@"/account/modifypwdcode"];
}

- (NSString *)fastLoginModifyPasswordUrl {
    return [_baseUrl stringByAppendingString:@"/account/modifypwdbycode"];
}

- (NSString *)oauthLoginUrl {
    return [_baseUrl stringByAppendingString:@"/account/thirdoauth/login"];
}

- (NSString *)queryBindInfoUrl {
    return [_baseUrl stringByAppendingString:@"/account/thirdoauth/querybindinfo"];
}

- (NSString *)bindThirdAccount {
    return [_baseUrl stringByAppendingString:@"/account/thirdoauth/bind"];
}

- (NSString *)unbindThirdAccount {
    return [_baseUrl stringByAppendingString:@"/account/thirdoauth/unbind"];
}

- (NSString *)destroyVCodeUrl;{
    return [_baseUrl stringByAppendingString:@"/account/newdestroycode"];
}

- (NSString *)destroyAccountUrl{
    return [_baseUrl stringByAppendingString:@"/account/destroy"];
}

- (NSString *)destroyUnBindAccountUrl{
    return [_baseUrl stringByAppendingString:@"/account/unbinddestroy"];
}
#pragma mark - 第三方认证接口
- (NSString *)dnaProxyAuthUrl {
    return [_baseProxyUrl stringByAppendingString:@"/dnaproxy/v1/app/auth"];
}

- (NSString *)dnaProxyDisauthUrl {
    return [_baseProxyUrl stringByAppendingString:@"/dnaproxy/v1/app/disauth"];
}

#pragma mark - APP 后台接口
- (NSString *)appManageVersionQueryNewUrl {
    return [_baseAppManageUrl stringByAppendingString:@"/ec4/v1/system/resource/resourceversionbypids"];
}

- (NSString *)appManageDownloadNewUrl {
    return [_baseAppManageUrl stringByAppendingString:@"/ec4/v1/system/resource/download"];
}

- (NSString *)appManageVersionQueryUrl {
    return [_baseAppManageUrl stringByAppendingString:@"/ec4/v1/system/getresourceversionbypid"];
}

- (NSString *)appManageDownloadUrl {
    return [_baseAppManageUrl stringByAppendingString:@"/ec4/v1/system/downloadproductresource"];
}

- (NSString *)appManageGetProductBrandList {
    return [_baseAppManageUrl stringByAppendingString:@"/ec4/v1/system/language/productbrand/list"];
}

- (NSString *)appManageGetBrandFilterList {
    return [_baseAppManageUrl stringByAppendingString:@"/ec4/v1/system/language/productbrandfilter/list"];
}

#pragma mark - 红码相关接口
- (NSString *)iRCodeCommonUrlWithPath:(NSString *)path {
    return [_baseIRCodeUrl stringByAppendingString:path];
}

- (NSString *)iRCodeQueryDeviceTypeUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/app/getdevtype"];
}

- (NSString *)iRCodeQueryDeviceBrandUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/app/getbrand"];
}

- (NSString *)iRCodeQueryDeviceVersionUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/app/getversion"];
}

//需补充域名用于下载红码，interimid为临时ID
- (NSString *)iRCodeGetScriptDownloadUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/app/geturlbybrandversion"];
}

- (NSString *)iRCodeGetCloudScriptDownloadUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/app/geturlbybrandversion?mtag=app"];
}

- (NSString *)iRCodeRecognizeDataUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/cloudac/recognizeirdata?mtag=app"];
}

- (NSString *)iRCodeSTBProviderGetScriptDownloadUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/stb/geturlbyarea"];
}

- (NSString *)iRCodeSTBChannelListUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/stb/getchannel"];
}

//机顶盒红外码
- (NSString *)irCodeSubAreaGetUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/app/getsubarea"];
}

- (NSString *)irCodeAreaInfoGetUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/app/getareainfobyid"];
}

- (NSString *)iRCodeSTBGetUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/stb/getprovider"];
}

- (NSString *)iRCodeSTBByNameGetUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/stb/getproviderinfobylocatename"];
}

- (NSString *)iRCodeSTBBrandsGetUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/stb/getproviderbrand"];
}

//红码匹配树接口
- (NSString *)iRCodeMatchTreeUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/app/getmatchtree"];
}
//红码下载(新版)
- (NSString *)iRCodeDownloadUrl {
    return [_baseIRCodeUrl stringByAppendingString:@"/publicircode/v2/app/getircode"];
}

#pragma mark - 家庭相关接口
- (NSString *)familyCommonUrlWithPath:(NSString *)path {
    return [_baseFamilyUrl stringByAppendingString:path];
}

- (NSString *)familyTimestrampAndKeyUrl {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/common/api"];
}

//家庭自身相关
- (NSString *)familyIdListUrl {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/user/getfamilyid"];
}

- (NSString *)familyBaseInfoUrl {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/user/getbasefamilylist"];
}

- (NSString *)familyVersionUrl {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/family/getversion"];
}

- (NSString *)familyAllInfoUrl {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/family/getallinfo"];
}

- (NSString *)familyDetailUrl {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/family/getfamilyversioninfo"];
}

- (NSString *)familyCreateDefaultUrl {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/family/default"];
}

- (NSString *)familyAddUrl {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/family/add"];
}

- (NSString *)familyInfoModifyUrl {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/family/modifyinfo"];
}

- (NSString *)familyIconModifyUrl {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/family/modifyicon"];
}

- (NSString *)familyDelUrl {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/family/del"];
}

//- (NSString *)familyPrivateDataUpUrl {
//    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/family/upsertprivatedata"];
//}
//
//- (NSString *)familyPrivateDataGetUrl {
//    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/family/getprivatedata"];
//}

- (NSString *)familyChildDirGetURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/system/getchilddir"];
}

- (NSString *)familyScenceDetailURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/system/scenedetail"];
}

//- (NSString *)familyPicAddURL {
//    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/system/addpic"];
//}

//- (NSString *)familyIrcodeIconDefineURL {
//    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/system/defineircodeicon"];
//}

//家庭房间相关
- (NSString *)familyRoomDefineUrl {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/system/defineroom"];
}

- (NSString *)familyRoomListManageUrl {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/room/manage"];
}

//家庭成员相关
- (NSString *)familyMemberInvitedQrcodeRequestURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/member/invited/reqqrcode"];
}

- (NSString *)familyMemberInvitedQrcodeScanInfoURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/member/invited/scanqrcode"];
}

- (NSString *)familyMemberInvitedQrcodeJoinURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/member/invited/joinfamily"];
}

- (NSString *)familyMemberJoinURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/member/joinpublicfamily"];
}

- (NSString *)familyMemberQuitURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/member/quitfamily"];
}

- (NSString *)familyMemberDelURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/member/delfamilymember"];
}

- (NSString *)familyMemberInfoURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/member/getfamilymember"];
}

//家庭设备相关
//- (NSString *)familyDeviceInURL {
//    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/dev/getfamily"];
//}

- (NSString *)familyDeviceConfigedListURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/dev/getconfigdev"];
}

//- (NSString *)familyDeviceMoveURL {
//    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/dev/movedev"];
//}

- (NSString *)familyDeviceDelURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/dev/deldev"];
}

//家庭设备认证
//- (NSString *)familyAuthCenterAddURL {
//    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/authcenter/auth/add"];
//}
//
//- (NSString *)familyAuthCenterQueryURL {
//    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/authcenter/auth/query"];
//}

//家庭模块相关
- (NSString *)familyModuleAddURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/module/add"];
}

- (NSString *)familyModuleAddListURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/module/addlist"];
}

- (NSString *)familyModuleDelURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/module/del"];
}

- (NSString *)familyModuleModifyURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/module/modify"];
}

- (NSString *)familyModuleModifyBasicInfoURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/module/modifybasicinfo"];
}

//- (NSString *)familyModuleModifyOrderURL {
//    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/module/modifyorder"];
//}

- (NSString *)familyModuleModifyFlagURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/module/modifyflag"];
}

- (NSString *)familyModuleModifyNameURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/module/modifyname"];
}

//- (NSString *)familyModuleModifyRelationURL {
//    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/module/modifyrelation"];
//}

- (NSString *)familyModuleModifyRoomURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/module/movemodule"];
}

- (NSString *)familyModuleModifyInfoAndRoomURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/module/modifyandmovemodule"];
}

//家庭峰谷电
- (NSString *)familyElectricInfoConfigURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/electricinfo/config"];
}

- (NSString *)familyElectricInfoQueryURL {
    return [_baseFamilyUrl stringByAppendingString:@"/ec4/v1/electricinfo/query"];
}

/** 获取家庭私有数据唯一ID 用于虚拟子设备Did**/
- (NSString *)familyPrivateDataIdURL {
    return [_baseFamilyPrivateUrl stringByAppendingString:@"/ec4/v1/family/privatedata/getid"];
}
/** 获取家庭私有数据更新 **/
- (NSString *)familyPrivateDataUpdateURL {
    return [_baseFamilyPrivateUrl stringByAppendingString:@"/ec4/v1/family/privatedata/update"];
}
/** 获取家庭私有数据删除 **/
- (NSString *)familyPrivateDataDeleteURL {
    return [_baseFamilyPrivateUrl stringByAppendingString:@"/ec4/v1/family/privatedata/del"];
}
/** 获取家庭私有数据查询 **/
- (NSString *)familyPrivateDataQueryURl {
    return [_baseFamilyPrivateUrl stringByAppendingString:@"/ec4/v1/family/privatedata/query"];
}



/** 家庭增加红码绑定 **/
- (NSString *)familyIrdaAddURL {
    return [_baseFamilyUrl stringByAppendingString:@"/appsync/group/ircode/add"];
}

/** 家庭删除红码绑定 **/
- (NSString *)familyIrdaDelURL {
    return [_baseFamilyUrl stringByAppendingString:@"/appsync/group/ircode/del"];
}

/** 家庭更新红码功能按键 **/
- (NSString *)familyIrdaUpdatefunctionURL {
    return [_baseFamilyUrl stringByAppendingString:@"/appsync/group/ircode/updatefunction"];
}

/** 家庭删除红码功能按键 **/
- (NSString *)familyIrdaDelfunctionURL {
    return [_baseFamilyUrl stringByAppendingString:@"/appsync/group/ircode/delfunction"];
}

/** 家庭红码查询 **/
- (NSString *)familyIrdaQueryURL {
    return [_baseFamilyUrl stringByAppendingString:@"/appsync/group/ircode/query"];
}

/** 家庭查询频道 **/
- (NSString *)familyChannellistQueryURL {
    return [_baseFamilyUrl stringByAppendingString:@"/appsync/group/channellist/query"];
}

/** 家庭新增频道 **/
- (NSString *)familyChannellistAddURL {
    return [_baseFamilyUrl stringByAppendingString:@"/appsync/group/channellist/add"];
}

/** 家庭更新频道 **/
- (NSString *)familyChannellistModifyURL {
    return [_baseFamilyUrl stringByAppendingString:@"/appsync/group/channellist/modify"];
}






/** 数据统计上报 **/
- (NSString *)pickUpdateDataURL {
    return [_basePickUrl stringByAppendingString:@"/data/v1/appdata/upload?source=app&datatype=app_user_v1"];
}

//设备上报数据的统计报表查询
- (NSString *)getDataReportURL {
    return [_baseDataServiceUrl stringByAppendingString:@"/dataservice/v1/device/stats"];
}

//场景模块相关
- (NSString *)sceneModuleAddURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/module/add"];
}
- (NSString *)sceneModuleAddListURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/module/addlist"];
}

- (NSString *)sceneModuleDelURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/module/del"];
}

- (NSString *)sceneModuleModifyURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/module/modify"];
}

- (NSString *)sceneModuleModifyBasicInfoURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/module/modifybasicinfo"];
}

- (NSString *)sceneModuleModifyFlagURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/module/modifyflag"];
}
- (NSString *)sceneModuleModifyNameURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/module/modifyname"];
}

- (NSString *)sceneModuleModifyRoomURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/module/movemodule"];
}

- (NSString *)sceneModuleModifyInfoAndRoomURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/module/modifyandmovemodule"];
}

/** 场景下发 **/
- (NSString *)sceneControlURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/scene/control"];
}

/** 场景取消 **/
- (NSString *)sceneCancelURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/scene/cancel"];
}

/** 场景历史任务查询 **/
- (NSString *)sceneHistoryURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/scene/history"];
}

/** 场景详情查询 **/
- (NSString *)sceneDeteailURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/scene/detail"];
}

/** 实时任务查询 **/
- (NSString *)sceneRunningtaskURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/scene/runningtask"];
}

/** 添加云定时 **/
- (NSString *)addTimertaskURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/timertask/add"];
}

/** 删除云定时 **/
- (NSString *)deleteTimertaskURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/timertask/delete"];
}

/** 修改云定时 **/
- (NSString *)modifyTimertaskURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/timertask/modify"];
}

/** 查询云定时 **/
- (NSString *)queryTimertaskURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/timertask/query"];
}

/** 联动信息增加 **/
- (NSString *)addLinkageURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/linkage/add"];
}

/** 联动信息删除 **/
- (NSString *)deleteLinkageURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/linkage/delete"];
}

/** 联动信息查询 **/
- (NSString *)queryLinkageURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/linkage/parsequery"];
}

/** 联动任务生效 **/
- (NSString *)upsertTriggerURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/trigger/upsert"];
}

/** 联动任务停止 **/
- (NSString *)deleteTriggerURL {
    return [_baseCloudUrl stringByAppendingString:@"/appfront/v1/trigger/delete"];
}

#pragma mark - OAuth Server Request
- (NSString *)oauthLoginByTokenURL {
    return _baseOauthUrl;
}

- (NSString *)oauthLoginDataURL {
    return [_baseOauthUrl stringByAppendingString:@"/oauth/v2/server/getlogindata"];
}

- (NSString *)oauthLoginInfoURL {
    return [_baseOauthUrl stringByAppendingString:@"/oauth/v2/login/info"];
}

- (NSString *)oauthTokenURL {
    return [_baseOauthUrl stringByAppendingString:@"/oauth/v2/token"];
}



- (NSString *)checkApiUrlHosts {
    NSMutableDictionary *hostResult = [NSMutableDictionary dictionary];
    NSArray *hostNameList = @[_baseUrl,_baseFamilyUrl,_baseAppManageUrl,_baseIRCodeUrl,_baseFamilyPrivateUrl,_baseCloudUrl];
    for (NSString *hostName in hostNameList) {
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
         NSString *hostNameStr = [hostName substringFromIndex:8];
        NSString *ip = [self getIPWithHostName:hostNameStr];
        if (ip != nil) {
            [self connect:ip];
            CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);
//            NSLog(@"time_total: %f ", endTime);
            NSMutableDictionary *hostDic = [NSMutableDictionary dictionary];
            [hostDic setObject:ip forKey:@"ip"];
            [hostDic setObject:[NSString stringWithFormat:@"%f",endTime] forKey:@"time_total"];
            [hostResult setObject:hostDic forKey:hostNameStr];
        }else{
            [hostResult setObject:@"Can not find address" forKey:hostNameStr];
        }        
    }
    NSString *result = [BLCommonTools serializeMessage:hostResult];
    return result;
}


- (NSString*)getIPWithHostName:(const NSString*)hostName {
   
//    NSLog(@"hostName======%@",hostName);
    const char *hostN= [hostName UTF8String];
    struct hostent* phot;
    @try {
        phot = gethostbyname(hostN);
    } @catch (NSException *exception) {
        return nil;
    }
    struct in_addr ip_addr;
    if (phot == NULL) {
//        NSLog(@"域名解析失败");
        return nil;
    }
    memcpy(&ip_addr, phot->h_addr_list[0], 4);
    char ip[20] = {0}; inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    NSString* strIPAddress = [NSString stringWithUTF8String:ip];
//    NSLog(@"ip=====%@",strIPAddress);
    return strIPAddress;
}

- (void)connect:(NSString *)hostAddress
{
    int clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (clientSocket > 0) {
//        NSLog(@"创建客户端Socket成功");
    }
    
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(80);
    addr.sin_addr.s_addr = inet_addr(hostAddress.UTF8String);
    
    int isConnected = connect(clientSocket, (const struct sockaddr *)&addr, sizeof(addr));
    if (isConnected == 0) {
//        NSLog(@"连接到服务器成功");
    }
    
//    NSString *sendMsg = @"GET / HTTP/1.1\r\n"
//    "Host: www.baidu.com\r\n"
//    "User-Agent: iphone\r\n"
//    "Connection: close\r\n\r\n"
//    ;
    
//    ssize_t sendCount = send(clientSocket, sendMsg.UTF8String, strlen(sendMsg.UTF8String), 0);
//    NSLog(@"发送字符数 %ld",sendCount);
    
    // 创建接收服务器发送的数据的容器 / 缓冲区 ,并且指定了容量
    uint8_t buffer[1024];
    // 需要创建一个容器
    NSMutableData *dataM = [NSMutableData data];
    
    // 循环的接收服务器发送的数据
    ssize_t recvCount = -1;
    while (recvCount != 0) {
        // 值接收了一次
        recvCount = recv(clientSocket, buffer, sizeof(buffer), 0);
//        NSLog(@"接收的内容数 %ld",recvCount);
        [dataM appendBytes:buffer length:recvCount];
    }
    
    // 5.关闭Socket
    close(clientSocket);
}

@end
