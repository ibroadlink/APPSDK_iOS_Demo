//
//  BLGroupDeviceInfo.h
//  BLLetFamily
//
//  Created by hongkun.bai on 2018/9/28.
//  Copyright © 2018 baihk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLGroupDeviceInfo : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (NSDictionary *)toDictionary;

@property (nonatomic, copy)NSString *did;          
@property (nonatomic, copy)NSString *extend;

@end

