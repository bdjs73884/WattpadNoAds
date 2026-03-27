#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

// تعريفات الكلاسات (كل شبكات الإعلانات في Wattpad 11.23.0)
@interface GADBannerView : UIView @end
@interface GADInterstitialAd : NSObject @end
@interface GADNativeAdView : UIView @end
@interface _GADAdView : UIView @end
@interface GADAdView : UIView @end

@interface MAAdView : UIView @end
@interface MAInterstitialAd : NSObject @end

@interface MAdvertiseView : UIView @end

@interface IMAdView : UIView @end

@interface HyBidAdView : UIView @end

@interface NimbusAdView : UIView @end
@interface DTBAdView : UIView @end

// دالة مساعدة داخلية
static void hideAdView(UIView *view) {
    if (!view) return;
    view.hidden = YES;
    view.alpha = 0;
    view.frame = CGRectZero;
    [view removeFromSuperview];
    NSLog(@"[WattpadNoAds] Removed ad: %@", NSStringFromClass([view class]));
}

%hook GADBannerView
- (void)layoutSubviews { %orig; hideAdView(self); }
- (void)loadRequest:(id)request { hideAdView(self); %orig(nil); }
%end

%hook GADNativeAdView
- (void)layoutSubviews { %orig; hideAdView(self); }
%end

%hook MAAdView
- (void)layoutSubviews { %orig; hideAdView(self); }
%end

%hook MAdvertiseView
- (void)layoutSubviews { %orig; hideAdView(self); }
%end

%hook IMAdView
- (void)layoutSubviews { %orig; hideAdView(self); }
%end

%hook HyBidAdView
- (void)layoutSubviews { %orig; hideAdView(self); }
%end

%hook NimbusAdView
- (void)layoutSubviews { %orig; hideAdView(self); }
%end

%hook DTBAdView
- (void)layoutSubviews { %orig; hideAdView(self); }
%end

%hook _GADAdView
- (void)layoutSubviews { %orig; hideAdView(self); }
%end

%hook GADAdView
- (void)layoutSubviews { %orig; hideAdView(self); }
%end

%hook GADInterstitialAd
+ (void)loadWithAdUnitID:(NSString *)adUnitID request:(id)request completionHandler:(id)handler {
    NSLog(@"[WattpadNoAds] Google Interstitial blocked");
}
%end

%hook MAInterstitialAd
+ (void)loadWithAdUnitID:(NSString *)adUnitID completionHandler:(id)handler {
    NSLog(@"[WattpadNoAds] AppLovin Interstitial blocked");
}
%end

%hook UIView
- (void)didMoveToWindow {
    %orig;
    NSString *className = NSStringFromClass([self class]);
    if ([className containsString:@"GAD"] || [className containsString:@"AdView"] ||
        [className containsString:@"MAAd"] || [className containsString:@"MAdvertise"] ||
        [className containsString:@"IMAd"] || [className containsString:@"HyBid"] ||
        [className containsString:@"Nimbus"] || [className containsString:@"DTB"]) {
        hideAdView(self);
    }
}
%end

%ctor {
    NSLog(@"🚀 WattpadNoAds v6.1 ULTRA Loaded - All ad networks blocked!");
}