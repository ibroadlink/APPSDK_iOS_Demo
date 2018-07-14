//
//  BLConstants.h
//  Let
//
//  Created by yzm on 16/5/19.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#ifndef BLConstants_h
#define BLConstants_h


typedef unsigned char *_Nullable(^BLReadPrivateDataBlock)(int sync, unsigned char *_Nullable key);
typedef unsigned char *_Nullable(^BLWritePrivateDataBlock)(int sync, unsigned char *_Nullable key, unsigned char *_Nullable data);

/**
 Account Error Code Enum
 */
typedef NS_ENUM(NSInteger, BLAccountErrCodeEnum) {
    // 由服务器返回的错误码
    /** session失效 */
    BL_ACCOUNT_ERR_SESSION_INVALID = -1000,
    /** 服务器繁忙 */
    BL_ACCOUNT_ERR_SERVER_BUSY = -1001,
    /** 验证码错误 */
    BL_ACCOUNT_ERR_VCODE = -1002,
    /** 帐号已被注册 */
    BL_ACCOUNT_ERR_REGISTED = -1003,
    /** 数据错误 */
    BL_ACCOUNT_ERR_DATA = -1005,
    /** 帐号或密码不正确*/
    BL_ACCOUNT_ERR_LOGIN = -1006,
    /** 验证码已失效 */
    BL_ACCOUNT_ERR_VCODE_EXPIRED = -1007,
    /** 帐号或密码不正确 */
    BL_ACCOUNT_ERR_LOGIN2 = -1008,
    /** 请登陆后操作 */
    BL_ACCOUNT_ERR_NEED_LOGIN = -1009,
    /** 原始密码错误 */
    BL_ACCOUNT_ERR_xx_LOGIN = -1010,
    /** 头像不存在 */
    BL_ACCOUNT_ERR_NO_AVADAR = -1011,
    /** 请重新登陆 */
    BL_ACCOUNT_ERR_NEED_LOGIN1 = -1012,
    /** 信息不匹配 */
    BL_ACCOUNT_ERR_INFO = -1013,
    /** 三小时后再登陆 */
    BL_ACCOUNT_ERR_RELOGIN = -1014,
    /** 邮箱错误 */
    BL_ACCOUNT_ERR_EMAIL = -1015,
    /** 上传的头像超过了50k */
    BL_ACCOUNT_ERR_AVADAR_LARGER = -1019,
    /** 邮箱或密码不正确 */
    BL_ACCOUNT_ERR_LOGIN3 = -1020,
    /** 注册过于频繁 */
    BL_ACCOUNT_ERR_REGISTER_MUCH = -1021,
    /** 登陆剩余次数 */
    BL_ACCOUNT_ERR_REMAINER = -1023,
    /** 发送验证码错误 */
    BL_ACCOUNT_ERR_VCODE2 = -1027,
    /** 手机号码错误 */
    BL_ACCOUNT_ERR_PHONE = -1028,
    /** 头像保存错误 */
    BL_ACCOUNT_ERR_AVADAR_SAVE = -1029,
    /** 获取验证码过于频繁 */
    BL_ACCOUNT_ERR_GET_VCODE_MORE = -1030,
    /** 验证码超时或不存在 */
    BL_ACCOUNT_ERR_NO_VCODE = -1031,
    /** 手机号码已经注册 */
    BL_ACCOUNT_ERR_PHONE_REGISTED = -1032,
    /** 手机号码或密码不正确 */
    BL_ACCOUNT_ERR_LOGIN4 = -1033,
    /** 未验证手机验证码 */
    BL_ACCOUNT_ERR_PHONE_VCODE = -1034,
    /** 帐号不存在 */
    BL_ACCOUNT_ERR_NO_USER = -1035,
    /** 尝试次数过多,请过一段时间后重试 */
    BL_ACCOUNT_ERR_RETRY = -1036,
    /** 登陆信息不正确 */
    BL_ACCOUNT_ERR_LOGIN_INFO = -1037,
    /** 邮箱已经注册 */
    BL_ACCOUNT_ERR_EMAIL_REGISTED = -1038,
    /** 验证码已失效 */
    BL_ACCOUNT_ERR_VCDOE = -1039,
    /** 发送短信次数过多 */
    BL_ACCOUNT_ERR_MESSAGE_MORE = -1040,
    /** 数据超长 */
    BL_ACCOUNT_ERR_DATA_LARGER = -1041,
    /** 权限格式错误*/
    BL_ACCOUNT_ERR_PERMISSION_FORMAT = -1042,
    /** 权限已存在*/
    BL_ACCOUNT_ERR_PERMISSION_EXIT = -1043,
    /** 角色格式错误 */
    BL_ACCOUNT_ERR_ROLE = -1044,
    /** 角色已存在*/
    BL_ACCOUNT_ERR_ROLE_EXIST = -1045,
    /** 公司已存在*/
    BL_ACCOUNT_ERR_COMPANY_EXIT = -1046,
    /** 公司不存在*/
    BL_ACCOUNT_ERR_COMPANY_NOT_EXIT = -1047,
    /** 账户已被禁用*/
    BL_ACCOUNT_ERR_BEEN_DISABLED = -1049,
    /** 密码已被重置，请直接修改*/
    BL_ACCOUNT_ERR_PASSWORD_BEEN_SET = -1050,
    /** 不支持的第三方OAuth平台*/
    BL_ACCOUNT_ERR_OAUTH_NOT_SUPPORT = -1051,
    /** OAuth认证失败*/
    BL_ACCOUNT_ERR_OAUTH_FAILED = -1052,
    /** 请求过于频繁*/
    BL_ACCOUNT_ERR_TOO_FREQUENT = -1099,
    
};

