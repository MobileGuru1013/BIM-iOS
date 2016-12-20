//
//  BIMAnimatorDetailsPop.m
//  BIM
//
//  Created by Alexis Jacquelin on 05/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAnimatorDetailsPop.h"
#import "BIMMainContainerViewController.h"
#import "BIMDetailsPlaceViewController.h"
#import "BIMHomeViewController.h"

@implementation BIMAnimatorDetailsPop

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return .4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    BIMDetailsPlaceViewController *fromViewController = (BIMDetailsPlaceViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    BIMMainContainerViewController *toViewController = (BIMMainContainerViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    BIMHomeViewController *homeVC = (BIMHomeViewController *)[toViewController currentViewController];
    
    if (![homeVC isKindOfClass:[BIMHomeViewController class]] ||
        ![fromViewController isKindOfClass:[BIMDetailsPlaceViewController class]]) {
        SKYLog(@"UNKNOWN VCs CLASS %@ to %@", homeVC, fromViewController);
    }
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toViewController.view];
    [containerView addSubview:fromViewController.view];
    
    [fromViewController vcIsPoppingWithDuration:[self transitionDuration:transitionContext] withCompletionBlock:nil];
    [toViewController vcIsPoppedWithDuration:[self transitionDuration:transitionContext] withCompletionBlock:nil];
    [homeVC vcIsPoppedWithDuration:[self transitionDuration:transitionContext] withCompletionBlock:^{
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
        homeVC.influencerScrollView = fromViewController.influencerScrollView;
        homeVC.informationPlace = fromViewController.informationPlace;
        [homeVC setCurrentImageString:[fromViewController getCurrentImageString]];
        [fromViewController.view removeFromSuperview];
    } onContainerView:containerView];
}

@end
