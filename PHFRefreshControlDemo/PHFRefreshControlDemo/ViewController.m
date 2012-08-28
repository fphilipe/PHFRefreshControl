#import "ViewController.h"
#import "PHFRefreshControl.h"

@interface ViewController ()
@property (nonatomic, readonly) UITableView *tableView;
@end

@implementation ViewController

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    [self setView:view];
    
    [view addSubview:[self tableView]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    [label setBackgroundColor:[UIColor redColor]];
    [label setText:@"Content Inset"];
    [label setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:label];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addRefreshControlToTableView];
}

- (void)addRefreshControlToTableView {
    PHFRefreshControl *refreshControl = [PHFRefreshControl new];
    [refreshControl setTintColor:[UIColor redColor]];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [[self tableView] setRefreshControl:refreshControl];
}

- (void)refresh {
    int64_t delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[[self tableView] refreshControl] endRefreshing];
    });
}

@synthesize tableView = _tableView;
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 460) style:UITableViewStylePlain];
        [_tableView setContentInset:UIEdgeInsetsMake(200, 0, 0, 0)];
        [_tableView setBackgroundColor:[UIColor whiteColor]];
    }

    return _tableView;
}

@end
