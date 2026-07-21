//
//  BLSFamilyMembersResult.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLSFamilyMember : NSObject

@property (nonatomic, copy)NSString *userid;
@property (nonatomic, assign)NSInteger type;

@end


@interface BLSFamilyMembersResult : BLBaseResult

@property (nonatomic, copy)NSArray *memberList;

@end

NS_ASSUME_NONNULL_END
