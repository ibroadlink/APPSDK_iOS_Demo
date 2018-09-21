//
//  BLFamilyInvitedQrcodePostResult.h
//  Let
//
//  Created by zjjllj on 2017/2/8.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLFamilyInvitedQrcodePostResult : BLBaseResult

@property (nonatomic, copy)NSString *familyId;
@property (nonatomic, copy)NSString *familyName;
@property (nonatomic, copy)NSString *familyIconPath;
@property (nonatomic, copy)NSString *familyCreatorId;

@end
