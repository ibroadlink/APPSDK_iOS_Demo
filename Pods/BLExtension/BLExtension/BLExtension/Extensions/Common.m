//
//  Common.m
//  BLExtension
//
//  Created by Bluelich on 03/03/2017.
//  Copyright © 2017 Bluelich. All rights reserved.
//

#import "Common.h"

void BL_ClassMethodSwizzling(Class cls, SEL origSel, SEL newSel){
    Class metaClass = objc_getMetaClass(class_getName(cls));
    
    Method origMethod = class_getClassMethod(metaClass, origSel);
    Method newMethod = class_getClassMethod(metaClass, newSel);
    
    IMP newIMP = method_getImplementation(newMethod);
    if (class_addMethod(metaClass, origSel, newIMP, method_getTypeEncoding(newMethod))) {
        IMP origIMP = method_getImplementation(origMethod);
        class_replaceMethod(metaClass, newSel, origIMP, method_getTypeEncoding(origMethod));
    }else{
        method_exchangeImplementations(origMethod, newMethod);
    }
}


void BL_InstanceMethodSwizzling(Class cls, SEL origSel, SEL newSel){
    Method origMethod = class_getInstanceMethod(cls, origSel);
    Method newMethod = class_getInstanceMethod(cls, newSel);
    
    IMP newIMP = method_getImplementation(newMethod);
    if (class_addMethod(cls, origSel, newIMP, method_getTypeEncoding(newMethod))) {
        IMP origIMP = method_getImplementation(origMethod);
        class_replaceMethod(cls, newSel, origIMP, method_getTypeEncoding(origMethod));
    }else{
        method_exchangeImplementations(origMethod, newMethod);
    }
}
