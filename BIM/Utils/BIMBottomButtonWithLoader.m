//
//  BIMBottomButtonWithLoader.m
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMBottomButtonWithLoader.h"
#import "BIMActivityView.h"

@interface BIMBottomButtonWithLoader() {
}

@property (nonatomic, strong) BIMActivityView *customActivityLoader;

@end

@implementation BIMBottomButtonWithLoader

#pragma mark -
#pragma mark - Lazy Loading

- (BIMActivityView *)customActivityLoader {
    if (_customActivityLoader == nil) {
        _customActivityLoader = [[BIMActivityView alloc] initWithImage:[UIImage imageNamed:@"white-loader"]];
        [self addSubview:self.customActivityLoader];
    }
    return _customActivityLoader;
}

- (BOOL)isLoading {
    return self.customActivityLoader.isAnimating;
}

- (void)startAnimationIndicationView {
    [self.customActivityLoader startAnimatingView];
}

- (void)stopAnimationIndicationView {
    [self.customActivityLoader stopAnimatingView];
}

- (void)startLoader {
    if ([self isLoading]) {
        return;
    }
    self.userInteractionEnabled = NO;
    [self startAnimationIndicationView];
}

- (void)stopLoader {
    if ([self isLoading] == NO) {
        return;
    }
    self.userInteractionEnabled = YES;
    [self stopAnimationIndicationView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.customActivityLoader.center = CGPointMake(roundf(self.width / 1.1), roundf(self.height / 2));
}

@end