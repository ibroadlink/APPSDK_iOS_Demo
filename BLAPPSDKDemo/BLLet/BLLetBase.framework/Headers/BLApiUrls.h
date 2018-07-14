//
//  ApiUrls.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLApiUrls : NSObject

@property (nonatomic, strong) NSString *baseIRCodeUrl;

+ (instancetype)sharedApiUrl;
/**
 *  检查服务器域名部署情况
 */
- (NSString *)checkApiUrlHosts;

/**
 *  设置服务器URL域名
 *
 *  @param baseUrl 域名
 */
- (void)setBaseUrl:(NSString *)baseUrl;

/**
 设置Proxy服务器域名URL

 @param baseProxyUrl 服务器域名URL
 */
- (void)setBaseProxyUrl:(NSString *)baseProxyUrl;

/**
 设置APP后台服务器域名URL

 @param baseAppManageUrl 服务器域名URL
 */
- (void)setBaseAppManageUrl:(NSString *)baseAppManageUrl;

/**
 设置红码相关服务器域名URL

 @param baseIRCodeUrl 服务器域名URL
 */
- (void)setBaseIRCodeUrl:(NSString *)baseIRCodeUrl;

/**
 设置家庭相关服务器域名URL

 @param baseFamilyUrl 服务器域名URL
 */
- (void)setBaseFamilyUrl:(NSString *)baseFamilyUrl;

/**
 设置家庭私有数据相关服务器域名URL
 
 @param baseFamilyPrivateUrl 服务器域名URL
 */
- (void)setBaseFamilyPrivateUrl:(NSString *)baseFamilyPrivateUrl;
/**
 设置统计系统服务器域名URL
 
 @param basePickUrl 服务器域名URL
 */
- (void)setBasePickUrl:(NSString *)basePickUrl;

/**
 设置认证服务器域名URL

 @param baseOauthUrl  服务器域名URL
 */
- (void)setBaseOauthUrl:(NSString *)baseOauthUrl;

/**
 设置设备数据上报服务器域名

 @param baseDataServiceUrl 服务器域名URL
 */
- (void)setBaseDataServiceUrl:(NSString *)baseDataServiceUrl;

/**
 设置云定时服务器域名

 @param baseCloudUrl 服务器域名URL
 */
- (void)setBaseCloudUrl:(NSString *)baseCloudUrl;
/**
 *  获取请求时间的URL
 *
 *  @return URL地址
 */
- (NSString *)getTimestampUrl;

/**
 *  获取账户登录URL
 *
 *  @return URL地址
 */
- (NSString *)getLoginUrl;

/**
 *  获取手机验证码URL
 *
 *  @return URL地址
 */
- (NSString *)getRegVCodeUrl;

/**
 *  获取注册用户的URL
 *
 *  @return URL地址
 */
- (NSString *)getRegisterUrl;


/**
 修改用户性别和生日

 @return URL地址
 */
- (NSString *)getModifyGenderUrl;

/**
 *  获取修改用户头像的URL
 *
 *  @return URL地址
 */
- (NSString *)getModifyUserIconUrl;

/**
 *  获取修改用户昵称的URL
 *
 *  @return URL地址
 */
- (NSString *)getModifyNicknameUrl;

/**
 *  获取用户信息的URL
 *
 *  @return URL地址
 */
- (NSString *)getUserinfoUrl;

/**
 *  获取修改用户密码的URL
 *
 *  @return URL地址
 */
- (NSString *)getModifyPasswordUrl;

/**
 *  获取修改手机邮箱验证码的URL
 *
 *  @return URL地址
 */
- (NSString *)getModifyVCodeUrl;

/**
 *  获取修改手机号码或邮箱地址的URL
 *
 *  @return URL地址
 */
- (NSString *)getModifyPhoneEmailUrl;

/**
 *  获取找回密码URL
 *
 *  @return URL地址
 */
- (NSString *)getFindPasswordUrl;

/**
 *  获取重置密码URL
 *
 *  @return URL地址
 */
- (NSString *)getRetrivePasswordurl;

/**
 *  获取检查用户名密码的URL
 *
 *  @return URL地址
 */
- (NSString *)getCheckUserPasswordUrl;

/**
 *  获取用户名手机号码和邮箱地址的URL
 *
 *  @return URL地址
 */
- (NSString *)getUserPhoneEmailUrl;

/**
 *   获取第三方授权url
 *
 *  @return url地址
 */
- (NSString *)thirdAuthUrl;

/**
 获取快速登录url

 @return url地址
 */
- (NSString *)fastLoginUrl;

/**
 获取快速登录验证码发送url
 
 @return url地址
 */
