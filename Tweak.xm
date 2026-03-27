#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

// تعريفات الكلاسات الرئيسية
@interface GADBannerView : UIView @end
@interface GADInterstitialAd : NSObject @end
@interface GADNativeAdView : UIView @end
@interface _GADAdView : UIView @end
@interface GADAdView : UIView @end

// AppLovin
@interface MAAdView : UIView @end
@interface MAInterstitialAd : NSObject @end

// Moloco
@interface MAdvertiseView : UIView @end

// InMobi
@interface IMAdView : UIView @end

// HyBid
@interface HyBidAdView : UIView @end

// Nimbus & DTB
@interface NimbusAdView : UIView @end
@interface DTBAdView : UIView @end

%hook GADBannerView
- (void)layoutSubviews { %orig; [self hideAd]; }
- (void)loadRequest:(id)request { self.hidden = YES; %orig(nil); }
%end

%hook GADInterstitialAd
+ (void)loadWithAdUnitID:(NSString *)adUnitID request:(id)request completionHandler:(id)handler {
    NSLog(@"[WattpadNoAds] Google Interstitial blocked");
}
%end

%hook GADNativeAdView
- (void)layoutSubviews { %orig; [self hideAd]; }
%end

%hook MAAdView
- (void)layoutSubviews { %orig; [self hideAd]; }
%end

%hook MAInterstitialAd
+ (void)loadWithAdUnitID:(NSString *)adUnitID completionHandler:(id)handler {
    NSLog(@"[WattpadNoAds] AppLovin Interstitial blocked");
}
%end

%hook MAdvertiseView
- (void)layoutSubviews { %orig; [self hideAd]; }
%end

%hook IMAdView
- (void)layoutSubviews { %orig; [self hideAd]; }
%end

%hook HyBidAdView
- (void)layoutSubviews { %orig; [self hideAd]; }
%end

%hook NimbusAdView
- (void)layoutSubviews { %orig; [self hideAd]; }
%end

%hook DTBAdView
- (void)layoutSubviews { %orig; [self hideAd]; }
%end

%hook _GADAdView
- (void)layoutSubviews { %orig; [self hideAd]; }
%end

%hook GADAdView
- (void)layoutSubviews { %orig; [self hideAd]; }
%end

// دالة مساعدة تخفي أي إعلان
%hook UIView
- (void)hideAd {
    self.hidden = YES;
    self.alpha = 0;
    self.frame = CGRectZero;
    [self removeFromSuperview];
    NSLog(@"[WattpadNoAds] Removed ad view: %@", NSStringFromClass([self class]));
}

- (void)didMoveToWindow {
    %orig;
    NSString *className = NSStringFromClass([self class]);
    if ([className containsString:@"GAD"] || [className containsString:@"AdView"] ||
        [className containsString:@"MAAd"] || [className containsString:@"MAdvertise"] ||
        [className containsString:@"IMAd"] || [className containsString:@"HyBid"] ||
        [className containsString:@"Nimbus"] || [className containsString:@"DTB"] ||
        (CGRectGetHeight(self.frame) <= 120 && CGRectGetHeight(self.frame) >= 40)) {
        [self hideAd];
    }
}
%end

%ctor {
    NSLog(@"🚀 WattpadNoAds v6 ULTRA Loaded - All ad networks blocked!");
}