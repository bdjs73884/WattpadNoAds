#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

// ======================
// إخفاء كل الإعلانات
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
// Modern Window Retrieval (iOS 13+)
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

// ======================
// Real Liquid Glass Popup (iOS 26 style)
// ======================
%ctor {
    NSLog(@"🚀 WattpadNoAds v17 FINAL - All ads blocked + Real Liquid Glass");

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *window = HSMGetActiveKeyWindow();
        if (!window) return;

        UIViewController *topVC = HSMTopViewControllerFrom(window.rootViewController);
        if (!topVC) return;

        UIView *glassView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        glassView.center = CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2 - 30);
        glassView.layer.cornerRadius = 28;
        glassView.layer.masksToBounds = YES;
        glassView.alpha = 0;

        // Liquid Glass Effect
        if (@available(iOS 26.0, *)) {
            UIGlassEffect *glassEffect = [UIGlassEffect effectWithStyle:UIGlassEffectStyleRegular];
            UIVisualEffectView *glassBlur = [[UIVisualEffectView alloc] initWithEffect:glassEffect];
            glassBlur.frame = glassView.bounds;
            glassBlur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [glassView addSubview:glassBlur];
        } else {
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
            UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
            blurView.frame = glassView.bounds;
            blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [glassView addSubview:blurView];
        }

        // Title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 280, 32)];
        title.text = @"Wattpad No Ads";
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:22 weight:UIFontWeightSemibold];
        title.textColor = [UIColor whiteColor];
        [glassView addSubview:title];

        // Message
        UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(20, 65, 280, 80)];
        msg.text = @"✅ التويك شغال 100%%\ninstagram: hsm__200";
        msg.textAlignment = NSTextAlignmentCenter;
        msg.numberOfLines = 0;
        msg.font = [UIFont systemFontOfSize:16.5 weight:UIFontWeightMedium];
        msg.textColor = [UIColor whiteColor];
        [glassView addSubview:msg];

        // OK Button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(35, 150, 250, 48);
        [btn setTitle:@"OK" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        btn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.18];
        btn.layer.cornerRadius = 24;
        [btn addTarget:glassView action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
        [glassView addSubview:btn];

        [window addSubview:glassView];

        glassView.transform = CGAffineTransformMakeScale(0.85, 0.85);
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.6 options:0 animations:^{
            glassView.alpha = 1;
            glassView.transform = CGAffineTransformIdentity;
        } completion:nil];
    });
}