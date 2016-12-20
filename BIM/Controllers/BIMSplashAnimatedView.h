//
//  BIMSplashAnimatedView.h
//  BIM
//
//  Created by Alexis Jacquelin on 24/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^block_splash_animation)(void);

@interface BIMSplashAnimatedView : UIView

- (void)startAnimationWithAnimations:(block_splash_animation)animationBlock andCompletionBlock:(block_splash_animation)completionBlock;

@end
