#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// تعريفات الكلاسات
@interface IMAWebUIViewController : UIViewController @end
@interface WKCompositingView : UIView @end

%hook IMAWebUIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    NSLog(@"[WattpadNoAds] IMAWebUIViewController appeared → ThingsBook ad blocked!");
    self.view.hidden = YES;
    self.view.alpha = 0;
    [self.view removeFromSuperview];
}
%end

%hook WKCompositingView
- (void)layoutSubviews {
    %orig;
    // نبحث عن أي محتوى يخص ThingsBook
    for (UIView *sub in self.subviews) {
        if ([sub isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)sub;
            if ([lbl.text containsString:@"ThingsBook"] || 
                [lbl.text containsString:@"journal"] || 
                [lbl.text containsString:@"Things"]) {
                
                NSLog(@"[WattpadNoAds] BLOCKED ThingsBook Web Ad!");
                self.hidden = YES;
                self.alpha = 0;
                [self removeFromSuperview];
                return;
            }
        }
    }
}
%end

%ctor {
    NSLog(@"🚀 WattpadNoAds v14 FINAL - IMAWeb + WKCompositingView blocked!");
}