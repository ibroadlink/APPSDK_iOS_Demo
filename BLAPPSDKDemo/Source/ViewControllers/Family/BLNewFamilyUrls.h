//
//  BLNewFamilyUrls.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/19.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#ifndef BLNewFamilyUrls_h
#define BLNewFamilyUrls_h

//创建家庭
static NSString * const kFamilyCreate = @"/appsync/group/family/add";
//删除家庭
static NSString * const kFamilyDelete = @"/appsync/group/family/del";
//修改家庭信息
static NSString * const kFamilyModilyInfo = @"/appsync/group/family/modifyinfo";
//修改家庭图标
static NSString * const kFamilyModilyIcon = @"/appsync/group/family/modifyicon";
//获取家庭图标
static NSString * const kFamilyGetIcon = @"/appsync/group/family/familypic";
//获取家庭基本信息列表
static NSString * const kFamilyList = @"/appsync/group/member/getfamilylist";
//获取指定家庭基本信息
static NSString * const kFamilyBaseInfo = @"/appsync/group/family/getfamilyinfo";

//获取家庭邀请二维码
static NSString * const kFamilyMemberReqQrcode = @"/appsync/group/member/invited/reqqrcode";
//根据二维码获取家庭基本信息
static NSString * const kFamilyMemberScanQrcode = @"/appsync/group/member/invited/scanqrcode";
//根据二维码加入家庭
static NSString * const kFamilyMemberJoin = @"/appsync/group/member/invited/joinfamily";
//获取家庭成员列表
static NSString * const kFamilyMemberList = @"/appsync/group/member/getfamilymember";
//删除家庭成员
static NSString * const kFamilyMemberDelete = @"/appsync/group/member/delfamilymember";
//转让家庭管理员角色
static NSString * const kFamilyMemberTransfermaster = @"/appsync/group/member/transfermaster";
//主动退出家庭
static NSString * const kFamilyMemberQuite = @"/appsync/group/member/quitfamily";

//获取房间列表
static NSString * const kFamilyRoomList = @"/appsync/group/room/query";
//房间管理
static NSString * const kFamilyRoomManage = @"/appsync/group/room/manage";

//获取设备列表
static NSString * const kFamilyDeviceList = @"/appsync/group/dev/query";
//设备管理
static NSString * const kFamilyDeviceManage = @"/appsync/group/dev/manage";
//设备属性修改
static NSString * const kFamilyDeviceUpdateAttribute = @"/appsync/group/dev/updateattribute";

//获取场景列表
static NSString * const kFamilySceneList = @"/appsync/group/scene/query";
//场景管理
static NSString * const kFamilySceneManage = @"/appsync/group/scene/manage";
//场景属性修改
static NSString * const kFamilySceneUpdateAttribute = @"/appsync/group/scene/updateattribute";

//增加授权
static NSString * const kFamilyAddAuth = @"/appsync/group/auth/add";
//删除授权
static NSString * const kFamilyDelAuth = @"/appsync/group/auth/del";
//查询授权
static NSString *const kFamilyQueryAuth = @"/appsync/group/auth/query";
#endif /* BLNewFamilyUrls_h */