/**
 Controller Error Code Enum
 */
typedef NS_ENUM(NSInteger, BLControllerErrCodeEnum) {
    /** 成功 */
    BL_CONTROLLER_SUCCESS = 0,
    
    /** 固件返回错误码**/
    /** 认证失败，认证码被修改，需要重新pair**/
    BL_CONTROLLER_ERR_AUTH_FAIL = -1,
    /*其他地方登录。强制退出。*/
    BL_CONTROLLER_ERR_NO_AUTH = -2,
    /** 设备不在线 */
    BL_CONTROLLER_ERR_NOT_ACCESS = -3,
    /** 不支持的命令类型 */
    BL_CONTROLLER_ERR_NOT_SUPPORT = -4,
    /*空间满*/
    BL_CONTROLLER_ERR_DEVICE_FULL = -5,
    /*结构体异常*/
    BL_CONTROLLER_ERR_STRUCT_FAIL = -6,
    /** 控制秘钥失效, 需局域网内重新配对 */
    BL_CONTROLLER_ERR_AUTH_FAIL_2 = -7,
    
    /** 控制超时 **/
    BL_CONTROLLER_ERR_TIMEOUT = -4000,
    /** 脚本文件不存在 */
    BL_CONTROLLER_ERR_FILE_NO_EXIT = -4020,
    /** SDK未认证 */
    BL_CONTROLLER_ERR_NOT_AUTH = -4035,
    /** 标准指令到电控指令失败 */
    BL_CONTROLLER_ORDER_TO_DEVICE_FAIL = -4031,
    
    /** SDK认证超时，重新认证 */
    BL_CONTROLLER_ERR_AUTH_TIMEOUT = -2001,
    /** 非法的认证码*/
    BL_CONTROLLER_ERR_AUTH_ILLEGAL_CODE = -2002,
    /** 控制设备未绑定至云端 */
    BL_CONTROLLER_ERR_NOT_BIND = -2003,
    /** 绑定设备到云端请求的参数不合法 */
    BL_CONTROLLER_ERR_BIND_PARAM = -2004,
    /** 请求的命令不支持 */
    BL_CONTROLLER_ERR_NO_SUCH_METROD = -2005,
    /** 网络故障 */
    BL_CONTROLLER_ERR_NETWORK = -2006,
    /** 远程控制数据加密类型错误 */
    BL_CONTROLLER_ERR_REMOTE_CONTROL_ENCRYPTION = -2007,
    /** 远程控制数据校验失败 */
    BL_CONTROLLER_ERR_REMOTE_CONTROL_VERIFY = -2008,
    /** License 未在云端注册 */
    BL_CONTROLLER_ERR_FORBIDDEN_LICENSE = -2009,
    /** 远程控制数据解密失败*/
    BL_CONTROLLER_ERR_REMOTE_CONTROL_DECIPHERING = -2010,
    /** 认证码不匹配 */
    BL_CONTROLLER_ERR_AUTH_CODE = -2011,
    /** UID 非法 */
    BL_CONTROLLER_ERR_ILLEGALITY_UID = -2012,
    /** 账号无法通过校验 */
    BL_CONTROLLER_ERR_ACCOUNT_VERIFY = -2013,
    /** 远程认证数据解密失败 */
    BL_CONTROLLER_ERR_REMOTE_AUTH_DECIPHERING = -2014,
    /** 绑定到云端的设备数量超过限制 */
    BL_CONTROLLER_ERR_TOO_MUCH_DEVICE = -2015,
    /** License 不支持当前绑定到云端的 设备类型 */
    BL_CONTROLLER_ERR_LICENSE_FORBIDDEN_BIND = -2016,
    /** 控制时未提供 account_id */
    BL_CONTROLLER_ERR_NO_ACCOUNT_ID = -2017,
    
};

