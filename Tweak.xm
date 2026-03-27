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

// الـ hook الجديد والقوي عشان ThingsBook
%hook UIViewController
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    NSString *className = NSStringFromClass([viewControllerToPresent class]);
    NSString *title = viewControllerToPresent.title ?: @"";
    
    if ([className containsString:@"Ad"] || 
        [className containsString:@"Promotion"] || 
        [className containsString:@"Interstitial"] ||
        [title containsString:@"ThingsBook"] || 
        [className containsString:@"ThingsBook"]) {
        
        NSLog(@"[WattpadNoAds] BLOCKED ThingsBook Promo Ad between chapters!");
        return;   // ما يعرض الإعلان أبدًا
    }
    %orig;
}
%end

%ctor {
    NSLog(@"🚀 WattpadNoAds v10 FINAL - All ads including ThingsBook blocked!");
}