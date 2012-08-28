#import <QuartzCore/QuartzCore.h>
#import "PHFRefreshControl.h"

static char kKVOContext;
static CGFloat const kViewHeight = 44;
static CGFloat const kMaxStretchFactor = 1.5;
static NSTimeInterval const kAnimationDuration = 0.25;

@interface PHFRefreshControl ()
@property (nonatomic, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, unsafe_unretained) UIScrollView *scrollView;
@property (nonatomic, strong) NSDate *animationStartDate;
@end

@implementation PHFRefreshControl

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 100, kViewHeight)];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];

    [[self layer] setAnchorPoint:CGPointMake(0, 1)];

    [self addSubview:[self arrowImageView]];
    [self addSubview:[self activityIndicatorView]];

    return self;
}

- (void)willMoveToSuperview:(UIView *)superview {
    if (superview)
        [self willBeAddedToScrollView:(UIScrollView *)superview];
    else
        [self willBeRemovedFromScrollView];
}

- (void)beginRefreshing {
    if (![self isRefreshing]) {
        [self setAnimationStartDate:[NSDate date]];
        [self setRefreshing:YES];
    }
}

- (void)endRefreshing {
    if ([self isRefreshing]) {
        NSTimeInterval timeIntervalSinceAnimationStart = -[[self animationStartDate] timeIntervalSinceNow];
        BOOL didAnimationFinish = timeIntervalSinceAnimationStart >= kAnimationDuration;

        if (didAnimationFinish) {
            [self setRefreshing:NO];
        } else {
            NSTimeInterval remainingAnimationDuration = kAnimationDuration - timeIntervalSinceAnimationStart;
            [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:remainingAnimationDuration];
        }
    }
}

#pragma mark - Accessors

@synthesize scrollView = _scrollView;

- (void)setRefreshing:(BOOL)refreshing {
    _refreshing = refreshing;

    if (refreshing) {
        UIEdgeInsets inset = [[self scrollView] contentInset];
        inset.top += kViewHeight;

        // Offset changes when changing inset. Store value before changing inset
        // in order to set offset back to previous value.
        CGPoint offset = [[self scrollView] contentOffset];

        // Cancel dragging.
        [[self scrollView] setScrollEnabled:NO];
        [[self scrollView] setScrollEnabled:YES];

        // Tweak content inset and adjust offset to look like before.
        [[self scrollView] setContentInset:inset];
        [[self scrollView] setContentOffset:offset];

        [[self layer] setAnchorPoint:CGPointMake(0, 0)];

        CGRect frame = [self frame];
        frame.origin.y = -kViewHeight * kMaxStretchFactor;
        [self setFrame:frame];

        [UIView animateWithDuration:kAnimationDuration animations:^{
            [[self arrowImageView] setAlpha:0];
            [[self activityIndicatorView] setAlpha:1];
            [[self scrollView] setContentOffset:CGPointMake(0, -inset.top)];
            [[self layer] setAffineTransform:CGAffineTransformIdentity];
        }];
    } else {
        UIEdgeInsets inset = [[self scrollView] contentInset];
        inset.top -= kViewHeight;

        [[self layer] setAnchorPoint:CGPointMake(0, 1)];

        CGRect frame = [self frame];
        frame.origin.y = -kViewHeight;
        [self setFrame:frame];

        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                                        [[self scrollView] setContentInset:inset];
                                    }
                         completion:^(BOOL finished){
                                        [[self arrowImageView] setAlpha:1];
                                        [[self activityIndicatorView] setAlpha:0];
                                    }];
    }
}

@synthesize arrowImageView = _arrowImageView;
- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];

        [_arrowImageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];

        [self updateArrowImage];
        [_arrowImageView sizeToFit];
        [_arrowImageView setCenter:[self centerForSubviews]];
    }

    return _arrowImageView;
}

@synthesize activityIndicatorView = _activityIndicatorView;
- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        [_activityIndicatorView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [_activityIndicatorView setCenter:[self centerForSubviews]];
        [_activityIndicatorView startAnimating];
        [[self activityIndicatorView] setAlpha:0];
    }

    return _activityIndicatorView;
}

