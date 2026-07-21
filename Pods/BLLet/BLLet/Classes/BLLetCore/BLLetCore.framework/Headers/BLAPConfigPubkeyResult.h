//
//  BLAPConfigPubkeyResult.h
//  BLLetCore
//
//  Created by admin on 2019/9/19.
//  Copyright © 2019 朱俊杰. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLAPConfigPubkeyResult : BLBaseResult

@property (nonatomic, copy) NSString *pubkey; //设备AP配网公钥

@end

NS_ASSUME_NONNULL_END
