#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// ======================
// PREMIUM UNLOCK ONLY
// ======================

%hook WPUser
- (BOOL)isPremium { 
    NSLog(@"[WattpadNoAds] WPUser → isPremium called → YES");
    return YES; 
}
- (BOOL)hasPremium { 
    NSLog(@"[WattpadNoAds] WPUser → hasPremium called → YES");
    return YES; 
}
- (BOOL)isSubscribed { 
    NSLog(@"[WattpadNoAds] WPUser → isSubscribed called → YES");
    return YES; 
}
%end

%hook WPPremiumManager
- (BOOL)isPremiumUser { 
    NSLog(@"[WattpadNoAds] WPPremiumManager → isPremiumUser → YES");
    return YES; 
}
- (BOOL)userHasPremiumAccess { 
    NSLog(@"[WattpadNoAds] WPPremiumManager → userHasPremiumAccess → YES");
    return YES; 
}
- (BOOL)canAccessPremiumFeatures { 
    NSLog(@"[WattpadNoAds] WPPremiumManager → canAccessPremiumFeatures → YES");
    return YES; 
}
%end

%hook WPSubscription
- (BOOL)isActive { 
    NSLog(@"[WattpadNoAds] WPSubscription → isActive → YES");
    return YES; 
}
%end

%hook WPPaywallViewController
- (void)viewDidLoad {
    %orig;
    NSLog(@"[WattpadNoAds] Paywall appeared → Closing it");
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)presentPaywall { 
    NSLog(@"[WattpadNoAds] Paywall blocked");
    return; 
}
%end

%hook WPReadingViewController
- (BOOL)shouldShowPaywall { 
    NSLog(@"[WattpadNoAds] shouldShowPaywall → NO");
    return NO; 
}
- (BOOL)hasPremiumAccess { 
    NSLog(@"[WattpadNoAds] hasPremiumAccess → YES");
    return YES; 
}
%end

// ======================
// الرسالة التنبيهية (نفس النص القديم بالضبط)
// ======================
static UIWindow *HSMGetActiveKeyWindow(void) {
    UIApplication *app = [UIApplication sharedApplication];
    for (UIScene *scene in app.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        if (scene.activationState != UISceneActivationStateForegroundActive) continue;
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        if (windowScene.keyWindow) return windowScene.keyWindow;
        for (UIWindow *w in windowScene.windows) {
            if (w.isKeyWindow) return w;
        }
    }
    return nil;
}

static UIViewController *HSMTopViewController(UIViewController *vc) {
    if (!vc) return nil;
    while (vc.presentedViewController) vc = vc.presentedViewController;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return HSMTopViewController(nav.visibleViewController ?: nav.topViewController);
    }
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)vc;
        return HSMTopViewController(tab.selectedViewController);
    }
    return vc;
}

static void HSMPresentAlert(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *window = HSMGetActiveKeyWindow();
        if (!window) return;
        UIViewController *topVC = HSMTopViewController(window.rootViewController);
        if (!topVC) return;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Wattpad No Ads"
                                                                      message:@"✅ التويك شغال 100٪\ninstagram: hsm__200"
                                                               preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [topVC presentViewController:alert animated:YES completion:nil];
    });
}

%ctor {
    NSLog(@"🚀 WattpadNoAds Premium Unlock v21 LOADED");
    HSMPresentAlert();
}