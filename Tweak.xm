#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%ctor {
    NSLog(@"🚀 WattpadNoAds MINIMAL v6 LOADED SUCCESSFULLY - Injection works!");
    
    // رسالة على الشاشة عشان تتأكد
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"WattpadNoAds" 
            message:@"✅ التويك يعمل وانحقن بنجاح!\n(بدون إخفاء إعلانات بعد)" 
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}