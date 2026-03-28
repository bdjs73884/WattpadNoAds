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

// دالة بحث عميقة جداً
static void scanAndHideThingsBookAd(UIView *view) {
    if (!view) return;

    NSString *className = NSStringFromClass([view class]);

    if ([className containsString:@"Things"] || 
        [className containsString:@"Journal"] || 
        [className containsString:@"Promotion"] || 
        [className containsString:@"Ad"] || 
        [className containsString:@"Banner"]) {

        for (UIView *child in view.subviews) {
            if ([child isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)child;
                NSString *text = label.text ?: @"";
                if ([text containsString:@"ThingsBook"] ||
                    [text containsString:@"journal"] ||
                    [text containsString:@"Things"] ||
                    [text containsString:@"veD3"] ||
                    [text containsString:@"onelink"]) {

                    NSLog(@"[WattpadNoAds] BLOCKED ThingsBook House Ad (v13 timer)!");
                    view.hidden = YES;
                    view.alpha = 0;
                    [view removeFromSuperview];
                    return;
                }
            }
            scanAndHideThingsBookAd(child);
        }
    }
}

%ctor {
    NSLog(@"🚀 WattpadNoAds v13 FINAL - Timer scanning for ThingsBook ad!");

    // timer يراقب الشاشة كل 0.5 ثانية
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer *timer) {
            UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
            if (root && root.view) {
                scanAndHideThingsBookAd(root.view);
            }
        }];
    });
}