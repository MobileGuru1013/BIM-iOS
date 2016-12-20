//
//  AppDelegate+AddOn.m
//  Bim
//
//  Created by Alexis Jacquelin on 20/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "AppDelegate+AddOn.h"

@implementation BIMAppDelegate (AddOn)

- (void)changeRootViewController:(UIViewController*)viewController {
    if (!self.window.rootViewController) {
        self.window.rootViewController = viewController;
        return;
    }
    UIView *snapShot = [self.window snapshotViewAfterScreenUpdates:YES];
    [viewController.view addSubview:snapShot];
    self.window.rootViewController = viewController;
    [UIView animateWithDuration:0.3 animations:^{
        snapShot.layer.opacity = 0;
        snapShot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
    } completion:^(BOOL finished) {
        [snapShot removeFromSuperview];
    }];
}

@end
