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
// الكود الجديد (مع @available عشان ما يفشل البناء)
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

static void HSMPresentWelcomeAlert(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) return;
        
        UIViewController *topVC = HSMTopViewControllerFrom(window.rootViewController);
        if (!topVC || topVC.presentedViewController) return;

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

    // عرض الرسالة
    HSMPresentWelcomeAlert();
}