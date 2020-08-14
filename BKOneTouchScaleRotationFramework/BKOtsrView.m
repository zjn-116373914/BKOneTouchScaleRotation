#import "BKOtsrView.h"
#import "UIView+Layout.h"
@interface BKOtsrView () {
    /// 标记 [开始][拖动手势]时 控制触点的初始位置
    CGPoint _initPoint;
    /// 标记 [开始][拖动手势]时 主视图中心点的位置
    CGPoint _centerPoint;
    /// 标记 [开始][拖动手势]时 主视图的旋转角度
    CGFloat _previousAngle;
    /// 标记 [开始][拖动手势]时 控制触点与中心点的距离(用于控件缩放比例)
    CGFloat _previousDistance;
    /// 标记 [开始][拖动手势]时 主视图的仿射变换矩阵
    CGAffineTransform _preMainTransform;
    /// 标记 [开始][拖动手势]时 图像控件的仿射变换矩阵
    CGAffineTransform _preImgTransform;
}
/// 核心图像视图
@property (nonatomic, strong) UIImageView *mainImgView;
/// 单指控制的触点控件
@property (nonatomic, strong) UIImageView *oneTouchPointView;
@end
@implementation BKOtsrView
/// 初始化实例方法
/// @param size 宽高尺寸
/// @param center 中心位置
/// @param image 核心视图的图像
/// @param touchIcon 单指控件触点的icon图标
/// @param touchRadius 单指控制触点的半径
- (instancetype)initWithSize:(CGSize)size
                      center:(CGPoint)center
                       Image:(UIImage*)image
                   touchIcon:(UIImage*)touchIcon
                 touchRadius:(CGFloat)touchRadius{
    self = [super init];
    if (self) {
        self.size = size;
        self.center = center;
        [self initUserInterfaceWithImage:image touchIcon:touchIcon touchRadius:touchRadius];
    }
    return self;
}
- (void)initUserInterfaceWithImage:(UIImage*)image touchIcon:(UIImage*)touchIcon touchRadius:(CGFloat)touchRadius{
    /*====== 加载[核心图像视图] start ======*/
    self.mainImgView = [[UIImageView alloc] initWithImage:image];
    self.mainImgView.size = CGSizeMake(self.width - 2*touchRadius, self.height - 2*touchRadius);
    self.mainImgView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    //空图像容错处理
    if (image == nil) {
        self.mainImgView.backgroundColor = [UIColor lightGrayColor];
    }
    [self addSubview:self.mainImgView];
    /*====== 加载[核心图像视图] end ======*/
    /*====== 加载[单指控制触点控件] start ======*/
    self.oneTouchPointView = [[UIImageView alloc] initWithImage:touchIcon];
    self.oneTouchPointView.size = CGSizeMake(2*touchRadius, 2*touchRadius);
    self.oneTouchPointView.center = CGPointMake(self.width - touchRadius, self.height - touchRadius);
    self.oneTouchPointView.layer.cornerRadius = touchRadius;
    self.oneTouchPointView.layer.masksToBounds = YES;
    //当主视图frame改变时,其单指控制触点控件位置也相应改变(与 左边界 上边界 的 相对位置保持不变)
    self.oneTouchPointView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    //空图像容错处理
    if (touchIcon == nil) {
        self.oneTouchPointView.backgroundColor = [UIColor blueColor];
    }
    [self addSubview:self.oneTouchPointView];
    /*====== 加载[单指控制触点控件] end ======*/
    //单指控制[拖动手势]的创建与控件关联
    self.oneTouchPointView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panOfOneTouchPointView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOfOneTouchPointViewGestureAction:)];
    [self.oneTouchPointView addGestureRecognizer:panOfOneTouchPointView];
    
    UIPanGestureRecognizer *panOfSelfView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOfSelfViewGestureAction:)];
    [self addGestureRecognizer:panOfSelfView];
}

/// [开始]点击控制触点时的响应事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [[touches allObjects] firstObject];
    if([touch.view isKindOfClass:[UIImageView class]]){
        //点击控制触点开始时 触点控件透明度设置为0.25(自定义高亮特效)
        self.oneTouchPointView.alpha = 0.25f;
    }
}

