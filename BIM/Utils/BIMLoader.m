//
//  BIMLoader.m
//  BIM
//
//  Created by Alexis Jacquelin on 23/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMLoader.h"

static CGFloat const kLoaderTimerFade = .3f;
static CGFloat const kLoaderImages = 11;

@interface BIMLoader() {
}

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) NSArray *arrayOfImages;
@property (nonatomic, strong) UIImageView *animatedIV;
@property (nonatomic, strong) RACDisposable *updateEventSignal;

@property (nonatomic, assign) NSUInteger currenIndex;

@end

@implementation BIMLoader

#pragma mark -
#pragma mark - Lazy Loading

- (NSArray *)arrayOfImages {
    if (_arrayOfImages == nil) {

        NSMutableArray *tmp = [NSMutableArray new];
        int i = 1;
        while (i <= kLoaderImages) {
            NSString *nameImg = [NSString stringWithFormat:@"gif-icon-%d", i];
            UIImage *img = [UIImage imageNamed:nameImg];
            [tmp addObject:img];
            i++;
        }
        _arrayOfImages = tmp.copy;
    }
    return _arrayOfImages;
}

- (POPBasicAnimation *)getBasicAlphaAnimationOnView:(UIView *)view {
    POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    alphaAnim.duration = kLoaderTimerFade;
    [view pop_addAnimation:alphaAnim forKey:@"fade"];
    
    return alphaAnim;
}

#pragma mark -
#pragma mark - View Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.animating = NO;
        self.hidden = YES;

        UIImageView *overlayIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gif-overlay"]];
        [overlayIV setContentMode:UIViewContentModeScaleAspectFit];
        [overlayIV sizeToFit];
        [self setFrame:overlayIV.bounds];
        [self addSubview:overlayIV];
        
        self.animatedIV = [[UIImageView alloc] initWithFrame:self.bounds];
        self.animatedIV.contentMode = UIViewContentModeCenter;
        [self insertSubview:self.animatedIV belowSubview:overlayIV];
    }
    return self;
}

- (BOOL)isAnimating {
    return self.animating;
}

- (void)startAnimating {
    if (self.animating) {
        return;
    }
    self.animating = YES;
    self.currenIndex = 0;
    self.hidden = NO;
    self.animatedIV.image = self.arrayOfImages[self.currenIndex];
    self.animatedIV.alpha = 1;
    
    POPBasicAnimation *alphaAnim = [self getBasicAlphaAnimationOnView:self];
    alphaAnim.fromValue = @(0.0);
    alphaAnim.toValue = @(1.0);
    [alphaAnim setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        [self displayNextImage];
    }];
}

- (void)stopAnimating {
    if (self.animating == NO) {
        return;
    }
    self.animating = NO;
    POPBasicAnimation *alphaAnim = [self getBasicAlphaAnimationOnView:self];
    alphaAnim.toValue = @(0.0);
    [alphaAnim setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)displayNextImage {
    if (self.animating == NO) {
        return;
    }
    self.currenIndex = (self.currenIndex + 1) % self.arrayOfImages.count;
    
    UIImage *image = self.arrayOfImages[self.currenIndex];
    POPBasicAnimation *alphaAnim = [self getBasicAlphaAnimationOnView:self.animatedIV];
    alphaAnim.toValue = @(0.0);
    [alphaAnim setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        self.animatedIV.image = image;
        POPBasicAnimation *alphaAnim = [self getBasicAlphaAnimationOnView:self.animatedIV];
        alphaAnim.toValue = @(1.0);
        [alphaAnim setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
            [self displayNextImage];
        }];
    }];
}

@end
