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
// Modern Key Window (iOS 13+)
// ======================
static UIWindow *HSMGetActiveKeyWindow(void) {
    UIApplication *app = [UIApplication sharedApplication];
    for (UIScene *scene in app.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        if (scene.activationState != UISceneActivationStateForegroundActive) continue;
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        for (UIWindow *w in windowScene.windows) {
            if (w.isKeyWindow) return w;
        }
        if (windowScene.windows.count > 0) return windowScene.windows.firstObject;
    }
    return nil;
}

// ======================
// UIGlassEffect الحقيقي (iOS 26)
// ======================
%ctor {
    NSLog(@"🚀 WattpadNoAds v19 - Real Liquid Glass iOS 26");

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *window = HSMGetActiveKeyWindow();
        if (!window) return;

        // Glass Container
        UIView *glassContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 340, 220)];
        glassContainer.center = CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2 - 40);
        glassContainer.layer.cornerRadius = 30;
        glassContainer.layer.masksToBounds = YES;
        glassContainer.alpha = 0;

        // Real Liquid Glass
        if (@available(iOS 26.0, *)) {
            UIGlassEffect *glass = [UIGlassEffect effectWithStyle:UIGlassEffectStyleRegular];
            UIVisualEffectView *glassView = [[UIVisualEffectView alloc] initWithEffect:glass];
            glassView.frame = glassContainer.bounds;
            [glassContainer addSubview:glassView];
        }

        // Title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 300, 32)];
        title.text = @"Wattpad No Ads";
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:23 weight:UIFontWeightSemibold];
        title.textColor = [UIColor whiteColor];
        [glassContainer addSubview:title];

        // Message
        UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(20, 65, 300, 80)];
        msg.text = @"✅ التويك شغال 100%%\ninstagram: hsm__200";
        msg.textAlignment = NSTextAlignmentCenter;
        msg.numberOfLines = 0;
        msg.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        msg.textColor = [UIColor whiteColor];
        [glassContainer addSubview:msg];

        // OK Button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(35, 155, 270, 52);
        [btn setTitle:@"OK" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:19 weight:UIFontWeightSemibold];
        btn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.18];
        btn.layer.cornerRadius = 26;
        [btn addTarget:glassContainer action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
        [glassContainer addSubview:btn];

        [window addSubview:glassContainer];

        // Animation
        glassContainer.transform = CGAffineTransformMakeScale(0.85, 0.85);
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.6 options:0 animations:^{
            glassContainer.alpha = 1.0;
            glassContainer.transform = CGAffineTransformIdentity;
        } completion:nil];
    });
}