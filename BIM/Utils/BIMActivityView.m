//
//  BIMActivityView.m
//  BIM
//
//  Created by Alexis Jacquelin on 24/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMActivityView.h"

static NSString * const kTransformZ = @"transform.rotation.z";
static NSString * const kRotationKey = @"rotationAnimation";

@interface BIMActivityView() {
    BOOL _animating;
}

@end

@implementation BIMActivityView

- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        _animating = NO;
        self.hidden = YES;
    }
    return self;
}

- (BOOL)isAnimating {
    return _animating;
}

- (void)startAnimatingView {
    _animating = YES;

    self.hidden = NO;
    self.alpha = 0;
    [UIView animateWithDuration:.2 animations:^{
        self.alpha = 1;
    }];
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:kTransformZ];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI];
    rotationAnimation.duration = .5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    [self.layer addAnimation:rotationAnimation forKey:kRotationKey];
}

- (void)stopAnimatingViewAndRestoreTransformWithCompletionBlock:(void (^)(void))completionBlock {
    CALayer *currentLayer = (CALayer *)[self.layer presentationLayer];
    float currentAngle = [(NSNumber *)[currentLayer valueForKeyPath:kTransformZ] floatValue];
    
    [self.layer removeAnimationForKey:kRotationKey];
    CABasicAnimation *restoreAnimation;
    restoreAnimation = [CABasicAnimation animationWithKeyPath:kTransformZ];
    restoreAnimation.fromValue = @(currentAngle);
    restoreAnimation.toValue = @(0);
    restoreAnimation.duration = .1;
    [self.layer addAnimation:restoreAnimation forKey:kRotationKey];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_animating = NO;
        self.hidden = YES;
        [self.layer removeAllAnimations];
        if (completionBlock) {
            completionBlock();
        }
    });
}

- (void)stopAnimatingView {
    _animating = NO;
    [UIView animateWithDuration:.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [self.layer removeAllAnimations];
    }];
}

- (void) hideAfterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(stopAnimating) withObject:nil afterDelay:delay];
}

@end
