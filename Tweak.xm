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
    NSLog(@"[WattpadNoAds] Interstitial load blocked");
}

// هذا الـ hook الجديد والقوي يمنع عرض الإعلان بين البارتات
- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    NSLog(@"[WattpadNoAds] Blocked interstitial presentation between chapters");
    // ما يعرض الإعلان أبدًا
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

%ctor {
    NSLog(@"🚀 WattpadNoAds v9 FINAL - All ads & inter-chapter ads blocked!");
}