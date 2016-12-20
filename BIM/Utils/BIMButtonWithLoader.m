//
//  BIMButtonWithLoader.m
//  BIM
//
//  Created by Alexis Jacquelin on 24/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMButtonWithLoader.h"
#import "BIMActivityView.h"

@interface BIMButtonWithLoader() {
    NSString *_titlebuttonLoader;
    UIImage *_imageStateNormal;
    UIImage *_imageStateSelected;
}

@property (nonatomic, strong) UIActivityIndicatorView *activityLoader;
@property (nonatomic, strong) BIMActivityView *customActivityLoader;

@end

@implementation BIMButtonWithLoader

#pragma mark -
#pragma mark - Lazy Loading

- (UIActivityIndicatorView *)activityLoader {
    if (_activityLoader == nil) {
        _activityLoader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activityLoader setHidesWhenStopped:YES];
        [self addSubview:_activityLoader];
        
        [self.customActivityLoader removeFromSuperview];
        self.customActivityLoader = nil;
    }
    return _activityLoader;
}

- (void)setImageLoader:(NSString *)imageLoader {
    _imageLoader = imageLoader;
    if (_imageLoader) {
        self.customActivityLoader = [[BIMActivityView alloc] initWithImage:[UIImage imageNamed:_imageLoader]];
        [self addSubview:self.customActivityLoader];
    } else {
        [self.customActivityLoader removeFromSuperview];
        self.customActivityLoader = nil;
    }
}

- (UIActivityIndicatorView *)indicatorView {
    if (self.customActivityLoader) {
        return (id)self.customActivityLoader;
    } else {
        return self.activityLoader;
    }
}

- (BOOL)isLoading {
    return self.indicatorView.isAnimating;
}

- (void)startAnimationIndicationView {
    if (self.customActivityLoader) {
        [NOTIFICATION_CENTER addObserver:self selector:@selector(addAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
        [self.customActivityLoader startAnimatingView];
    } else {
        [self.activityLoader startAnimating];
    }
}

- (void)stopAnimationIndicationViewWithCompletionBlock:(void (^)(void))completionBlock {
    [self.customActivityLoader stopAnimatingViewAndRestoreTransformWithCompletionBlock:completionBlock];
}

- (void)stopAnimationIndicationView {
    if (self.customActivityLoader) {
        [self.customActivityLoader stopAnimatingView];
    } else {
        [self.activityLoader stopAnimating];
    }
}

- (void)addAnimation {
    [self startAnimationIndicationView];
}

- (void)startLoader {
    if ([self isLoading]) {
        return;
    }
    _titlebuttonLoader = [self titleForState:UIControlStateNormal];
    _imageStateNormal = [self imageForState:UIControlStateNormal];
    _imageStateSelected = [self imageForState:UIControlStateSelected];

    [self setSKYTitle:nil];
    [self setImage:nil forState:UIControlStateNormal];
    [self setImage:nil forState:UIControlStateSelected];

    self.userInteractionEnabled = NO;
    
    [self startAnimationIndicationView];
}

- (void)stopLoader {
    [NOTIFICATION_CENTER removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    if ([self isLoading] == NO) {
        return;
    }
    
    if (self.needToRestoreAfterRotation) {
        [self stopAnimationIndicationViewWithCompletionBlock:^{
            [self setSKYTitle:self->_titlebuttonLoader];
            [self setImage:self->_imageStateNormal forState:UIControlStateNormal];
            [self setImage:self->_imageStateSelected forState:UIControlStateSelected];
            self->_titlebuttonLoader = nil;
            self.userInteractionEnabled = YES;
            
            [self stopAnimationIndicationView];
        }];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setSKYTitle:self->_titlebuttonLoader];
            [self setImage:self->_imageStateNormal forState:UIControlStateNormal];
            [self setImage:self->_imageStateSelected forState:UIControlStateSelected];
            self->_titlebuttonLoader = nil;
            self.userInteractionEnabled = YES;
        });
        [self stopAnimationIndicationView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.indicatorView.center = CGPointMake(roundf(self.width / 2), roundf(self.height / 2));
}

@end