- (NSString *)fastLoginVCodeUrl;

/**
 注销未绑定账号url
 
 @return url地址
 */
- (NSString *)destroyUnBindAccountUrl;

/**
 注销账号发送验证码url
 
 @return url地址
 */
- (NSString *)destroyVCodeUrl;

/**
 注销账号url
 
 @return url地址
 */
- (NSString *)destroyAccountUrl;

/**
 获取快速登录密码设置验证码发送url
 
 @return url地址
 */
- (NSString *)fastLoginModifyVCodeUrl;

/**
 获取快速登录密码设置url
 
 @return url地址
 */
- (NSString *)fastLoginModifyPasswordUrl;

/**
 获取Oauth登录Url

 @return url地址
 */
- (NSString *)oauthLoginUrl;

/**
 查询用户第三方绑定账号Url
 
 @return url地址
 */
- (NSString *)queryBindInfoUrl;

/**
 绑定第三方账号Url
 
 @return url地址
 */
- (NSString *)bindThirdAccount;

/**
 解绑第三方账号Url
 
 @return url地址
 */
- (NSString *)unbindThirdAccount;

/**
 设备授权url

 @return url地址
 */
- (NSString *)dnaProxyAuthUrl;


/**
 取消设备授权url

 @return url地址
 */
- (NSString *)dnaProxyDisauthUrl;
/**
 获取查询版本URL(新)
 
 @return url地址
 */
- (NSString *)appManageVersionQueryNewUrl;
/**
 获取资源下载URL(新)
 
 @return url地址
 */
- (NSString *)appManageDownloadNewUrl;
/**
 获取查询版本URL

 @return url地址
 */
- (NSString *)appManageVersionQueryUrl;

/**
 获取资源下载URL

 @return url地址
 */
- (NSString *)appManageDownloadUrl;

/**
 获取分类下品牌列表接口

 @return url地址
 */
- (NSString *)appManageGetProductBrandList;

/**
 获取分类下品牌产品接口

 @return url地址
 */
- (NSString *)appManageGetBrandFilterList;

/**
 获取红外码指定路径URL
 
 @param path 指定路径
 @return URL地址
 */
- (NSString *)iRCodeCommonUrlWithPath:(NSString *)path;
/**
 查询设备产品类型

 @return url地址
 */
- (NSString *)iRCodeQueryDeviceTypeUrl;

/**
 查询获取设备品牌列表

 @return url地址
 */
- (NSString *)iRCodeQueryDeviceBrandUrl;

/**
 查询获取产品型号

 @return url地址
 */
- (NSString *)iRCodeQueryDeviceVersionUrl ;

/**
 获取下载脚本的临时URL
 需补充域名用于下载红码，interimid为临时ID
 @return url地址
 */
- (NSString *)iRCodeGetScriptDownloadUrl;

/**
 获取下载脚本的URL,APP下载GZ

 @return url地址
 */
- (NSString *)iRCodeGetCloudScriptDownloadUrl;
/**
 识别红外数据URL

 @return url地址
 */
- (NSString *)iRCodeRecognizeDataUrl;

/**
 获取下级区域列表URL

 @return url地址
 */
- (NSString *)irCodeSubAreaGetUrl;

/**
 获取区域详细信息URL

 @return url
 */
- (NSString *)irCodeAreaInfoGetUrl;

/**
 根据地区ID获取机顶盒供应商列表URL

 @return url地址
 */
- (NSString *)iRCodeSTBGetUrl;

/**
 根据地区名机顶盒供应商列表URL
 
 @return url地址
 */
- (NSString *)iRCodeSTBByNameGetUrl;
/**
 获取机顶盒红码下载URL

 @return url地址
 */
- (NSString *)iRCodeSTBProviderGetScriptDownloadUrl;

/**
 获取机顶盒下面频道列表
 
 @return URL地址
 */
- (NSString *)iRCodeSTBChannelListUrl;

/**
 获取家庭指定路径URL
 
 @param path 指定路径
 @return URL地址
 */
- (NSString *)familyCommonUrlWithPath:(NSString *)path;
/**
 获取家庭HTTP请求Key

 @return URL地址
 */
- (NSString *)familyTimestrampAndKeyUrl;
//家庭自身相关

/**
 获取用户下家庭的ID列表

 @return URL地址
 */
- (NSString *)familyIdListUrl;
/**
 获取用户下家庭的基本信息列表

 @return URL地址
 */
- (NSString *)familyBaseInfoUrl;
/**
 获取家庭版本信息

 @return URL地址
 */
- (NSString *)familyVersionUrl;
/**
 获取家庭的具体所有信息
 
 @return URL地址
 */
