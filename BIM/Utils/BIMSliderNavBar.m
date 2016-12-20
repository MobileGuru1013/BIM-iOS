//
//  BIMSlidingNavBar.m
//  BIM
//
//  Created by Alexis Jacquelin on 21/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMSliderNavBar.h"
#import "BIMMainContainerViewController.h"

static CGFloat const kMarginLeft = 30.f;
static CGFloat const kOffsetTranslationX = 50.f;

@implementation BIMSliderNavBar

#pragma mark -
#pragma mark - Lazy Loading

- (void)setArrayOfItems:(NSArray *)arrayOfItems {
    if (_arrayOfItems) {
        for (UIView *item in _arrayOfItems) {
            [item removeFromSuperview];
        }
    }
    for (UIView *item in arrayOfItems) {
        [self addSubview:item];
        
        item.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle:)];
        [item addGestureRecognizer:tapGesture];
    }
    _arrayOfItems = arrayOfItems;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    _contentOffset = contentOffset;
    
    CGFloat xOffset = contentOffset.x;
    CGFloat step = ((WIDTH_DEVICE / 2) - kMarginLeft);
    CGFloat speed = WIDTH_DEVICE / step;
    [self.arrayOfItems enumerateObjectsUsingBlock:^(UIView<BIMSliderItemProtocol> *itemView, NSUInteger index, BOOL *stop) {
        itemView.centerX = roundf(((index * step) - xOffset / speed) + (WIDTH_DEVICE / 2));

        CGFloat ratio;
        if(xOffset < WIDTH_DEVICE * index) {
            ratio = (xOffset - WIDTH_DEVICE * (index - 1)) / WIDTH_DEVICE;
        } else {
            ratio = 1 - ((xOffset - WIDTH_DEVICE * index) / WIDTH_DEVICE);
        }
        [itemView updateItemWithRatio:ratio];
    }];
}

#pragma mark -
#pragma mark - TapGesture

- (void)tapGestureHandle:(UITapGestureRecognizer *)tapGesture {
    NSInteger pageIndex = [self.arrayOfItems indexOfObject:tapGesture.view];

    [self.mainContainer setCurrentPage:pageIndex withAnimation:YES];
}

#pragma mark -
#pragma mark - Animations between controllers

- (void)hideCurrentItemsWithAnimationWithDuration:(CGFloat)duration {
    for (UIView *itemView in self.arrayOfItems) {
        POPSpringAnimation *translateAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        translateAnimation.toValue = [NSValue valueWithCGRect:CGRectOffset(itemView.frame, -kOffsetTranslationX, 0)];
        [itemView pop_addAnimation:translateAnimation forKey:@"translation"];

        POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation.duration = duration;
        alphaAnimation.toValue = @(0);
        [itemView pop_addAnimation:alphaAnimation forKey:@"alpha"];
    }
}

- (void)showCurrentItemsWithAnimationWithDuration:(CGFloat)duration {
    for (UIView *itemView in self.arrayOfItems) {
        POPSpringAnimation *translateAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        translateAnimation.toValue = [NSValue valueWithCGRect:CGRectOffset(itemView.frame, kOffsetTranslationX, 0)];
        [itemView pop_addAnimation:translateAnimation forKey:@"translation"];
        
        POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation.duration = duration;
        alphaAnimation.toValue = @(1);
        [itemView pop_addAnimation:alphaAnimation forKey:@"alpha"];
    }
}

@end
