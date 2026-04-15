#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface GADBannerView : UIView @end
@interface GADInterstitialAd : NSObject @end
@interface GADNativeAdView : UIView @end
@interface _GADAdView : UIView @end
@interface GADAdView : UIView @end
@interface IMAWebUIViewController : UIViewController @end
@interface WKCompositingView : UIView @end
@interface WPCommentAdBannerCell : UITableViewCell @end

%hook #import <objc/runtime.h>

%hook WPCommentAdBannerCell

- (void)didMoveToWindow {
    %orig;
    self.hidden = YES;
}

%end

%ctor {
    %init(WPCommentAdBannerCell = objc_getClass("Wattpad.WPCommentAdBannerCell"));
}

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
    self.view.hidden = YES; self.view.alpha = 0; [self.view removeFromSuperview];
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
                self.hidden = YES; self.alpha = 0; [self removeFromSuperview];
                return;
            }
        }
    }
}
%end

// ======================
// إخفاء إعلان التعليقات (النسخة القوية v2)
// ======================

- (void)awakeFromNib {
    %orig;
    self.hidden = YES;
    self.alpha = 0;
    NSLog(@"[WattpadNoAds] WPCommentAdBannerCell → awakeFromNib → Hidden");
}

- (void)layoutSubviews {
    %orig;
    self.hidden = YES;
    self.alpha = 0;
    self.contentView.hidden = YES;
    self.contentView.alpha = 0;
    NSLog(@"[WattpadNoAds] WPCommentAdBannerCell → layoutSubviews → Hidden");
}

- (void)didMoveToSuperview {
    %orig;
    if (self.superview) {
        [self removeFromSuperview];
        NSLog(@"[WattpadNoAds] WPCommentAdBannerCell → Removed from superview");
    }
}

- (void)setHidden:(BOOL)hidden {
    %orig(YES);   // نجبره دائماً يكون مخفي
}

%end

// ======================
// الكود اللي أرسلته (بالضبط)
// ======================
static UIWindow *HSMGetActiveKeyWindow(void) {
    UIApplication *app = [UIApplication sharedApplication];

    for (UIScene *scene in app.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        if (scene.activationState != UISceneActivationStateForegroundActive) continue;

        UIWindowScene *windowScene = (UIWindowScene *)scene;

        if (windowScene.keyWindow) {
            return windowScene.keyWindow;
        }

        for (UIWindow *w in windowScene.windows) {
            if (w.isKeyWindow) return w;
        }
    }

    return nil;
}

static UIViewController *HSMTopViewController(UIViewController *vc) {
    if (!vc) return nil;

    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }

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

static void HSMPresentSystemAlert(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{

        UIWindow *window = HSMGetActiveKeyWindow();
        if (!window) return;

        UIViewController *topVC = HSMTopViewController(window.rootViewController);
        if (!topVC) return;

        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Wattpad No Ads"
                                            message:@"✅ التويك شغال 100٪\ninstagram: hsm__200"
                                     preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *ok =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:nil];

        [alert addAction:ok];
        [topVC presentViewController:alert animated:YES completion:nil];
    });
}

%ctor {
    NSLog(@"🚀 WattpadNoAds - System Style Alert Loaded");
    HSMPresentSystemAlert();
}