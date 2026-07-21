//
//  BLTheme.m
//  BLAPPSDKDemo
//

#import "BLTheme.h"
#import <Masonry/Masonry.h>

@implementation BLTheme

+ (UIColor *)colorWithHex:(NSUInteger)hex {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIColor *)backgroundColor { return [self colorWithHex:0xF4F7FA]; }
+ (UIColor *)cardColor { return [UIColor whiteColor]; }
+ (UIColor *)primaryColor { return [self colorWithHex:0x0F766E]; }
+ (UIColor *)primaryLightColor { return [self colorWithHex:0xCCFBF1]; }
+ (UIColor *)accentColor { return [self colorWithHex:0xF0AA3D]; }
+ (UIColor *)titleColor { return [self colorWithHex:0x0F172A]; }
+ (UIColor *)subtitleColor { return [self colorWithHex:0x64748B]; }
+ (UIColor *)dangerColor { return [self colorWithHex:0xDC2626]; }
+ (UIColor *)separatorColor { return [self colorWithHex:0xE2E8F0]; }
+ (UIColor *)inputBackgroundColor { return [self colorWithHex:0xEEF2F6]; }
+ (UIColor *)toastBackgroundColor { return [[self colorWithHex:0x0F172A] colorWithAlphaComponent:0.92]; }

+ (CGFloat)buttonCornerRadius { return 14.0; }
+ (CGFloat)cardCornerRadius { return 16.0; }
+ (CGFloat)inputCornerRadius { return 12.0; }

+ (void)applyGlobalAppearance {
    UIColor *primary = [self primaryColor];
    UIColor *title = [self titleColor];
    UIColor *background = [self backgroundColor];

    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *navAppearance = [[UINavigationBarAppearance alloc] init];
        [navAppearance configureWithOpaqueBackground];
        navAppearance.backgroundColor = [UIColor whiteColor];
        navAppearance.shadowColor = [self separatorColor];
        navAppearance.titleTextAttributes = @{
            NSForegroundColorAttributeName: title,
            NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]
        };
        navAppearance.largeTitleTextAttributes = @{
            NSForegroundColorAttributeName: title,
            NSFontAttributeName: [UIFont systemFontOfSize:28 weight:UIFontWeightBold]
        };

        UINavigationBar *navBar = [UINavigationBar appearance];
        navBar.standardAppearance = navAppearance;
        navBar.scrollEdgeAppearance = navAppearance;
        navBar.compactAppearance = navAppearance;
        navBar.tintColor = primary;
        navBar.barTintColor = [UIColor whiteColor];
        navBar.barStyle = UIBarStyleDefault;
        navBar.translucent = NO;
    } else {
        UINavigationBar *navBar = [UINavigationBar appearance];
        navBar.barTintColor = [UIColor whiteColor];
        navBar.tintColor = primary;
        navBar.barStyle = UIBarStyleDefault;
        navBar.translucent = NO;
        navBar.titleTextAttributes = @{ NSForegroundColorAttributeName: title };
    }

    [UIBarButtonItem appearance].tintColor = primary;

    UITableView *tableView = [UITableView appearance];
    tableView.backgroundColor = background;
    tableView.separatorColor = [self separatorColor];

    [UITextField appearance].tintColor = primary;
    [UIButton appearance].tintColor = primary;
}

+ (void)stylePrimaryButton:(UIButton *)button {
    if (!button) { return; }
    UIImage *normal = [self imageWithColor:[self primaryColor]];
    UIImage *disabled = [self imageWithColor:[[self primaryColor] colorWithAlphaComponent:0.45]];
    [button setBackgroundImage:normal forState:UIControlStateNormal];
    [button setBackgroundImage:disabled forState:UIControlStateDisabled];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateDisabled];
    button.backgroundColor = [UIColor clearColor];
    button.layer.cornerRadius = [self buttonCornerRadius];
    button.layer.masksToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    button.contentEdgeInsets = UIEdgeInsetsMake(12, 16, 12, 16);
}