/// [结束]点击控制触点时的响应事件
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [[touches allObjects] firstObject];
    if([touch.view isKindOfClass:[UIImageView class]]){
        //点击控制触点开始时 触点控件透明度设置为0.25(自定义高亮特效)
        self.oneTouchPointView.alpha = 1.0f;
    }
}

/// 单指控制[拖动手势]的响应手势
-(void)panOfOneTouchPointViewGestureAction:(UIPanGestureRecognizer *)sender{
    CGPoint pp = [sender translationInView:self.superview];
    if (sender.state == UIGestureRecognizerStateBegan) {
        /*====== 手势操作[开始]时调用  start ======*/
        _initPoint = [self.superview convertPoint:sender.view.center fromView:sender.view.superview];
        _centerPoint = self.center;
        _preMainTransform = self.transform;
        //开始手势时 当前控件触点 指向 主视图中心点 矢量(可用于标记 开始手势时 缩放比例与旋转角度)
        CGPoint preDp = CGPointMake(_initPoint.x - _centerPoint.x,
                                    _initPoint.y - _centerPoint.y);
        _previousAngle = atan2(preDp.y, preDp.x);
        _previousDistance = sqrt(preDp.x*preDp.x + preDp.y*preDp.y);
        _preImgTransform = self.mainImgView.transform;
        /*====== 手势操作[开始]时调用  end ======*/
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        //手势结束后 触点控件的透明度恢复到1.0(自定义高亮特效)
        sender.view.alpha = 1.0;
    }
    //当前控件触点 指向 主视图中心点 矢量(可用于计算缩放比例与旋转角度)
    CGPoint dp = CGPointMake(pp.x + _initPoint.x - _centerPoint.x,
                             pp.y + _initPoint.y - _centerPoint.y);
    /*====== 进行[缩放]操作 start ======*/
    CGFloat distance = sqrt(dp.x*dp.x + dp.y*dp.y);
    CGFloat scale = distance/_previousDistance;
    //改变主视图的frame前,需要将仿射变换矩阵复原
    self.transform = CGAffineTransformIdentity;
    self.mainImgView.transform = CGAffineTransformScale(_preImgTransform, scale, scale);
    CGRect myRect = CGRectZero;
    CGRect imgRect= [self convertRect:self.mainImgView.frame toView:self.superview];
    myRect.origin.x = imgRect.origin.x - self.oneTouchPointView.width/2;
    myRect.origin.y = imgRect.origin.y - self.oneTouchPointView.height/2;
    myRect.size.width = imgRect.size.width + self.oneTouchPointView.width;
    myRect.size.height = imgRect.size.height + self.oneTouchPointView.height;
    self.frame = myRect;
    //主视图frame改变后,需要将图像控件重新居中,不然会出现位置紊乱
    self.mainImgView.center = CGPointMake(myRect.size.width/2, myRect.size.height/2);
    /*====== 进行[缩放]操作 end ======*/
    
    /*====== 进行[旋转]操作 start ======*/
    CGFloat angle = atan2(dp.y, dp.x);
    CGFloat Δangle = angle - _previousAngle;
    self.transform = CGAffineTransformRotate(_preMainTransform, Δangle);
    /*====== 进行[旋转]操作 end ======*/
}

/// 主视图[拖动手势]的响应方法(实现主视图平移功能)
-(void)panOfSelfViewGestureAction:(UIPanGestureRecognizer *)sender{
    CGPoint pp = [sender translationInView:sender.view.superview];
    if (sender.view.center.x+pp.x >= 0 &&
        sender.view.center.x+pp.x <= sender.view.superview.width &&
        sender.view.center.y+pp.y >= 0 &&
        sender.view.center.y+pp.y <= sender.view.superview.height
        ) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            //手势操作[开始]时调用
            _centerPoint = sender.view.center;
        }
        CGPoint center = CGPointMake(_centerPoint.x + pp.x,  _centerPoint.y + pp.y);
        sender.view.center = center;
    }
}
@end
