#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface RTReadingViewController : UIViewController @end

%hook RTReadingViewController

- (BOOL)canShowDisplayAdsInInterstitials {
    NSLog(@"[TEST] forcing canShowDisplayAdsInInterstitials = YES");
    return YES;
}

%end

%ctor {
    %init(RTReadingViewController = objc_getClass("Wattpad.RTReadingViewController"));
}