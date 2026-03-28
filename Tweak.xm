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

// دالة مساعدة تبحث داخل كل الـ subviews بشكل عميق
static void hideThingsBookAd(UIView *view) {
    if (!view) return;

    NSString *className = NSStringFromClass([view class]);

    if ([className containsString:@"Things"] ||
        [className containsString:@"Journal"] ||
        [className containsString:@"Promotion"] ||
        [className containsString:@"Ad"] ||
        [className containsString:@"Banner"]) {

        // نبحث داخل النصوص
        for (UIView *child in view.subviews) {
            if ([child isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)child;
                NSString *text = label.text ?: @"";
                if ([text containsString:@"ThingsBook"] ||
                    [text containsString:@"journal"] ||
                    [text containsString:@"Things"] ||
                    [text containsString:@"veD3"] ||
                    [text containsString:@"onelink"]) {

                    NSLog(@"[WattpadNoAds] BLOCKED ThingsBook House Ad (recursive)!");
                    view.hidden = YES;
                    view.alpha = 0;
                    [view removeFromSuperview];
                    return;
                }
            }
            hideThingsBookAd(child); // بحث عميق
        }
    }
}

// الـ hooks القوية
%hook UIView
- (void)addSubview:(UIView *)subview {
    %orig(subview);
    hideThingsBookAd(subview);
}

- (void)insertSubview:(UIView *)subview atIndex:(NSInteger)index {
    %orig(subview, index);
    hideThingsBookAd(subview);
}

- (void)bringSubviewToFront:(UIView *)subview {
    %orig(subview);
    hideThingsBookAd(subview);
}
%end

%ctor {
    NSLog(@"🚀 WattpadNoAds v12 FINAL - ThingsBook house ads blocked recursively!");
}