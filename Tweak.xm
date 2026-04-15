#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <objc/runtime.h>

@interface CommentViewController : UIViewController @end

%hook CommentViewController

- (CGFloat)makeWPCommentAdBannerCellHeightAt:(id)arg1 {
    return 0.01;
}

%end

%ctor {
    %init(CommentViewController = objc_getClass("Wattpad.CommentViewController"));
}