- (NSString *)familyAllInfoUrl;

/**
 获取家庭详细信息

 @return URL地址
 */
- (NSString *)familyDetailUrl;
/**
 创建默认家庭

 @return URL地址
 */
- (NSString *)familyCreateDefaultUrl;
/**
 添加家庭

 @return URL地址
 */
- (NSString *)familyAddUrl;
/**
 修改家庭信息

 @return URL地址
 */
- (NSString *)familyInfoModifyUrl;
/**
 修改家庭的ICON信息

 @return URL地址
 */
- (NSString *)familyIconModifyUrl;
/**
 删除家庭

 @return URL地址
 */
- (NSString *)familyDelUrl;
/**
 更新家庭的私有数据

 @return URL地址
 */
//- (NSString *)familyPrivateDataUpUrl;
/**
 获取家庭的私有数据

 @return URL地址
 */
//- (NSString *)familyPrivateDataGetUrl;
/**
 获取家庭的子目录/分类信息

 @return URL地址
 */
- (NSString *)familyChildDirGetURL;
/**
 获取家庭场景的具体信息

 @return URL地址
 */
- (NSString *)familyScenceDetailURL;
/**
 添加家庭图片

 @return URL地址
 */
//- (NSString *)familyPicAddURL;
/**
 获取预定义的家庭RM ICON

 @return URL地址
 */
//- (NSString *)familyIrcodeIconDefineURL;
//家庭房间相关
/**
 获取预定义的房间

 @return URL地址
 */
- (NSString *)familyRoomDefineUrl;
/**
 管理家庭的房间列表

 @return URL地址
 */
- (NSString *)familyRoomListManageUrl;
//家庭成员相关
/**
 请求生成邀请加入家庭的二维码

 @return URL地址
 */
- (NSString *)familyMemberInvitedQrcodeRequestURL;
/**
 获取加入家庭的二维码的扫描信息

 @return URL地址
 */
- (NSString *)familyMemberInvitedQrcodeScanInfoURL;
/**
 通过二维码加入家庭

 @return URL地址
 */
- (NSString *)familyMemberInvitedQrcodeJoinURL;
/**
 成员加入家庭

 @return URL地址
 */
- (NSString *)familyMemberJoinURL;
/**
 成员退出家庭

 @return URL地址
 */
- (NSString *)familyMemberQuitURL;
/**
 删除家庭成员

 @return URL地址
 */
- (NSString *)familyMemberDelURL;
/**
 获取家庭成员的信息

 @return URL地址
 */
- (NSString *)familyMemberInfoURL;

//家庭设备相关
/**
 获取设备所在家庭的信息

 @return URL地址
 */
//- (NSString *)familyDeviceInURL;
/**
 家庭内已经配置的设备列表

 @return URL地址
 */
- (NSString *)familyDeviceConfigedListURL;
/**
 家庭内设备移动

 @return URL地址
 */
//- (NSString *)familyDeviceMoveURL;
/**
 家庭内设备删除

 @return URL地址
 */
- (NSString *)familyDeviceDelURL;
//家庭设备认证
/**
 家庭内设备认证添加

 @return URL地址
 */
//- (NSString *)familyAuthCenterAddURL;
/**
 家庭内设备认证退出

 @return URL地址
 */
//- (NSString *)familyAuthCenterQueryURL;

//家庭模块相关
/**
 家庭内模块单个添加

 @return URL地址
 */
- (NSString *)familyModuleAddURL;
/**
 家庭内模块列表方式添加

 @return URL地址
 */
- (NSString *)familyModuleAddListURL;
/**
 家庭内模块删除

 @return URL地址
 */
- (NSString *)familyModuleDelURL;
/**
 家庭内模块信息修改

 @return URL地址
 */
- (NSString *)familyModuleModifyURL;
/**
 家庭内模块信息修改-新接口

 @return URL地址
 */
- (NSString *)familyModuleModifyBasicInfoURL;
/**
 家庭内模块顺序修改

 @return URL地址
 */
//- (NSString *)familyModuleModifyOrderURL;
/**
 家庭内模块FLAG修改

 @return URL地址
 */
- (NSString *)familyModuleModifyFlagURL;
/**
 家庭内模块名称修改

 @return URL地址
 */
- (NSString *)familyModuleModifyNameURL;
/**
 家庭内模块关系修改

 @return URL地址
 */
//- (NSString *)familyModuleModifyRelationURL;
/**
 家庭内模块对应房间修改

 @return URL地址
 */
- (NSString *)familyModuleModifyRoomURL;
/**
 家庭内模块信息和房间修改

 @return URL地址
 */
