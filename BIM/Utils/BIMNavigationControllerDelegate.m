//
//  BIMNavigationControllerDelegate.m
//  BIM
//
//  Created by Alexis Jacquelin on 30/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMNavigationControllerDelegate.h"
#import "BIMAnimatorDetailsPush.h"
#import "BIMAnimatorDetailsPop.h"
#import "BIMViewController.h"

@interface BIMNavigationControllerDelegate() {
}

@property (weak, nonatomic) IBOutlet UINavigationController *navigationController;

@property (strong, nonatomic) BIMAnimatorDetailsPush *animatorDetailsPush;
@property (strong, nonatomic) BIMAnimatorDetailsPop *animatorDetailsPop;

@end

@implementation BIMNavigationControllerDelegate

#pragma mark -
#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(BIMViewController *)fromVC toViewController:(BIMViewController *)toVC {
    if (operation == UINavigationControllerOperationPop) {
        return [fromVC animatorPopForToVC:toVC];
    } else if (operation == UINavigationControllerOperationPush) {
        return [fromVC animatorPushForToVC:toVC];
    }
    return nil;
}

@end
