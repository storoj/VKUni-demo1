//
//  AppDelegate.m
//  VKDemo1
//
//  Created by Alexey Storozhev on 21/11/15.
//  Copyright © 2015 Aleksey Storozhev. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <VKSdkFramework/VKSdk.h>

@interface AppDelegate() <VKSdkDelegate, VKSdkUIDelegate>
@property (nonatomic, strong) VKSdk *sdk;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [UIViewController new];
    window.rootViewController.view.backgroundColor = [UIColor whiteColor];
    self.window = window;
    [window makeKeyAndVisible];
    
    [self configureVKClient];

    return YES;
}


- (void)configureVKClient
{
    VKSdk *sdkInstance = [VKSdk initializeWithAppId:@"4445963"];
    [sdkInstance registerDelegate:self];
    [sdkInstance setUiDelegate:self];
    
    self.sdk = sdkInstance;
    
    [VKSdk wakeUpSession:@[VK_PER_PHOTOS, VK_PER_FRIENDS] completeBlock:^(VKAuthorizationState state, NSError *error) {
        
        switch (state) {
            case VKAuthorizationAuthorized:
                break;
                
            case VKAuthorizationError:
                NSLog(@"VKSDK error: %@", error);
                break;
                
            case VKAuthorizationInitialized:
                [VKSdk authorize:@[@"friends"]];
                break;
                
            case VKAuthorizationExternal:
            case VKAuthorizationPending:
            case VKAuthorizationSafariInApp:
            case VKAuthorizationWebview:
            case VKAuthorizationUnknown:
                break;
        }
    }];
}

//iOS 9 workflow
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    [VKSdk processOpenURL:url fromApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
    return YES;
}
//iOS 8 and lower
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    return YES;
}

#pragma mark VKSdkDelegate

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    self.window.rootViewController = controller;
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    
}

- (void)vkSdkUserAuthorizationFailed {
    
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    
    if (result.token) {
        [UIView transitionWithView:self.window
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            ViewController *vc = [ViewController new];
                            vc.view.backgroundColor = [UIColor whiteColor];
                            self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:vc];
                        }
                        completion:^(BOOL finished) {
                            
                        }];
    }
    
}


@end
