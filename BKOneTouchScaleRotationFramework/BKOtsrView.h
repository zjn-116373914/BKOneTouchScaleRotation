#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface BKOtsrView : UIView
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
                 touchRadius:(CGFloat)touchRadius;
@end
NS_ASSUME_NONNULL_END
