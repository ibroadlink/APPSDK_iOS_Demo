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

#pragma mark - Account form helpers

/// 隐藏 Storyboard 原有子视图，避免与代码布局冲突
+ (void)hideStoryboardSubviewsIn:(UIView *)hostView;

+ (UITextField *)makeTextFieldWithPlaceholder:(NSString *)placeholder;
+ (UITextField *)makePasswordFieldWithPlaceholder:(NSString *)placeholder;
+ (UIButton *)makePrimaryButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (UIButton *)makeSecondaryButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (UIButton *)makeLinkButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;

/// 账号表单页：大标题 + 副标题 + 表单区 + 主按钮 + 底部链接
+ (void)installAuthFormOnView:(UIView *)hostView
                        title:(NSString *)title
                     subtitle:(nullable NSString *)subtitle
                   formViews:(NSArray<UIView *> *)formViews
               primaryButton:(nullable UIButton *)primaryButton
                 footerViews:(nullable NSArray<UIView *> *)footerViews;

+ (UIColor *)colorWithHex:(NSUInteger)hex;
+ (UIImage *)imageWithColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
