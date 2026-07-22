//
//  SceneDelegate.m
//  BLAPPSDKDemo
//

#import "SceneDelegate.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "BLTheme.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }

    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];

    MainViewController *mainVC = [MainViewController viewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    nav.navigationBar.prefersLargeTitles = NO;
    self.window.rootViewController = nav;
    self.window.backgroundColor = [BLTheme backgroundColor];
    [self.window makeKeyAndVisible];

    AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    appDelegate.window = self.window;
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