/**
 APPSDK Return Error Code Enum
 */
typedef NS_ENUM(NSInteger, BLAppSdkErrCodeEnum) {
    /** 成功 */
    BL_APPSDK_SUCCESS = 0,
    
    /** SDK未初始化 */
    BL_APPSDK_ERR_NOT_INIT = -3000,
    /** 系统／网络异常错误 */
    BL_APPSDK_ERR_UNKNOWN = -3001,
    /** 参数错误 */
    BL_APPSDK_ERR_INPUT_PARAM = -3002,
    /** 未登录异常 */
    BL_APPSDK_ERR_NOT_LOGIN = -3003,
    /** 网络异常 **/
    BL_APPSDK_HTTP_REQUEST_ERR = -3004,
    /** 网络请求过快 **/
    BL_APPSDK_HTTP_TOO_FAST_ERR = -3005,
    /** 服务器无返回 **/
    BL_APPSDK_SERVER_NO_RESULT_ERR = -3006,
    /** 不支持的操作 **/
    BL_APPSDK_ERR_NOT_SUPPORT_ACTION = -3007,
    /** 配置错误的设备 **/
    BL_APPSDK_ERR_CONFIG_ERR_DEVICE= -3008,
    /** 设备无法找到 **/
    BL_APPSDK_ERR_DEVICE_NOT_FOUND= -3009,
    
    /** 系统／网络异常错误 */
    BL_CONTROLLER_ERR_UNKNOWN = -3101,
    /** 未登录异常 */
    BL_CONTROLLER_ERR_NOT_LOGIN = -3102,
    /** 设备不存在异常 */
    BL_CONTROLLER_ERR_DEVICE_NOT_FOUND = -3103,
    /** 获取TOKEN异常 */
    BL_CONTROLLER_ERR_GET_TOKEN = -3104,
    /** 查询资源异常 */
    BL_CONTROLLER_ERR_QUERY_RESOURCE = -3105,
    /** 无法找到请求的资源 */
    BL_CONTROLLER_ERR_NO_RESOURCE = -3106,
    /** Body格式错误 */
    BL_CONTROLLER_ERR_PARAM = -3107,
    /** 数据缺少必要字段 */
    BL_CONTROLLER_ERR_LEAK_PARAM = -3108,
    /** TOKEN/URL过期 */
    BL_CONTROLLER_ERR_TOKEN_OUT_OF_DATE = -3109,
    /** 请求方法错误 */
    BL_CONTROLLER_ERR_WRONG_METHOD = -3110,
    /** 用户主动停止 */
    BL_CONTROLLER_ERR_DENIED = -3111,
    /** 解压文件失败 */
    BL_CONTROLLER_ERR_UNZIP = -3112,
    /** 文件不存在 */
    BL_CONTROLLER_ERR_FILE_NOT_FOUND = -3113,
    /** DNS解析失败 */
    BL_CONTROLLER_ERR_GET_HOST_IP_ERROR = -3114,
    /** AccessKey 为空*/
    BL_CONTROLLER_ERR_ACCESS_KEY_NULL_ERROR = -3115,
    /** 用户取消授权*/
    BL_APPSDK_ERR_USER_CANCEL = -3116,
    /** 下载文件解密失败*/
    BL_APPSDK_ERR_DOWNLOAD_DECODE_ERROR = -3117,
    /** key配对失败*/
    BL_APPSDK_ERR_GET_DEVICEKEY_ERROR = -3118,
};

/**
 Debug Level Enum
 */
