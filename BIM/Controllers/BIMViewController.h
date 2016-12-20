//
//  BIMViewController.h
//  Bim
//
//  Created by Alexis Jacquelin on 02/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKYViewController.h"
#import "BIMLoader.h"
#import "BIMTintedImageView.h"

extern CGFloat const kItemTranslationX;

typedef NS_ENUM(NSUInteger, BIMDirectionMode) {
    BIMDirectionModeLeft,
    BIMDirectionModeRight
};


@interface BIMViewController : SKYViewController

@property (nonatomic, strong) BIMLoader *loader;
@property (nonatomic, strong) BIMTintedImageView *tintedTopIV;

- (void)addLeftBackBtnItem;

- (void)addLoaderOnView:(UIView *)view;

- (void)addCloseBtnOnNavigationItem:(UINavigationItem *)navigationItem;
- (void)displayUserImageWithURL:(NSURL *)url withSize:(CGSize)size withSearchBar:(UISearchBar *)searchBar;

- (void)showCurrentItemsWithAnimationWithDuration:(CGFloat)duration direction:(BIMDirectionMode)mode;
- (void)hideCurrentItemsWithAnimationWithDuration:(CGFloat)duration direction:(BIMDirectionMode)mode;

- (void)displayTitle;

- (void)displayPolicy;
- (void)displayCGU;

- (void)startLoader;
- (void)stopLoader;

//transition between vcs
- (id <UIViewControllerAnimatedTransitioning>)animatorPushForToVC:(BIMViewController *)toVC;
- (id <UIViewControllerAnimatedTransitioning>)animatorPopForToVC:(BIMViewController *)toVC;

- (CGFloat)offsetHeight;

- (void)reachabilityChanged;

- (void)logout;

@end
