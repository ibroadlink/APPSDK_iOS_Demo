//
//  SceneDelegate.m
//  BLAPPSDKDemo
//

#import "SceneDelegate.h"
#import "AppDelegate.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }

    // Main.storyboard 已在 Info.plist 的 UISceneStoryboardFile 中配置，系统会创建 window。
    // 这里同步给 AppDelegate，兼容旧代码里对 window 的访问。
    AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    if (self.window) {
        appDelegate.window = self.window;
    } else {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyboard instantiateInitialViewController];
        [self.window makeKeyAndVisible];
        appDelegate.window = self.window;
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene {
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
}

- (void)sceneWillResignActive:(UIScene *)scene {
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
}

@end