- (NSString *)familyModuleModifyInfoAndRoomURL;

//家庭峰谷电
/**
 配置家庭峰谷电信息

 @return URL地址
 */
- (NSString *)familyElectricInfoConfigURL;
/**
 查询家庭峰谷电信息

 @return URL地址
 */
- (NSString *)familyElectricInfoQueryURL;
/**
 查询家庭私有数据唯一ID 用于虚拟子设备Did
 
 @return URL地址
 */
- (NSString *)familyPrivateDataIdURL;
/** 获取家庭私有数据更新
 
 @return URL地址
 */
- (NSString *)familyPrivateDataUpdateURL;
/** 获取家庭私有数据删除
 
 @return URL地址
 */
- (NSString *)familyPrivateDataDeleteURL;
/** 获取家庭私有数据查询
 
 @return URL地址
 */
- (NSString *)familyPrivateDataQueryURl;

//家庭联动
/**
 家庭内联动添加

 @return URL地址
 */
//- (NSString *)familyLinkageAddURL;
/**
 家庭内联动删除

 @return URL地址
 */
//- (NSString *)familyLinkageDelURL;
/**
 家庭内联动查询

 @return URL地址
 */
//- (NSString *)familyLinkageQueryURL;
/**
 家庭内联动更新

 @return URL地址
 */
//- (NSString *)familyLinkageUpdateURL;

/**
 数据上报
 
 @return URL地址
 */
- (NSString *)pickUpdateDataURL;


/**
 设备上报的数据统计查询

 @return URL地址
 */
- (NSString *)getDataReportURL;

/**
 获取Oauth 登录地址

 @return URL地址
 */
- (NSString *)oauthLoginByTokenURL;

/**
 根据Token获取登录userid

 @return URL地址
 */
- (NSString *)oauthLoginDataURL;


/**
 Token方式Oauth获取accessToken

 @return URL地址
 */
- (NSString *)oauthLoginInfoURL;

/**
 刷新Oauth的accessToken
 
 @return URL地址
 */
- (NSString *)oauthTokenURL;

//场景模块相关
/**
 场景内模块单个添加
 
 @return URL地址
 */
- (NSString *)sceneModuleAddURL;
/**
 场景内模块列表方式添加
 
 @return URL地址
 */
- (NSString *)sceneModuleAddListURL;
/**
 场景内模块删除
 
 @return URL地址
 */
- (NSString *)sceneModuleDelURL;
/**
 场景内模块信息修改
 
 @return URL地址
 */
- (NSString *)sceneModuleModifyURL;
/**
 场景内模块信息修改-新接口
 
 @return URL地址
 */
- (NSString *)sceneModuleModifyBasicInfoURL;
/**
 场景内模块FLAG修改
 
 @return URL地址
 */
- (NSString *)sceneModuleModifyFlagURL;
/**
 场景内模块名称修改
 
 @return URL地址
 */
- (NSString *)sceneModuleModifyNameURL;
/**
 场景内模块对应房间修改
 
 @return URL地址
 */
- (NSString *)sceneModuleModifyRoomURL;
/**
 场景内模块信息和房间修改
 
 @return URL地址
 */
- (NSString *)sceneModuleModifyInfoAndRoomURL;



/**
 场景下发

 @return URL地址
 */
- (NSString *)sceneControlURL;
/**
 场景取消
 
 @return URL地址
 */
- (NSString *)sceneCancelURL;
/**
 场景历史任务查询
 
 @return URL地址
 */
- (NSString *)sceneHistoryURL;
/**
 场景详情查询
 
 @return URL地址
 */
- (NSString *)sceneDeteailURL;
/**
 实时任务查询
 
 @return URL地址
 */
- (NSString *)sceneRunningtaskURL;
/**
 添加云定时
 
 @return URL地址
 */
- (NSString *)addTimertaskURL;
/**
 删除云定时
 
 @return URL地址
 */
- (NSString *)deleteTimertaskURL;
/**
 修改云定时
 
 @return URL地址
 */
- (NSString *)modifyTimertaskURL;
/**
 查询云定时
 
 @return URL地址
 */
- (NSString *)queryTimertaskURL;
/**
 联动信息增加
 
 @return URL地址
 */
- (NSString *)addLinkageURL;
/**
 联动信息删除
 
 @return URL地址
 */
- (NSString *)deleteLinkageURL;
/**
 联动信息查询
 
 @return URL地址
 */
- (NSString *)queryLinkageURL;
/**
 联动任务添加
 
 @return URL地址
 */
- (NSString *)upsertTriggerURL;
/**
联动任务停止
 
 @return URL地址
 */
- (NSString *)deleteTriggerURL;
@end
