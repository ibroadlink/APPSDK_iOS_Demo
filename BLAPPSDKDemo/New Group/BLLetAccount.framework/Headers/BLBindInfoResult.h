//
//  BLBindInfoResult.h
//  BLLetCore
//
//  Created by 白洪坤 on 2018/2/28.
//  Copyright © 2018年 朱俊杰. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLBindinfo : NSObject

@property (nonatomic, copy) NSString *thirdtype;


@property (nonatomic, copy) NSString *thirdid;

@end

@interface BLBindInfoResult : BLBaseResult

@property (nonatomic,copy) NSArray<BLBindinfo*> *bindinfos;
@end
