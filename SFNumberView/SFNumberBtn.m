//
//  SFNumberBtn.m
//  SFNumberView
//
//  Created by 王帅锋 on 2017/8/17.
//  Copyright © 2017年 WSF. All rights reserved.
//

#import "SFNumberBtn.h"

@interface SFNumberBtn ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *bgView;

@property (weak, nonatomic) CAShapeLayer *shapeLayer;

@end

@implementation SFNumberBtn

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUpViews];
    }
    return self;
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    //大圆随着手指移动
    CGPoint offSetPonit = [pan translationInView:self];
    CGPoint center = self.center;
    center.x += offSetPonit.x;
    center.y += offSetPonit.y;
    self.center = center;
    [pan setTranslation:CGPointZero inView:self];
    //获取两个圆心的距离
    CGFloat centerDistance = [self distanceWithBgView:self.bgView topView:self];
    
    //计算小圆的半径
    CGFloat smallRadius = self.bounds.size.width/2 - centerDistance/10;
    
    self.bgView.bounds = CGRectMake(0, 0, smallRadius*2, smallRadius*2);
    self.bgView.layer.cornerRadius = smallRadius;
    
    if (centerDistance > 100) {
        self.bgView.hidden = YES;
        [self.shapeLayer removeFromSuperlayer];
    }
    
    if (self.bgView.hidden == NO) {
        // 设置path
        self.shapeLayer.path = [self pathWithBgView:self.bgView topView:self].CGPath;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (centerDistance > 100) {
            [self disappearAnimation];
        }else {
            // 复位
            [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.center = self.bgView.center ;
            } completion:^(BOOL finished) {
                
            }];
            self.bgView.hidden = NO;
            [self.shapeLayer removeFromSuperlayer];
        }
    }
}
// 消失动画
- (void)disappearAnimation {
    self.bgView.hidden = YES;
    UIImageView * imageV = [[UIImageView alloc] initWithFrame:self.bounds];
    NSArray *arr;
    NSMutableArray *mutArrs = [NSMutableArray array];
    if (_images == nil) {
        for (int i=1 ; i<=5; i++) {
            NSString * imageName = [NSString stringWithFormat:@"unreadBomb_%d",i];
            UIImage * image = [UIImage imageNamed:imageName];
            [mutArrs addObject:image];
        }
        arr = mutArrs;
    }else{
        arr = _images;
    }
    imageV.animationImages =  arr ;
    imageV.animationDuration = 1.0 ;
    [imageV startAnimating];
    [self addSubview:imageV];
    self.backgroundColor = [UIColor whiteColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
        [self.bgView removeFromSuperview];
    });
}

- (UIBezierPath *)pathWithBgView:(UIView *)bgView topView:(UIView *)topView {
    CGFloat x1 = bgView.center.x;
    CGFloat y1 = bgView.center.y;
    CGFloat r1 = bgView.bounds.size.width/2;
    
    CGFloat x2 = topView.center.x;
    CGFloat y2 = topView.center.y;
    CGFloat r2 = topView.bounds.size.width/2;
    
    CGFloat distance = [self distanceWithBgView:bgView topView:topView];
    
    if (distance <= 0) {
        return nil;
    }
    
    CGFloat cosθ = (y2 - y1) / distance;
    CGFloat sinθ = (x2 - x1) / distance;
    
    CGPoint pointA = CGPointMake(x1 - cosθ * r1, y1 + sinθ * r1);
    CGPoint pointB = CGPointMake(x1 + cosθ * r1, y1 - sinθ * r1);
    CGPoint pointC = CGPointMake(x2 + cosθ * r2, y2 - sinθ * r2);
    CGPoint pointD = CGPointMake(x2 - cosθ * r2, y2 + sinθ * r2);
    CGPoint pointO = CGPointMake(pointA.x + distance * 0.5 * sinθ, pointA.y + distance * 0.5 * cosθ);
    CGPoint pointP = CGPointMake(pointB.x + distance * 0.5 * sinθ, pointB.y + distance * 0.5 * cosθ);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    // A B
    [path addLineToPoint:pointB];
    // B C
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    // C D
    [path addLineToPoint:pointD];
    // D A
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
    
}

// 计算两个圆心的距离
- (CGFloat)distanceWithBgView:(UIView *)bgView topView:(UIView *)topView {
    CGFloat offsetx = topView.center.x - bgView.center.x;
    CGFloat offsety = topView.center.y - bgView.center.y;
    return sqrtf(pow(offsetx, 2) + pow(offsety, 2));
}

- (void)setUpViews {
    
    self.layer.cornerRadius = self.frame.size.width/2;
    self.clipsToBounds = YES;
    [self setBackgroundColor:[UIColor redColor]];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)tap {
    [self disappearAnimation];
}

- (void)didMoveToSuperview {
    [self.superview insertSubview:self.bgView belowSubview:self];
}

- (void)setNumber:(NSInteger)number {
    _number = number;
    [self setTitle:[NSString stringWithFormat:@"%ld",number] forState:UIControlStateNormal];
}

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        CAShapeLayer * shapeLayer = [CAShapeLayer layer];
        shapeLayer.fillColor = [UIColor redColor].CGColor;
        [self.superview.layer insertSublayer:shapeLayer atIndex:0];
        _shapeLayer = shapeLayer;
    }
    return _shapeLayer ;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        _bgView.backgroundColor = self.backgroundColor;
        _bgView.layer.cornerRadius = self.layer.cornerRadius;
        _bgView.clipsToBounds = YES;
    }
    return _bgView;
}

@end
