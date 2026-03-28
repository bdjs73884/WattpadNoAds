#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

// ======================
// إخفاء كل الإعلانات (كما نجح سابقاً)
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
// Custom Glass Popup (iOS 26 Liquid Glass Style)
// ======================
%ctor {
    NSLog(@"🚀 WattpadNoAds v16 FINAL - All ads blocked + Modern Glass Message");

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) return;

        UIViewController *topVC = window.rootViewController;
        while (topVC.presentedViewController) topVC = topVC.presentedViewController;

        // ──────── Glass Container ────────
        UIView *glassView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
        glassView.center = CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2);
        glassView.layer.cornerRadius = 24;
        glassView.layer.masksToBounds = YES;
        glassView.alpha = 0;

        // Blur + Vibrancy (Liquid Glass)
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        blurView.frame = glassView.bounds;
        blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [glassView addSubview:blurView];

        UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
        UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
        vibrancyView.frame = glassView.bounds;
        vibrancyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        // Title
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 28)];
        titleLabel.text = @"Wattpad No Ads";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
        titleLabel.textColor = [UIColor whiteColor];
        [vibrancyView.contentView addSubview:titleLabel];

        // Message
        UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, 280, 70)];
        msgLabel.text = @"✅ التويك شغال 100%%\ninstagram: hsm__200";
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.numberOfLines = 0;
        msgLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        msgLabel.textColor = [UIColor whiteColor];
        [vibrancyView.contentView addSubview:msgLabel];

        [glassView addSubview:vibrancyView];

        // Modern OK Button
        UIButton *okButton = [UIButton buttonWithType:UIButtonTypeSystem];
        okButton.frame = CGRectMake(40, 135, 240, 44);
        [okButton setTitle:@"OK" forState:UIControlStateNormal];
        okButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        okButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
        okButton.layer.cornerRadius = 22;
        [okButton addTarget:glassView action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
        [glassView addSubview:okButton];

        [window addSubview:glassView];

        // Animation
        glassView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:0 animations:^{
            glassView.alpha = 1;
            glassView.transform = CGAffineTransformIdentity;
        } completion:nil];
    });
}