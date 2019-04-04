//
//  IRCodeMatchTreeInfo.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/4/3.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TreeInfo : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSArray *codeList;

@end

@interface CodeInfo : NSObject

@property (nonatomic, copy) NSString *ircodeid;
@property (nonatomic, copy) NSArray *code;
@property (nonatomic, strong) TreeInfo *chirdren;

@end

@interface IRCodeMatchTreeInfo : NSObject

@property (nonatomic, copy) NSArray *hotircode;
@property (nonatomic, copy) NSArray *nobyteircode;
@property (nonatomic, strong) TreeInfo *matchtree;

@end

NS_ASSUME_NONNULL_END
