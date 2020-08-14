#import "ViewController.h"
#import "BKOtsrView.h"
@interface ViewController ()
/// 单指控制缩放旋转控件的demo对象
@property (nonatomic, strong) BKOtsrView *mainTestView;
@end
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    CGSize size = CGSizeMake(200, 350);
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    self.mainTestView = [[BKOtsrView alloc] initWithSize:size center:center Image:[UIImage imageNamed:@"resources01"] touchIcon:[UIImage imageNamed:@"touchIcon"] touchRadius:10.0f];
    [self.view addSubview:self.mainTestView];
}
@end
