//
//  BLTheme.m
//  BLAPPSDKDemo
//

#import "BLTheme.h"

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

+ (UIButton *)menuRowCardWithItem:(NSDictionary *)item target:(id)target action:(SEL)action {
    UIButton *card = [UIButton buttonWithType:UIButtonTypeCustom];
    card.tag = [item[@"tag"] integerValue];
    [card addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self styleCardView:card];
    card.backgroundColor = [self cardColor];

    UIView *iconBg = [[UIView alloc] init];
    iconBg.translatesAutoresizingMaskIntoConstraints = NO;
    iconBg.userInteractionEnabled = NO;
    iconBg.backgroundColor = [self primaryLightColor];
    iconBg.layer.cornerRadius = 18;
    [card addSubview:iconBg];

    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.userInteractionEnabled = NO;
    iconView.tintColor = [self primaryColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightMedium];
        iconView.image = [UIImage systemImageNamed:item[@"symbol"] withConfiguration:config];
    }
    [iconBg addSubview:iconView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.userInteractionEnabled = NO;
    titleLabel.text = item[@"title"];
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titleLabel.textColor = [self titleColor];
    [card addSubview:titleLabel];

    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.translatesAutoresizingMaskIntoConstraints = NO;
    descLabel.userInteractionEnabled = NO;
    descLabel.text = item[@"desc"];
    descLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    descLabel.textColor = [self subtitleColor];
    descLabel.numberOfLines = 2;
    [card addSubview:descLabel];

    UIImageView *chevron = [[UIImageView alloc] init];
    chevron.translatesAutoresizingMaskIntoConstraints = NO;
    chevron.userInteractionEnabled = NO;
    chevron.tintColor = [self subtitleColor];
    if (@available(iOS 13.0, *)) {
        chevron.image = [UIImage systemImageNamed:@"chevron.right"];
    }
    [card addSubview:chevron];

    [NSLayoutConstraint activateConstraints:@[
        [iconBg.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [iconBg.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
        [iconBg.widthAnchor constraintEqualToConstant:40],
        [iconBg.heightAnchor constraintEqualToConstant:40],

        [iconView.centerXAnchor constraintEqualToAnchor:iconBg.centerXAnchor],
        [iconView.centerYAnchor constraintEqualToAnchor:iconBg.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:20],
        [iconView.heightAnchor constraintEqualToConstant:20],

        [chevron.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
        [chevron.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
        [chevron.widthAnchor constraintEqualToConstant:12],
        [chevron.heightAnchor constraintEqualToConstant:16],

        [titleLabel.leadingAnchor constraintEqualToAnchor:iconBg.trailingAnchor constant:12],
        [titleLabel.trailingAnchor constraintEqualToAnchor:chevron.leadingAnchor constant:-8],
        [titleLabel.topAnchor constraintEqualToAnchor:card.topAnchor constant:18],

        [descLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [descLabel.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor],
        [descLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:4],
    ]];
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
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    [hostView addSubview:scrollView];

    UIView *content = [[UIView alloc] init];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:content];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    titleLabel.textColor = [self titleColor];
    [content addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    subtitleLabel.text = subtitle;
    subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [self subtitleColor];
    subtitleLabel.numberOfLines = 0;
    [content addSubview:subtitleLabel];

    UIView *accentBar = [[UIView alloc] init];
    accentBar.translatesAutoresizingMaskIntoConstraints = NO;
    accentBar.backgroundColor = [self primaryColor];
    accentBar.layer.cornerRadius = 2;
    [content addSubview:accentBar];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12;
    [content addSubview:stack];

    for (NSDictionary *item in items) {
        UIButton *card = [self menuRowCardWithItem:item target:target action:action];
        [stack addArrangedSubview:card];
        [card.heightAnchor constraintEqualToConstant:76].active = YES;
    }

    UILayoutGuide *safe = hostView.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:hostView.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:hostView.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:hostView.bottomAnchor],

        [content.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor],
        [content.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor],
        [content.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor],
        [content.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor],
        [content.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor],

        [titleLabel.topAnchor constraintEqualToAnchor:content.topAnchor constant:16],
        [titleLabel.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-20],

        [subtitleLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:6],
        [subtitleLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [subtitleLabel.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor],

        [accentBar.topAnchor constraintEqualToAnchor:subtitleLabel.bottomAnchor constant:12],
        [accentBar.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [accentBar.widthAnchor constraintEqualToConstant:32],
        [accentBar.heightAnchor constraintEqualToConstant:4],

        [stack.topAnchor constraintEqualToAnchor:accentBar.bottomAnchor constant:20],
        [stack.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-16],
        [stack.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-28],
    ]];
}

@end