typedef NS_ENUM(NSUInteger, BLDebugLevelEnum) {
    /** 不打印 */
    BL_LEVEL_NONE = 0,
    /** 打印错误信息 */
    BL_LEVEL_ERROR = 1,
    /** 打印错误信息与警告信息 */
    BL_LEVEL_WARN = 2,
    /** 打印错误信息、警告信息以及调试信息 */
    BL_LEVEL_DEBUG = 3,
    /** 打印所有信息 */
    BL_LEVEL_ALL = 4
};

/**
 Device Control Network Mode Enum
 */
typedef NS_ENUM(NSUInteger, BLDeviceNetModeEnum) {
    /** Control only in lan */
    BL_NET_LAN_ONLY = 0,
    /** Control only in wan */
    BL_NET_REMOTE_ONLY = 1,
    /** Both network mode, Priority use lan */
    BL_NET_DEFAULT = 2
};

/**
 Device Network Status Enum
 */
typedef NS_ENUM(NSInteger, BLDeviceStatusEnum) {
    /** 初始化状态(未知) */
    BL_DEVICE_STATE_UNKNOWN = 0,
    /** 局域网状态 */
    BL_DEVICE_STATE_LAN = 1,
    /** 远程状态 */
    BL_DEVICE_STATE_REMOTE = 2,
    /** 离线状态 */
    BL_DEVICE_STATE_OFFLINE = 3
};


/**
 IRcode Device Support Type Enum
 */
typedef NS_ENUM(NSInteger, BLIRCodeDeviceTypeEnum) {
    /** 所有 */
    BL_IRCODE_DEVICE_ALL = 0,
    /** 电视 */
    BL_IRCODE_DEVICE_TV ,
    /** 机顶盒 */
    BL_IRCODE_DEVICE_TV_BOX ,
    /** 云空调 */
    BL_IRCODE_DEVICE_AC ,
    /** 云电机 */
    BL_IRCODE_DEVICE_MOTOR ,
    /** 灯控开关 */
    BL_IRCODE_DEVICE_SWITCH ,
    /** 遥控灯 */
    BL_IRCODE_DEVICE_LIGHT ,
    /** 遥控门 */
    BL_IRCODE_DEVICE_DOOR ,
};

/**
 Account Gender Enum
 */
typedef NS_ENUM(NSUInteger, BLAccountSexEnum) {
    /** 男性 */
    BL_ACCOUNT_MALE,
    /** 女性 */
    BL_ACCOUNT_FEMALE
};

typedef NS_ENUM(NSUInteger, BLTimeTypeEnum) {
    /** 普通定时 */
    BL_TIMER_TYPE_LIST = 0,
    /** 延时定时 */
    BL_DELAY_TYPE_LIST,
    /** 周期定时 */
    BL_PERIOD_TYPE_LIST,
    /** 循环定时 */
    BL_CYCLE_TYPE_LIST,
    /** 防盗定时 */
    BL_RANDOM_TYPE_LIST,
    
};

#pragma mark - 错误信息返回
static NSString * _Nonnull const kSuccessMsg = @"Success";
static NSString * _Nonnull const kErrorMsgUnknownError = @"Unknown error";
static NSString * _Nonnull const kErrorMsgNotLogin = @"Not login";
static NSString * _Nonnull const kErrorMsgInputParam = @"Params input error";
static NSString * _Nonnull const kErrorMsgServerReturn = @"Server has not return data";
static NSString * _Nonnull const kErrorMsgInputLicense = @"Please input license";
static NSString * _Nonnull const kErrorMsgInitSdkFirst = @"Please init sdk first";
static NSString * _Nonnull const kErrorMsgNotSupportAction = @"Not support this action";
static NSString * _Nonnull const kErrorMsgConfigErrorDevice = @"EasyConfig error device";
static NSString * _Nonnull const kErrorMsgConfigTimeout = @"EasyConfig timout";
static NSString * _Nonnull const kErrorMsgCannotFindDevice = @"Cannot find specified device";
static NSString * _Nonnull const kErrorMsgRequestFast = @"HTTP request too fast";
static NSString * _Nonnull const kErrorMsgRequestDns = @"DNS resolution failed";
static NSString * _Nonnull const kErrorMsgRequestResource = @"Query resources error";
static NSString * _Nonnull const kErrorMsgDeviceNotSupport = @"Device is not supported by this license";
static NSString * _Nonnull const kErrorMsgDeviceKeyGetError = @"Can not get device key. Please retry!";

#endif /* BLConstants_h */
