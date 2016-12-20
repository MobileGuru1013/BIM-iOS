//
//  BIMAnimatorPlacesPush.m
//  Bim
//
//  Created by Alexis Jacquelin on 18/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAnimatorPlacesPush.h"
#import "BIMPlacesViewController.h"
#import "BIMDetailsPlaceViewController.h"

@implementation BIMAnimatorPlacesPush

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return .4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    BIMPlacesViewController *fromViewController = (BIMPlacesViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    BIMDetailsPlaceViewController *toViewController = (BIMDetailsPlaceViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [fromViewController hideCurrentItemsWithAnimationWithDuration:[self transitionDuration:transitionContext] direction:BIMDirectionModeLeft];
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:fromViewController.view];
    [containerView addSubview:toViewController.view];
}

@end