+ (void)styleSecondaryButton:(UIButton *)button {
    if (!button) { return; }
    button.backgroundColor = [self primaryLightColor];
    [button setTitleColor:[self primaryColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = [self buttonCornerRadius];
    button.layer.masksToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
}

+ (void)styleDangerOutlineButton:(UIButton *)button {
    if (!button) { return; }
    button.backgroundColor = [[self dangerColor] colorWithAlphaComponent:0.08];
    [button setTitleColor:[self dangerColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = [self buttonCornerRadius];
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = [[self dangerColor] colorWithAlphaComponent:0.35].CGColor;
    button.layer.masksToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
}

+ (void)styleTextField:(UITextField *)textField {
    if (!textField) { return; }
    textField.backgroundColor = [self inputBackgroundColor];
    textField.textColor = [self titleColor];
    textField.layer.cornerRadius = [self inputCornerRadius];
    textField.layer.masksToBounds = YES;
    textField.borderStyle = UITextBorderStyleNone;
    textField.font = [UIFont systemFontOfSize:15];
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 44)];
    textField.leftView = left;
    textField.leftViewMode = UITextFieldViewModeAlways;
    if (!textField.rightView) {
        UIView *right = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 44)];
        textField.rightView = right;
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
}

+ (void)styleCardView:(UIView *)view {
    if (!view) { return; }
    view.backgroundColor = [self cardColor];
    view.layer.cornerRadius = [self cardCornerRadius];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
    view.layer.shadowOpacity = 0.06;
    view.layer.shadowRadius = 10;
    view.layer.shadowOffset = CGSizeMake(0, 4);
}

+ (void)styleResultTextView:(UITextView *)textView {
    if (!textView) { return; }
    textView.backgroundColor = [self inputBackgroundColor];
    textView.textColor = [self titleColor];
    textView.layer.cornerRadius = [self cardCornerRadius];
    textView.layer.masksToBounds = YES;
    textView.font = [UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightRegular];
    textView.textContainerInset = UIEdgeInsetsMake(12, 10, 12, 10);
    textView.editable = NO;
}

+ (void)styleButtonsInView:(UIView *)view {
    if (!view) { return; }
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [self stylePrimaryButton:(UIButton *)subview];
        } else {
            [self styleButtonsInView:subview];
        }
    }
}

+ (UIButton *)menuRowCardWithItem:(NSDictionary *)item target:(id)target action:(SEL)action {
    UIButton *card = [UIButton buttonWithType:UIButtonTypeCustom];
    card.tag = [item[@"tag"] integerValue];
    [card addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self styleCardView:card];
    card.backgroundColor = [self cardColor];

    UIView *iconBg = [[UIView alloc] init];
    iconBg.userInteractionEnabled = NO;
    iconBg.backgroundColor = [self primaryLightColor];
    iconBg.layer.cornerRadius = 18;
    [card addSubview:iconBg];

    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.userInteractionEnabled = NO;
    iconView.tintColor = [self primaryColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightMedium];
        iconView.image = [UIImage systemImageNamed:item[@"symbol"] withConfiguration:config];
    }
    [iconBg addSubview:iconView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.userInteractionEnabled = NO;
    titleLabel.text = item[@"title"];
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titleLabel.textColor = [self titleColor];
    [card addSubview:titleLabel];

    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.userInteractionEnabled = NO;
    descLabel.text = item[@"desc"];
    descLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    descLabel.textColor = [self subtitleColor];
    descLabel.numberOfLines = 2;
    [card addSubview:descLabel];

    UIImageView *chevron = [[UIImageView alloc] init];
    chevron.userInteractionEnabled = NO;
    chevron.tintColor = [self subtitleColor];
    if (@available(iOS 13.0, *)) {
        chevron.image = [UIImage systemImageNamed:@"chevron.right"];
    }
    [card addSubview:chevron];

    [iconBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(card).offset(16);
        make.centerY.equalTo(card);
        make.width.height.mas_equalTo(40);
    }];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(iconBg);
        make.width.height.mas_equalTo(20);
    }];
    [chevron mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(card).offset(-16);
        make.centerY.equalTo(card);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(16);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconBg.mas_right).offset(12);
        make.right.equalTo(chevron.mas_left).offset(-8);
        make.top.equalTo(card).offset(18);
    }];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(titleLabel);
        make.top.equalTo(titleLabel.mas_bottom).offset(4);
    }];
    return card;
}

+ (void)installMenuListOnView:(UIView *)hostView
                        title:(NSString *)title
                     subtitle:(NSString *)subtitle
                        items:(NSArray<NSDictionary *> *)items
                       target:(id)target
                       action:(SEL)action {
    if (!hostView) { return; }

    for (UIView *subview in hostView.subviews) {
        if (subview.tag == 88001) { return; } // already installed
        subview.hidden = YES;
    }

    hostView.backgroundColor = [self backgroundColor];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.tag = 88001;
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    [hostView addSubview:scrollView];

    UIView *content = [[UIView alloc] init];
    [scrollView addSubview:content];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    titleLabel.textColor = [self titleColor];
    [content addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = subtitle;
    subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [self subtitleColor];
    subtitleLabel.numberOfLines = 0;
    [content addSubview:subtitleLabel];

    UIView *accentBar = [[UIView alloc] init];
    accentBar.backgroundColor = [self primaryColor];
    accentBar.layer.cornerRadius = 2;
    [content addSubview:accentBar];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12;
    [content addSubview:stack];

    for (NSDictionary *item in items) {
        UIButton *card = [self menuRowCardWithItem:item target:target action:action];
        [stack addArrangedSubview:card];
        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(76);
        }];
    }

    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(hostView.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(hostView);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(16);
        make.left.equalTo(content).offset(20);
        make.right.equalTo(content).offset(-20);
    }];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(6);
        make.left.right.equalTo(titleLabel);
    }];
    [accentBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subtitleLabel.mas_bottom).offset(12);
        make.left.equalTo(titleLabel);
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(4);
    }];
    [stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accentBar.mas_bottom).offset(20);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
        make.bottom.equalTo(content).offset(-28);
    }];
}

@end
