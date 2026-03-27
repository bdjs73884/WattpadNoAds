#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

// تعريفات الكلاسات
@interface GADBannerView : UIView @end
@interface GADInterstitialAd : NSObject @end
@interface GADNativeAdView : UIView @end
@interface _GADAdView : UIView @end
@interface GADAdView : UIView @end

%hook GADBannerView
- (void)layoutSubviews {
    %orig;
    self.hidden = YES;
    self.alpha = 0;
    self.frame = CGRectZero;
}
- (void)loadRequest:(id)request {
    self.hidden = YES;
    self.alpha = 0;
    %orig(nil);
}
%end

%hook GADInterstitialAd
+ (void)loadWithAdUnitID:(NSString *)adUnitID request:(id)request completionHandler:(id)handler {
    NSLog(@"[WattpadNoAds] Interstitial blocked");
}
%end

%hook GADNativeAdView
- (void)layoutSubviews {
    %orig;
    self.hidden = YES;
    self.alpha = 0;
}
%end

%hook _GADAdView
- (void)layoutSubviews {
    %orig;
    self.hidden = YES;
    self.alpha = 0;
    [self removeFromSuperview];
}
%end

%hook GADAdView
- (void)layoutSubviews {
    %orig;
    self.hidden = YES;
    self.alpha = 0;
}
%end

%hook UIView
- (void)didMoveToWindow {
    %orig;
    NSString *className = NSStringFromClass([self class]);
    if ([className containsString:@"GAD"] ||
        [className containsString:@"AdView"] ||
        [className containsString:@"AdBanner"] ||
        (CGRectGetHeight(self.frame) <= 100 && CGRectGetHeight(self.frame) >= 50)) {
        self.hidden = YES;
        self.alpha = 0;
        [self removeFromSuperview];
        NSLog(@"[WattpadNoAds] Removed ad: %@", className);
    }
}
%end

%ctor {
    NSLog(@"🚀 WattpadNoAds CRASH TEST - Tweak is LOADED and INJECTED!");
    
    // هنا الكراش المتعمد (عشان تتأكد إنه يشتغل)
    [NSException raise:@"WattpadNoAdsCrashTest" format:@"✅ التويك يعمل! WattpadNoAds injected successfully."];
}