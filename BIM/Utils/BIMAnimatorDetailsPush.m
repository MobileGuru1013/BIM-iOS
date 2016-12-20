//
//  BIMAnimatorDetailsPush.m
//  BIM
//
//  Created by Alexis Jacquelin on 05/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAnimatorDetailsPush.h"
#import "BIMHomeViewController.h"
#import "BIMDetailsPlaceViewController.h"
#import "BIMInfluencerScrollView.h"
#import "BIMChoosePlaceView.h"
#import "BIMPlaceInformations.h"

@implementation BIMAnimatorDetailsPush

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return .4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    BIMMainContainerViewController *fromViewController = (BIMMainContainerViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    BIMHomeViewController *homeVC = (BIMHomeViewController *)[fromViewController currentViewController];
    BIMDetailsPlaceViewController *toViewController = (BIMDetailsPlaceViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (![homeVC isKindOfClass:[BIMHomeViewController class]] ||
        ![toViewController isKindOfClass:[BIMDetailsPlaceViewController class]]) {
        SKYLog(@"UNKNOWN VCs CLASS %@ to %@", homeVC, toViewController);
    }
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toViewController.view];
    [containerView addSubview:fromViewController.view];
    
    [fromViewController vcIsPushingWithDuration:[self transitionDuration:transitionContext] withCompletionBlock:nil];
    [toViewController vcIsPushedWithDuration:[self transitionDuration:transitionContext] withCompletionBlock:nil onContainerView:containerView];
    [homeVC vcIsPushingWithDuration:[self transitionDuration:transitionContext] withCompletionBlock:^{
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
        toViewController.influencerScrollView = homeVC.influencerScrollView;
        toViewController.informationPlace = homeVC.informationPlace;
        [toViewController setCurrentImageString:[homeVC getCurrentImageString]];
        [fromViewController.view removeFromSuperview];
    }];
}

@end
