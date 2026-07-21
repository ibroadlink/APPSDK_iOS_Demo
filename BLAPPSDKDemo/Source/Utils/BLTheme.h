//
//  BLTheme.h
//  BLAPPSDKDemo
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLTheme : NSObject

+ (UIColor *)backgroundColor;
+ (UIColor *)cardColor;
+ (UIColor *)primaryColor;
+ (UIColor *)primaryLightColor;
+ (UIColor *)accentColor;
+ (UIColor *)titleColor;
+ (UIColor *)subtitleColor;
+ (UIColor *)dangerColor;
+ (UIColor *)separatorColor;
+ (UIColor *)inputBackgroundColor;
+ (UIColor *)toastBackgroundColor;

+ (CGFloat)buttonCornerRadius;
+ (CGFloat)cardCornerRadius;
+ (CGFloat)inputCornerRadius;

+ (void)applyGlobalAppearance;

+ (void)stylePrimaryButton:(UIButton *)button;
+ (void)styleSecondaryButton:(UIButton *)button;
+ (void)styleDangerOutlineButton:(UIButton *)button;
+ (void)styleTextField:(UITextField *)textField;
+ (void)styleCardView:(UIView *)view;
+ (void)styleResultTextView:(UITextView *)textView;
/// 递归将视图树中的 UIButton 统一为主题主按钮样式
+ (void)styleButtonsInView:(UIView *)view;

/// items: @{ @"title", @"desc", @"symbol", @"tag" }
+ (void)installMenuListOnView:(UIView *)hostView
                        title:(NSString *)title
                     subtitle:(nullable NSString *)subtitle
                        items:(NSArray<NSDictionary *> *)items
                       target:(id)target
                       action:(SEL)action;

+ (UIColor *)colorWithHex:(NSUInteger)hex;
+ (UIImage *)imageWithColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