@synthesize tintColor = _tintColor;
- (UIColor *)tintColor {
    if (!_tintColor)
        _tintColor = [UIColor grayColor];

    return _tintColor;
}
- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    [self updateArrowImage];
}

#pragma mark - Helpers

- (void)willBeAddedToScrollView:(UIScrollView *)scrollView {
    [self setScrollView:scrollView];
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:&kKVOContext];
    CGRect frame = CGRectMake(0, -kViewHeight, [scrollView bounds].size.width, kViewHeight);
    [self setFrame:frame];
}

- (void)willBeRemovedFromScrollView {
    [[self scrollView] removeObserver:self forKeyPath:@"contentOffset" context:&kKVOContext];
    [self setScrollView:nil];
}

- (void)updateArrowImage {
    [[self arrowImageView] setImage:[self drawArrowImage]];
}

- (CGPoint)centerForSubviews {
    CGRect bounds = [self bounds];
    return CGPointMake(floorf(bounds.size.width / 2), floorf(bounds.size.height / 2));
}

- (UIImage *)drawArrowImage {
    CGSize size = CGSizeMake(21, 40);
    CGRect rect = CGRectZero;
    rect.size = size;

    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);

    CGContextRef c = UIGraphicsGetCurrentContext();

    // the rects above the arrow
    CGContextAddRect(c, CGRectMake(6,  0, 9, 2));
    CGContextAddRect(c, CGRectMake(6,  4, 9, 3));
    CGContextAddRect(c, CGRectMake(6,  9, 9, 4));
    CGContextAddRect(c, CGRectMake(6, 15, 9, 5));
    CGContextAddRect(c, CGRectMake(6, 22, 9, 6));

    // the arrow tip
    CGContextMoveToPoint(   c,  0  , 28);
    CGContextAddLineToPoint(c, 10.5, 38.5);
    CGContextAddLineToPoint(c, 21  , 28);
    CGContextAddLineToPoint(c,  0,   28);
    CGContextClosePath(c);

    CGContextSaveGState(c);
    CGContextClip(c);

    // Gradient Declaration
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat alphaGradientLocations[] = {0, 28.0/40};

    CGGradientRef alphaGradient = nil;
    NSArray* alphaGradientColors = [NSArray arrayWithObjects:
                                    (id)[[self tintColor] colorWithAlphaComponent:0.2].CGColor,
                                    (id)[[self tintColor] colorWithAlphaComponent:1].CGColor,
                                    nil];
    alphaGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)alphaGradientColors, alphaGradientLocations);

    CGContextDrawLinearGradient(c, alphaGradient, CGPointZero, CGPointMake(0, size.height), 0);

    CGContextRestoreGState(c);

    CGGradientRelease(alphaGradient);
    CGColorSpaceRelease(colorSpace);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &kKVOContext) {
        if ([keyPath isEqualToString:@"contentOffset"])
            [self scrollViewDidScroll:[[change objectForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    CGFloat offsetY= -contentOffset.y - [[self scrollView] contentInset].top;

    if ([self isRefreshing]) {
        // Always keep view on top unless scrolling down in which case the view
        // should move with the content.
        CGRect frame = [self frame];
        frame.origin.y = MIN(-kViewHeight - offsetY, -kViewHeight);
        [self setFrame:frame];
    } else {
        // Stretch the view until a max stretch factor which triggers a refresh.
        CGFloat stretchFactor = MAX(offsetY / kViewHeight, 1);
        CGAffineTransform transform = CGAffineTransformMakeScale(1, stretchFactor);

        if (stretchFactor > kMaxStretchFactor) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            [self beginRefreshing];
        } else {
            [[self layer] setAffineTransform:transform];
        }
    }
}

@end

#import <objc/runtime.h>

static char kRefreshControlKey;

@implementation UIScrollView (PHFRefreshControl)

- (void)setRefreshControl:(PHFRefreshControl *)refreshControl {
    [[self refreshControl] removeFromSuperview];
    [self addSubview:refreshControl];
    objc_setAssociatedObject(self, &kRefreshControlKey, refreshControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PHFRefreshControl *)refreshControl {
    return objc_getAssociatedObject(self, &kRefreshControlKey);
}

@end

