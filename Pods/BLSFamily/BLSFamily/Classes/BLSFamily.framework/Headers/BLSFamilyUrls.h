//
//  BLSFamilyUrls.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/19.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#ifndef BLSFamilyUrls_h
#define BLSFamilyUrls_h

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
static NSString * const kFamilyUserDeviceList = @"/appsync/group/dev/queryuserdev";

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

//联动增加
static NSString * const kLinkageAdd = @"/appsync/group/linkage/add";
//联动更新
static NSString * const kLinkageModify = @"/appsync/group/linkage/modify";
//联动删除
static NSString * const kLinkageDel = @"/appsync/group/linkage/delete";
//联动查询
static NSString *const kLinkageQuery = @"/appsync/group/linkage/query";

//销毁家庭
static NSString *const kFamilyDestory = @"/appsync/group/member/destoryfamily";

/** 获取虚拟设备id **/
static NSString *const kGetVirtualId = @"/appsync/group/dev/getvirtualid";

/** 分组设备管理 **/
static NSString *const kGroupDeviceManage = @"/appsync/group/dev/groupdevice/manage";

/** 分组设备查询 **/
static NSString *const kGroupDeviceQuery = @"/appsync/group/dev/groupdevice/query";


#endif /* BLNewFamilyUrls_h */
