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
// Liquid Glass Popup (iOS 26 style)
// ======================
%ctor {
    NSLog(@"🚀 WattpadNoAds v16 FINAL - All ads blocked + Liquid Glass Message");

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) return;

        UIViewController *topVC = window.rootViewController;
        while (topVC.presentedViewController) topVC = topVC.presentedViewController;

        // Glass Container
        UIView *glass = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        glass.center = CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2 - 30);
        glass.layer.cornerRadius = 28;
        glass.layer.masksToBounds = YES;
        glass.alpha = 0;

        // Liquid Glass Effect
        UIBlurEffect *blur;
        if (@available(iOS 13.0, *)) {
            blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
        } else {
            blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        }

        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        blurView.frame = glass.bounds;
        blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [glass addSubview:blurView];

        // Vibrancy للنص (يجعله أكثر شفافية ولمعان)
        UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
        UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
        vibrancyView.frame = glass.bounds;
        vibrancyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        // Title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 280, 32)];
        title.text = @"Wattpad No Ads";
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:22 weight:UIFontWeightSemibold];
        title.textColor = [UIColor whiteColor];
        [vibrancyView.contentView addSubview:title];

        // Message
        UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(20, 65, 280, 80)];
        msg.text = @"✅ التويك شغال 100%%\ninstagram: hsm__200";
        msg.textAlignment = NSTextAlignmentCenter;
        msg.numberOfLines = 0;
        msg.font = [UIFont systemFontOfSize:16.5 weight:UIFontWeightMedium];
        msg.textColor = [UIColor whiteColor];
        [vibrancyView.contentView addSubview:msg];

        [glass addSubview:vibrancyView];

        // OK Button (شفاف وحديث)
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(35, 150, 250, 48);
        [btn setTitle:@"OK" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        btn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.18];
        btn.layer.cornerRadius = 24;
        [btn addTarget:glass action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
        [glass addSubview:btn];

        [window addSubview:glass];

        // Animation ناعمة
        glass.transform = CGAffineTransformMakeScale(0.8, 0.8);
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.6 options:0 animations:^{
            glass.alpha = 1;
            glass.transform = CGAffineTransformIdentity;
        } completion:nil];
    });
}