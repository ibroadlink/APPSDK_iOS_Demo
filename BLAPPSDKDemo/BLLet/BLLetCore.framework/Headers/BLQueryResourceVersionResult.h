//
//  BLQueryResourceVersionResult.h
//  Let
//
//  Created by junjie.zhu on 2016/10/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>


/**
 Resource info
 */
@interface BLResourceVersion : NSObject

/**
 Resource version
 */
@property (nonatomic, copy) NSString *version;

/**
 Resource support product pid
 */
@property (nonatomic, copy) NSString *pid;

@end


@interface BLQueryResourceVersionResult : BLBaseResult

/**
 Resource file versions
 */
@property (nonatomic, copy) NSArray<BLResourceVersion*> *versions;

@end
