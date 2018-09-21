//
//  UIView+BL.m
//  BLExtension
//
//  Created by Bluelich on 03/03/2017.
//  Copyright © 2017 Bluelich. All rights reserved.
//

#import "UIView+BL.h"
#import "Common.h"

@implementation UIView (BL)
+(void)load
{
    BL_InstanceMethodSwizzling(self, @selector(pointInside:withEvent:), @selector(swizzling_PointInside:withEvent:));
}
-(BOOL)swizzling_PointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.touchExtendInset, UIEdgeInsetsZero) || self.hidden
        || ([self isKindOfClass:[UIControl class]]  &&  ![(UIControl *)self isEnabled])){
        return [self swizzling_PointInside:point withEvent:event];
    }
    CGRect enabledFrame = UIEdgeInsetsInsetRect(self.bounds, self.touchExtendInset);
    enabledFrame.size.width = MAX(enabledFrame.size.width, 0);
    enabledFrame.size.height = MAX(enabledFrame.size.height, 0);
    return CGRectContainsPoint(enabledFrame, point);
}
-(UIEdgeInsets)touchExtendInset
{
    return [objc_getAssociatedObject(self, @selector(touchExtendInset)) UIEdgeInsetsValue];
}
-(void)setTouchExtendInset:(UIEdgeInsets)touchExtendInset
{
    objc_setAssociatedObject(self, @selector(touchExtendInset), [NSValue valueWithUIEdgeInsets:touchExtendInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
