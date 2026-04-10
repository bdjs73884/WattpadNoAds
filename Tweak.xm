#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

// ======================
// إخفاء كل الإعلانات
// ======================
@interface GADBannerView : UIView @end
@interface GADInterstitialAd : NSObject @end
@interface GADNativeAdView : UIView @end
@interface _GADAdView : UIView @end
@interface GADAdView : UIView @end
@interface IMAWebUIViewController : UIViewController @end
@interface WKCompositingView : UIView @end
@interface WPCommentAdBannerCell : UITableViewCell @end
@interface AppDelegate : UIView @end

%hook AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        for (UIScene *scene in application.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive &&
                [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *w in windowScene.windows) {
                    if (w.isKeyWindow) {
                        window = w;
                        break;
                    }
                }
            }
            if (window) break;
        }
        if (!window) return;
        UIViewController *rootVC = window.rootViewController;

        while (rootVC.presentedViewController) {
            rootVC = rootVC.presentedViewController;
        }

        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Wattpad Tweaked"
            message:@"Type anything you want here — this alert is injected by your custom tweak!"
            preferredStyle:UIAlertControllerStyleAlert];

        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Type your message here...";
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }];

        UIAlertAction *okAction = [UIAlertAction
            actionWithTitle:@"OK"
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                UITextField *textField = alert.textFields.firstObject;
                NSString *userInput = textField.text;
                NSLog(@"[WattpadTweak] User typed: %@", userInput);
            }];

        UIAlertAction *dismissAction = [UIAlertAction
            actionWithTitle:@"Dismiss"
            style:UIAlertActionStyleCancel
            handler:nil];

        [alert addAction:okAction];
        [alert addAction:dismissAction];

        [rootVC presentViewController:alert animated:YES completion:nil];
    });

    return result;
}

%end