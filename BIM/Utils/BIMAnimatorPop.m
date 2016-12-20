//
//  BIMAnimatorPop.m
//  BIM
//
//  Created by Alexis Jacquelin on 30/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAnimatorPop.h"
#import "BIMSliderNavBar.h"
#import "BIMViewController.h"
#import "BIMMainContainerViewController.h"

static CGFloat const kOffsetTranslationX = 80.f;

@implementation BIMAnimatorPop

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return .3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    BIMViewController *fromViewController = (BIMViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    BIMMainContainerViewController *toViewController = (BIMMainContainerViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    [containerView addSubview:toViewController.view];
    [containerView addSubview:fromViewController.view];
    
    //Get the blur
    BIMTintedImageView *tintedTopIV = nil;
    if ([toViewController isKindOfClass:[BIMMainContainerViewController class]]) {
        BIMSliderNavBar *navBar = (BIMSliderNavBar *)[fromViewController.navigationController navigationBar];
        [navBar showCurrentItemsWithAnimationWithDuration:.2];
        tintedTopIV = fromViewController.tintedTopIV;
        if (tintedTopIV) {
            if ([[toViewController currentViewController].tintedTopIV.urlString isEqualToString:tintedTopIV.urlString]) {
                [toViewController currentViewController].tintedTopIV = tintedTopIV;
            } else {
                [containerView addSubview:[toViewController currentViewController].tintedTopIV];
            }
            [containerView addSubview:tintedTopIV];
        }
    } else {
        [toViewController showCurrentItemsWithAnimationWithDuration:[self transitionDuration:transitionContext] direction:BIMDirectionModeLeft];
    }
    [fromViewController hideCurrentItemsWithAnimationWithDuration:[self transitionDuration:transitionContext] direction:BIMDirectionModeRight];

    toViewController.view.left = -kOffsetTranslationX;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fromViewController.view.left = containerView.width;
        toViewController.view.left = 0;
        
        if (tintedTopIV &&
            ![[toViewController currentViewController].tintedTopIV.urlString isEqualToString:tintedTopIV.urlString]) {
            [toViewController currentViewController].tintedTopIV.alpha = 0;
            tintedTopIV.alpha = 0;
            [toViewController currentViewController].tintedTopIV.alpha = 1;
        }
    } completion:^(BOOL finished) {
        if ([tintedTopIV superview] == containerView) {
            [tintedTopIV removeFromSuperview];
        }
        if (tintedTopIV &&
            [[toViewController currentViewController].tintedTopIV superview] != [toViewController currentViewController].view) {
            [[toViewController currentViewController].view addSubview:[toViewController currentViewController].tintedTopIV];
        }
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [fromViewController.view removeFromSuperview];
    }];
    
    if ([toViewController respondsToSelector:@selector(displayTitle)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toViewController performSelector:@selector(displayTitle)];
        });;
    }
}

@end
