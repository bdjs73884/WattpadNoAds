#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface RTReadingViewController : UIViewController @end

%hook RTReadingViewController

- (void)readerWebViewPageToNextPart:(id)arg1 {
    NSLog(@"[TEST] readerWebViewPageToNextPart: CALLED | arg1=%@", arg1);
    %orig(arg1);
}

- (BOOL)goToNextPartAndSkipInterstitial:(BOOL)arg1 {
    NSLog(@"[TEST] goToNextPartAndSkipInterstitial: CALLED | skip=%d", arg1);
    BOOL result = %orig(arg1);
    NSLog(@"[TEST] goToNextPartAndSkipInterstitial: RETURNED | result=%d", result);
    return result;
}

- (BOOL)goToNextPartAndSkipInterstitial:(BOOL)arg1 animated:(BOOL)arg2 {
    NSLog(@"[TEST] goToNextPartAndSkipInterstitial:animated: CALLED | skip=%d animated=%d", arg1, arg2);
    BOOL result = %orig(arg1, arg2);
    NSLog(@"[TEST] goToNextPartAndSkipInterstitial:animated: RETURNED | result=%d", result);
    return result;
}

- (BOOL)didGoToNextPart {
    BOOL result = %orig;
    NSLog(@"[TEST] didGoToNextPart CALLED | return=%d", result);
    return result;
}

- (void)setDidGoToNextPart:(BOOL)arg1 {
    NSLog(@"[TEST] setDidGoToNextPart: CALLED | value=%d", arg1);
    %orig(arg1);
}

%end

%ctor {
    %init(
        RTReadingViewController = objc_getClass("Wattpad.RTReadingViewController")
    );
    NSLog(@"[TEST] RTReadingViewController hooks loaded");
}