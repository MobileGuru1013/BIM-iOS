//
//  BIMAnimatorPush.m
//  BIM
//
//  Created by Alexis Jacquelin on 30/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAnimatorPush.h"
#import "BIMSliderNavBar.h"
#import "BIMViewController.h"
#import "BIMMainContainerViewController.h"

static CGFloat const kOffsetTranslationX = 80.f;

@implementation BIMAnimatorPush

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return .3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    BIMMainContainerViewController *fromViewController = (BIMMainContainerViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    BIMViewController *toViewController = (BIMViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *containerView = [transitionContext containerView];

    [containerView addSubview:fromViewController.view];
    [containerView addSubview:toViewController.view];
    
    //Get the blur if containers
    BIMTintedImageView *tintedTopIV = nil;
    if ([fromViewController isKindOfClass:[BIMMainContainerViewController class]]) {
        BIMSliderNavBar *navBar = (BIMSliderNavBar *)[fromViewController.navigationController navigationBar];
        [navBar hideCurrentItemsWithAnimationWithDuration:[self transitionDuration:transitionContext]];

        tintedTopIV = [fromViewController currentViewController].tintedTopIV;
        if (tintedTopIV) {
            toViewController.tintedTopIV = tintedTopIV;
            [containerView addSubview:tintedTopIV];
        }
    } else {
        [fromViewController hideCurrentItemsWithAnimationWithDuration:[self transitionDuration:transitionContext] direction:BIMDirectionModeLeft];
    }
    [toViewController showCurrentItemsWithAnimationWithDuration:[self transitionDuration:transitionContext] direction:BIMDirectionModeRight];
    
    toViewController.view.left = containerView.width;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fromViewController.view.left = -kOffsetTranslationX;
        toViewController.view.left = 0;
    } completion:^(BOOL finished) {
        if ([toViewController respondsToSelector:@selector(user)]) {
            BIMUser *user = [toViewController performSelector:@selector(user)];

            CGSize size = tintedTopIV.size;
            NSURL *navBarURL = [user avatarURLWithSize:size];
            if (navBarURL && ![tintedTopIV.urlString isEqualToString:navBarURL.absoluteString]) {
                [toViewController displayUserImageWithURL:navBarURL withSize:size withSearchBar:nil];
            } else {
                [toViewController.view addSubview:tintedTopIV];
            }
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
