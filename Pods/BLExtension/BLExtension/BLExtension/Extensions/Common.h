//
//  Common.h
//  BLExtension
//
//  Created by Bluelich on 03/03/2017.
//  Copyright © 2017 Bluelich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

FOUNDATION_EXPORT void BL_ClassMethodSwizzling(Class cls, SEL origSel, SEL newSel);
FOUNDATION_EXPORT void BL_InstanceMethodSwizzling(Class cls, SEL origSel, SEL newSel);
