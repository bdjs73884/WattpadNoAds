#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

// تعريفات الكلاسات للإعلانات العادية
@interface GADBannerView : UIView @end
@interface GADInterstitialAd : NSObject @end
@interface GADNativeAdView : UIView @end
@interface _GADAdView : UIView @end
@interface GADAdView : UIView @end

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

// 🔥 الـ hook الخاص بـ ThingsBook (الداخلي)
%hook UIView
- (void)addSubview:(UIView *)subview {
    %orig(subview);

    NSString *className = NSStringFromClass([subview class]);

    if ([className containsString:@"Things"] ||
        [className containsString:@"Journal"] ||
        [className containsString:@"Promotion"] ||
        [className containsString:@"Ad"] ||
        [className containsString:@"Banner"]) {

        // نبحث داخل النصوص أيضاً
        for (UIView *child in subview.subviews) {
            if ([child isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)child;
                if ([label.text containsString:@"ThingsBook"] ||
                    [label.text containsString:@"journal"] ||
                    [label.text containsString:@"Things"] ||
                    [label.text containsString:@"Things"]) {

                    NSLog(@"[WattpadNoAds] BLOCKED ThingsBook House Ad between chapters!");
                    subview.hidden = YES;
                    subview.alpha = 0;
                    [subview removeFromSuperview];
                    return;
                }
            }
        }
    }
}
%end

%ctor {
    NSLog(@"🚀 WattpadNoAds v11 FINAL - ThingsBook house ads blocked!");
}