//
//  BLOAuth.h
//  Let
//
//  Created by zhujunjie on 2017/7/30.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>
#import "BLOAuthBlockResult.h"

typedef void(^BLOAuthBlock)(BOOL status, BLOAuthBlockResult *result);

@interface BLOAuth : NSObject

/** Access Token凭证，用于后续访问各开放接口 */
@property(nonatomic, copy) NSString* accessToken;

/** Access Token的失效期 */
@property(nonatomic, copy) NSDate* expirationDate;

/** 第三方应用在互联开放平台申请的clientID */
@property(nonatomic, retain) NSString* clientId;

/**
 * 初始化BLOAuth对象
 * param clientId 第三方应用在互联开放平台申请的唯一标识
 * param redirectURI 第三方应用在互联开放平台申请所填的URL，必须一致
 * return 初始化后的授权登录对象
 */
- (id)initWithLicenseId:(NSString *)licenseId cliendId:(NSString *)clientId redirectURI:(NSString *)redirectURI;

/**
 * 登录授权
 *
 * param permissions 授权信息列 暂为空
 */
- (BOOL)authorize:(NSArray *)permissions;

/**
 * 处理应用拉起协议
 * param url 处理被其他应用呼起时的逻辑
 * return 处理结果，YES表示成功，NO表示失败
 */
- (void)HandleOpenURL:(NSURL *)url completionHandler:(BLOAuthBlock)completionHandler;

/**
 * 判断登录状态是否有效
 * return 处理结果，YES表示有效，NO表示无效，请用户重新登录授权
 */
- (BOOL)isSessionValid;


@end
