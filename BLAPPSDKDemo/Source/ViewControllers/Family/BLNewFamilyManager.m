//
//  BLNewFamilyManager.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/19.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLNewFamilyManager.h"
#import "BLNewFamilyUrls.h"
#import <BLLetBase/BLLetBase.h>
#import <BLLetCore/BLLetCore.h>
#import <BLLetIRCode/BLLetIRCode.h>

#define UPDATA_ICON_MAXLIMIT            (2014 * 512)

@implementation BLNewFamilyManager

+ (instancetype)sharedFamily {
    static dispatch_once_t onceToken;
    static BLNewFamilyManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (void)setFamilyid:(NSString *)familyid {
    _familyid = familyid;
    [BLConfigParam sharedConfigParam].familyId = familyid;
}

- (void)createDefaultFamilyWithInfo:(nonnull NSString *)name country:(nullable NSString *)country province:(nullable NSString *)province city:(nullable NSString *)city completionHandler:(nullable void (^)(BLSFamilyCreateResult * __nonnull result))completionHandler {
    
    BLSFamilyInfo *info = [[BLSFamilyInfo alloc] init];
    info.name = name;
    info.countryCode = country;
    info.provinceCode = province;
    info.cityCode = city;
    
    NSData *jsondata = [info BLS_modelToJSONData];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyCreate];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLSFamilyCreateResult *result = [[BLSFamilyCreateResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLSFamilyCreateResult *result = [BLSFamilyCreateResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)delFamilyWithFamilyid:(nonnull NSString *)familyid completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler {
    
    NSDictionary *body = @{};
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyDelete];
    self.familyid = familyid;
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseResult *result = [[BLBaseResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
    
}

- (void)modifyFamilyInfo:(nonnull BLSFamilyInfo *)info completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler {
    
    if (!info) {
        BLBaseResult *result = [[BLBaseResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSData *jsondata = [info BLS_modelToJSONData];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyModilyInfo];
    self.familyid = info.familyid;
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseResult *result = [[BLBaseResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)modifyFamilyIcon:(nonnull UIImage *)iconImage completionHandler:(nullable void (^)(BLSFamilyIconResult * __nonnull result))completionHandler {
    
    if (!iconImage) {
        BLSFamilyIconResult *result = [[BLSFamilyIconResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSData *imageData = [BLCommonTools convertToDataWithimage:iconImage MaxLimit:@(UPDATA_ICON_MAXLIMIT)];
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:2];
    
    if (imageData) {
        [postDic setObject:imageData forKey:@"picdata"];
    }
    
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyModilyIcon];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];

    [httpAccessor multipartPost:url head:nil data:postDic timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLSFamilyIconResult *result = [[BLSFamilyIconResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLSFamilyIconResult *result = [BLSFamilyIconResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)queryFamilyBaseInfoListWithCompletionHandler:(nullable void (^)(BLSFamilyListResult * __nonnull result))completionHandler {
    
    NSDictionary *body = @{};
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyList];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLSFamilyListResult *result = [[BLSFamilyListResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLSFamilyListResult *result = [BLSFamilyListResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)getFamilyInvitedQrcodeWithCompletionHandler:(nullable void (^)(BLSInvitedQrcodeResult * __nonnull result))completionHandler {
    
    NSDictionary *body = @{};
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyMemberReqQrcode];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLSInvitedQrcodeResult *result = [[BLSInvitedQrcodeResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLSInvitedQrcodeResult *result = [BLSInvitedQrcodeResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)queryFamilyInfoWithQrcode:(nonnull NSString *)qrcode completionHandler:(nullable void (^)(BLSFamilyInfoResult * __nonnull result))completionHandler {
    
    if (!qrcode) {
        BLSFamilyInfoResult *result = [[BLSFamilyInfoResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSDictionary *body = @{@"qrcode":qrcode};
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyMemberScanQrcode];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLSFamilyInfoResult *result = [[BLSFamilyInfoResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLSFamilyInfoResult *result = [BLSFamilyInfoResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
    
}

- (void)joinFamilyWithQrcode:(nonnull NSString *)qrcode completionHandler:(nullable void (^)(BLSFamilyInfoResult * __nonnull result))completionHandler {
    
    if (!qrcode) {
        BLSFamilyInfoResult *result = [[BLSFamilyInfoResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSDictionary *body = @{@"qrcode":qrcode};
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyMemberJoin];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLSFamilyInfoResult *result = [[BLSFamilyInfoResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLSFamilyInfoResult *result = [BLSFamilyInfoResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)getFamilyMembersWithCompletionHandler:(nullable void (^)(BLSFamilyMembersResult * __nonnull result))completionHandler {
    
    NSDictionary *body = @{};
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyMemberList];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLSFamilyMembersResult *result = [[BLSFamilyMembersResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLSFamilyMembersResult *result = [BLSFamilyMembersResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
    
}

- (void)deleteFamilyMembersWithUserids:(nonnull NSArray *)userids completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler {
    
    if (!userids || userids.count == 0) {
        BLSFamilyInfoResult *result = [[BLSFamilyInfoResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSDictionary *body = @{@"familymember":userids};
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyMemberDelete];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseResult *result = [[BLBaseResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
    
}

- (void)quiteFamilyWithCompletionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler {
    
    NSDictionary *body = @{};
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyMemberQuite];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseResult *result = [[BLBaseResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
    
}

- (void)transferFamilyMasterToUserid:(nonnull NSString *)userid completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler {
    
    if (!userid) {
        BLBaseResult *result = [[BLBaseResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSDictionary *body = @{@"newmaster":userid};
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyMemberTransfermaster];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseResult *result = [[BLBaseResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
    
}

- (void)getFamilyRoomsWithCompletionHandler:(nullable void (^)(BLSManageRoomResult * __nonnull result))completionHandler {
    
    NSDictionary *body = @{};
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyRoomList];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLSManageRoomResult *result = [[BLSManageRoomResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLSManageRoomResult *result = [BLSManageRoomResult BLS_modelWithJSON:data];
            if ([result succeed]) {
                self.roomList = result.roomInfos;
            }
            completionHandler(result);
        }
    }];
    
}

- (void)manageRooms:(nonnull NSArray <BLSRoomInfo *>*)rooms completionHandler:(nullable void (^)(BLSManageRoomResult * __nonnull result))completionHandler {
    
    if (!rooms || rooms.count == 0) {
        BLSManageRoomResult *result = [[BLSManageRoomResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSMutableArray *manageinfos = [NSMutableArray arrayWithCapacity:rooms.count];
    for (BLSRoomInfo *info in rooms) {
        NSDictionary *dic = [info BLS_modelToJSONObject];
        [manageinfos addObject:dic];
    }
    NSDictionary *body = @{@"manageinfo":manageinfos};
    
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyRoomManage];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLSManageRoomResult *result = [[BLSManageRoomResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLSManageRoomResult *result = [BLSManageRoomResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
    
}

- (void)getEndpointsWithCompletionHandler:(nullable void (^)(BLSQueryEndpointsResult * __nonnull result))completionHandler {
    
    NSDictionary *body = @{};
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyDeviceList];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLSQueryEndpointsResult *result = [[BLSQueryEndpointsResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLSQueryEndpointsResult *result = [BLSQueryEndpointsResult BLS_modelWithJSON:data];
            if ([result succeed]) {
                self.endpointList = result.endpoints;
            }
            completionHandler(result);
        }
    }];
    
}

- (void)addEndpoints:(nonnull NSArray <BLSEndpointInfo *>*)endpoints completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler {
    
    if (!endpoints || endpoints.count == 0) {
        BLBaseResult *result = [[BLBaseResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSMutableArray *manageinfos = [NSMutableArray arrayWithCapacity:endpoints.count];
    for (BLSEndpointInfo *info in endpoints) {
        NSDictionary *dic = [info BLS_modelToJSONObject];
        [manageinfos addObject:dic];
    }
    NSDictionary *body = @{@"endpoints":manageinfos};
    
    NSLog(@"addEndpoints: %@", body);
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *path = [kFamilyDeviceManage stringByAppendingString:@"?operation=add"];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:path];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseResult *result = [[BLBaseResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];

}

- (void)delEndpoint:(nonnull NSString *)endpointId completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler {
    
    if (!endpointId) {
        BLBaseResult *result = [[BLBaseResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSDictionary *body = @{
                           @"endpoint":@{@"endpointId":endpointId}
                           };
    
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *path = [kFamilyDeviceManage stringByAppendingString:@"?operation=del"];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:path];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseResult *result = [[BLBaseResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)modifyEndpoint:(nonnull BLSEndpointInfo *)endpoint completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler {
    
    if (!endpoint) {
        BLBaseResult *result = [[BLBaseResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSDictionary *dic = [endpoint BLS_modelToJSONObject];
    NSDictionary *body = @{
                           @"endpoint":dic
                           };
    
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *path = [kFamilyDeviceManage stringByAppendingString:@"?operation=update"];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:path];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseResult *result = [[BLBaseResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
    
}

- (void)modifyEndpoint:(nonnull NSString *)endpointId attributes:(NSArray *)attributes completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler {
    
    if (!endpointId || !attributes || attributes.count == 0) {
        BLBaseResult *result = [[BLBaseResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSDictionary *dic = @{
                          @"endpointId": endpointId,
                          @"attributes": attributes
                          };
    NSDictionary *body = @{
                           @"endpoints":@[dic]
                           };
    
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyDeviceUpdateAttribute];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseResult *result = [[BLBaseResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)getScenesWithCompletionHandler:(nullable void (^)(BLSQueryScenesResult * __nonnull result))completionHandler {
    
    NSDictionary *body = @{};
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilySceneList];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLSQueryScenesResult *result = [[BLSQueryScenesResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLSQueryScenesResult *result = [BLSQueryScenesResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)addScene:(nonnull BLSSceneInfo *)sceneInfo completionHandler:(nullable void (^)(BLSAddSceneResult * __nonnull result))completionHandler {
    
    if (!sceneInfo) {
        BLSAddSceneResult *result = [[BLSAddSceneResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSDictionary *dic = [sceneInfo BLS_modelToJSONObject];
    NSDictionary *body = @{@"sceneInfo":dic};
    
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *path = [kFamilySceneManage stringByAppendingString:@"?operation=add"];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:path];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLSAddSceneResult *result = [[BLSAddSceneResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLSAddSceneResult *result = [BLSAddSceneResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)delScene:(nonnull NSString *)sceneId completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler {
    
    if (!sceneId) {
        BLBaseResult *result = [[BLBaseResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSDictionary *dic = @{@"sceneId":sceneId};
    NSDictionary *body = @{@"sceneList":@[dic]};
    
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *path = [kFamilySceneManage stringByAppendingString:@"?operation=del"];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:path];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseResult *result = [[BLBaseResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)modifyScene:(nonnull BLSSceneInfo *)sceneInfo completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler {
    if (!sceneInfo) {
        BLBaseResult *result = [[BLBaseResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSDictionary *dic = [sceneInfo BLS_modelToJSONObject];
    NSDictionary *body = @{@"sceneInfo":dic};
    
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *path = [kFamilySceneManage stringByAppendingString:@"?operation=update"];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:path];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseResult *result = [[BLBaseResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)modifyScene:(nonnull NSString *)sceneId attributes:(NSArray *)attributes completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler {
    
    if (!sceneId || !attributes || attributes.count == 0) {
        BLBaseResult *result = [[BLBaseResult alloc] init];
        result.status = BL_APPSDK_ERR_INPUT_PARAM;
        result.msg = @"Input params is error";
        completionHandler(result);
        return;
    }
    
    NSDictionary *dic = @{
                          @"sceneId": sceneId,
                          @"attributes": attributes
                          };
    NSDictionary *body = @{
                           @"sceneList":@[dic]
                           };
    
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilySceneUpdateAttribute];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseResult *result = [[BLBaseResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)addAuthWithDid:(BLDNADevice *)device param:(NSDictionary *)param completionHandler:(nullable void (^)(BLSAddAuthResult * __nonnull result))completionHandler {
    NSDictionary *paramDic = param[@"servicelist"];
    NSArray *paramList = paramDic.allKeys;
    NSDictionary *body = @{
                           @"did": device.did,
                           @"pid": device.pid,
                           @"extend": param[@"extend"]?:@"",
                           @"serverlist": paramList,
                           @"lid": [BLConfigParam sharedConfigParam].licenseId,
                           @"licensesig": [BLConfigParam sharedConfigParam].sdkLicense,
                           @"isremainvalid":@0, //0:一直有效;!0:一定时间有效
                           @"validhour":@0,
                           @"ispartdata":@0,//0:全部数据,!0:part data
                           @"dataid":@[@{@"idtype":@"did",@"idlist":@[@"12",@"33"]}]//支持多重设置
                           };
    
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyAddAuth];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLSAddAuthResult *result = [[BLSAddAuthResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLSAddAuthResult *result = [BLSAddAuthResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)delAuthWithAuthid:(nonnull NSString *)authid completionHandler:(nullable void (^)(BLBaseResult * __nonnull result))completionHandler {
    NSString *url = [NSString stringWithFormat:@"%@?authid=%@",[[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyDelAuth],authid];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor get:url head:nil timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseResult *result = [[BLBaseResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}

- (void)queryAuthWithTicket:(nullable NSString *)ticket completionHandler:(nullable void (^)(BLBaseBodyResult * __nonnull result))completionHandler {
    NSString *url = nil;
    if ([BLCommonTools isEmpty:ticket]) {
        url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyQueryAuth];
    } else {
        url = [NSString stringWithFormat:@"%@?ticket=%@",[[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:kFamilyQueryAuth],ticket];
    }
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:nil data:jsondata timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            BLBaseBodyResult *result = [[BLBaseBodyResult alloc] init];
            result.status = BL_APPSDK_HTTP_REQUEST_ERR;
            result.msg = @"Http request error";
            completionHandler(result);
        } else {
            BLBaseBodyResult *result = [BLBaseBodyResult BLS_modelWithJSON:data];
            completionHandler(result);
        }
    }];
}
@end
