#import <UIKit/UIKit.h>

@interface PHFRefreshControl : UIControl

// Designated initializer.
- (id)init;

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

- (void)beginRefreshing;
- (void)endRefreshing;

@end

@interface UIScrollView (PHFRefreshControl)
@property (nonatomic, strong) PHFRefreshControl *refreshControl;
@end
