//
//  BIMSplashAnimatedView.m
//  BIM
//
//  Created by Alexis Jacquelin on 24/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMSplashAnimatedView.h"

@interface BIMSplashAnimatedView() {
}

@property (nonatomic, strong) UIImageView *splashBgIV;
@property (nonatomic, strong) UIImageView *logoSplashScreenIV;
@property (nonatomic, strong) UIImageView *baselineIV;
@property (nonatomic, strong) UIView *blueCircle;

@end

@implementation BIMSplashAnimatedView

#pragma mark -
#pragma mark - Look & Feel

- (UIImageView *)splashBgIV {
    if (_splashBgIV == nil) {
        NSString *imageName = ([SDiPhoneVersion deviceSize] == iPhone47inch) ? @"splashscreen-iPhone6" : @"splashscreen";
        UIImage *image = [UIImage imageNamed:imageName];
        _splashBgIV = [[UIImageView alloc] initWithImage:image];
        [_splashBgIV sizeToFit];
    }
    return _splashBgIV;
}

- (UIView *)blueCircle {
    if (_blueCircle == nil) {
        _blueCircle = [UIView new];
        _blueCircle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue-color"]];
        _blueCircle.frame = CGRectMake(0, 0, 100, 100);
        _blueCircle.center =  CGPointMake(self.centerX, self.centerY);
        _blueCircle.layer.cornerRadius = round(_blueCircle.width / 2);
        [_blueCircle.layer setMasksToBounds:YES];
    }
    return _blueCircle;
}

- (UIImageView *)logoSplashScreenIV {
    if (_logoSplashScreenIV == nil) {
        NSString *nameLogoImageName = @"white-logo";
        CGFloat offsetY = 18.5;
        if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
            nameLogoImageName = @"white-logo-iPhone6";
            offsetY = 21.5;
        } else if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
            offsetY = 23.5;
        }
        _logoSplashScreenIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:nameLogoImageName]];
        _logoSplashScreenIV.center = CGPointMake(self.centerX + 2, self.centerY - offsetY);
    }
    return _logoSplashScreenIV;
}

- (UIImageView *)baselineIV {
    if (_baselineIV == nil) {
        NSString *baseLineImageName = @"baseline";
        CGFloat offsetX = .5;
        CGFloat offsetY = 42.5;
        if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
            baseLineImageName = @"baseline-iPhone6";
        } else if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
            offsetX = 1;
            offsetY = 55;
        }
        _baselineIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:baseLineImageName]];
        _baselineIV.center = CGPointMake(self.centerX + offsetX, self.centerY + offsetY);
    }
    return _baselineIV;
}

#pragma mark -
#pragma mark - View Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.splashBgIV];
        [self addSubview:self.blueCircle];
        [self addSubview:self.logoSplashScreenIV];
        [self addSubview:self.baselineIV];
    }
    return self;
}

- (void)startAnimationWithAnimations:(block_splash_animation)animationBlock andCompletionBlock:(block_splash_animation)completionBlock {
    if (animationBlock) {
        animationBlock();
    }
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    CGFloat multiplier = 7;
    if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
        multiplier = 8;
    } else if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        multiplier = 9;
    }
    scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(multiplier, multiplier)];
    scaleAnimation.springSpeed = 4;
    [self.blueCircle.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
    
    POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnim.toValue = @(0);
    [self.baselineIV pop_addAnimation:alphaAnim forKey:@"alpha"];
    
    alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    
    if ([SDiPhoneVersion deviceSize] != iPhone35inch) {
        alphaAnim.beginTime = CACurrentMediaTime() + .4;
    }
    alphaAnim.toValue = @(0);
    [alphaAnim setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
    [self pop_addAnimation:alphaAnim forKey:@"alpha"];
    
    POPSpringAnimation *translateAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    translateAnimation.beginTime = CACurrentMediaTime() + .1;
    
    CGFloat offsetY = 190;
    CGFloat offsetX = 2;
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone55inch:
            offsetY = 256;
            break;
        case iPhone47inch:
            offsetY = 236;
            break;
        default:
            break;
    }
    translateAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.logoSplashScreenIV.centerX - offsetX, self.logoSplashScreenIV.centerY - offsetY)];
    [self.logoSplashScreenIV pop_addAnimation:translateAnimation forKey:@"translate"];

    if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
        scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(.84, .84)];
        [self.logoSplashScreenIV.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
    }
}

@end
