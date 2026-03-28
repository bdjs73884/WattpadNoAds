#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

// ======================
// إخفاء كل الإعلانات (اللي نجحت سابقاً)
// ======================
@interface GADBannerView : UIView @end
@interface GADInterstitialAd : NSObject @end
@interface GADNativeAdView : UIView @end
@interface _GADAdView : UIView @end
@interface GADAdView : UIView @end
@interface IMAWebUIViewController : UIViewController @end
@interface WKCompositingView : UIView @end

%hook GADBannerView
- (void)layoutSubviews { %orig; self.hidden = YES; self.alpha = 0; self.frame = CGRectZero; }
- (void)loadRequest:(id)request { self.hidden = YES; self.alpha = 0; %orig(nil); }
%end

%hook GADInterstitialAd
+ (void)loadWithAdUnitID:(NSString *)adUnitID request:(id)request completionHandler:(id)handler {
    NSLog(@"[WattpadNoAds] Interstitial blocked");
}
%end

%hook GADNativeAdView
- (void)layoutSubviews { %orig; self.hidden = YES; self.alpha = 0; }
%end

%hook _GADAdView
- (void)layoutSubviews { %orig; self.hidden = YES; self.alpha = 0; [self removeFromSuperview]; }
%end

%hook GADAdView
- (void)layoutSubviews { %orig; self.hidden = YES; self.alpha = 0; }
%end

%hook IMAWebUIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    self.view.hidden = YES;
    self.view.alpha = 0;
    [self.view removeFromSuperview];
}
%end

%hook WKCompositingView
- (void)layoutSubviews {
    %orig;
    for (UIView *sub in self.subviews) {
        if ([sub isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)sub;
            if ([lbl.text containsString:@"ThingsBook"] || [lbl.text containsString:@"journal"] || [lbl.text containsString:@"Things"]) {
                NSLog(@"[WattpadNoAds] BLOCKED ThingsBook House Ad!");
                self.hidden = YES;
                self.alpha = 0;
                [self removeFromSuperview];
                return;
            }
        }
    }
}
%end

// ======================
// الكود الجديد من GPT (الأفضل لعرض الرسالة)
// ======================
static UIViewController *HSMTopViewControllerFrom(UIViewController *vc) {
    if (!vc) return nil;
    while (vc.presentedViewController) vc = vc.presentedViewController;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return HSMTopViewControllerFrom(nav.visibleViewController ?: nav.topViewController);
    }
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)vc;
        return HSMTopViewControllerFrom(tab.selectedViewController);
    }
    return vc;
}

static UIWindow *HSMGetActiveKeyWindow(void) {
    UIApplication *app = [UIApplication sharedApplication];
    for (UIScene *scene in app.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        if (scene.activationState != UISceneActivationStateForegroundActive) continue;
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        for (UIWindow *window in windowScene.windows) {
            if (window.isKeyWindow) return window;
        }
        if (windowScene.windows.count > 0) return windowScene.windows.firstObject;
    }
    return nil;
}

static void HSMPresentWelcomeAlert(NSInteger retriesLeft) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = HSMGetActiveKeyWindow();
        UIViewController *topVC = HSMTopViewControllerFrom(window.rootViewController);

        if (!topVC) {
            if (retriesLeft > 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    HSMPresentWelcomeAlert(retriesLeft - 1);
                });
            }
            return;
        }

        if (topVC.presentedViewController) {
            if (retriesLeft > 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    HSMPresentWelcomeAlert(retriesLeft - 1);
                });
            }
            return;
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Wattpad No Ads"
            message:@"✅ التويك شغال 100%%\n\ninstagram: hsm__200"
            preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];

        [topVC presentViewController:alert animated:YES completion:nil];
    });
}

%ctor {
    NSLog(@"🚀 WattpadNoAds v15 FINAL LOADED - All ads blocked + Welcome message");

    // عرض الرسالة بعد 1.5 ثانية (مع retries)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        HSMPresentWelcomeAlert(6);   // 6 محاولات كحد أقصى
    });
}