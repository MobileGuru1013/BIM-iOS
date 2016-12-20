//
//  BIMViewController.m
//  Bim
//
//  Created by Alexis Jacquelin on 02/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMViewController.h"
#import "BIMAnimatorPush.h"
#import "BIMAnimatorPop.h"
#import "BIMLoginViewcontroller.h"
#import "AppDelegate+AddOn.h"
#import "BIMAPIClient+User.h"

CGFloat const kItemTranslationX = 20;

@interface BIMViewController() {
}

@property (nonatomic, strong) BIMAnimatorPush *animatorPush;
@property (nonatomic, strong) BIMAnimatorPop *animatorPop;

@end

@implementation BIMViewController

#pragma mark -
#pragma mark - Lazy Loading

- (BIMAnimatorPush *)animatorPush {
    if (_animatorPush == nil) {
        _animatorPush = [BIMAnimatorPush new];
    }
    return _animatorPush;
}

- (BIMAnimatorPop *)animatorPop {
    if (_animatorPop == nil) {
        _animatorPop = [BIMAnimatorPop new];
    }
    return _animatorPop;
}

#pragma mark -
#pragma mark - Lifecycle

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (self.loader) {
        [self.loader.superview bringSubviewToFront:self.loader];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(reachabilityChanged) name:NOTIF_REACHABLE object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [NOTIFICATION_CENTER removeObserver:self name:SKYReachabilityChangedNotification object:nil];
}

- (void)reachabilityChanged {
}

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    [super customize];
    
    self.navigationController.navigationBar.topItem.title = @"";
}

- (void)addLeftBackBtnItem {
    UIButton *backBtn = [UIButton bim_getBackBtn];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -13.f;
    self.navigationItem.leftBarButtonItems = @[spaceItem, backItem];
    
    [[backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn_) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)addLoaderOnView:(UIView *)view {
    if (view == nil) {
        view = self.view;
    }
    self.loader = [BIMLoader new];
    [view addSubview:self.loader];
    [self.loader autoCenterInSuperview];
    [self.loader autoSetDimensionsToSize:CGSizeMake(self.loader.width, self.loader.height)];
}

- (void)addCloseBtnOnNavigationItem:(UINavigationItem *)navigationItem {
    UIImage *closeImg = [UIImage imageNamed:@"close-btn-small"];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:closeImg style:UIBarButtonItemStylePlain target:self action:@selector(pressedCloseButton)];
    [closeItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = closeItem;
}

- (void)displayUserImageWithURL:(NSURL *)url withSize:(CGSize)size withSearchBar:(UISearchBar *)searchBar {
    if (url == nil) {
        SKYLog(@"URLSTRING IS EMPTY");
        return;
    }
    size = CGSizeMake(size.width, size.height + searchBar.height);
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    @weakify(self);
    [manager downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            [image bim_resizeImageWithSize:CGSizeMake(size.width, size.height) withCompletionBlock:^(UIImage *imageResized) {
                UIImage *imageBlurred = [imageResized bim_blur];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                    @strongify(self);
                    UIImage *imageBlurredTop = [imageBlurred bim_croppedImage:CGRectMake(0, 0, size.width, size.height - searchBar.height)];
                    UIImage *imageBlurredBottom = nil;
                    if (searchBar) {
                        imageBlurredBottom = [imageBlurred bim_croppedImage:CGRectMake(0, searchBar.height, size.width, searchBar.height)];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.tintedTopIV && [self.tintedTopIV.urlString isEqualToString:url.absoluteString]) {
                            self.tintedTopIV.alpha = 0;
                            [self.view addSubview:self.tintedTopIV];
                            return;
                        }
                        UIView *oldTintedView = self.tintedTopIV;
                        self.tintedTopIV = [[BIMTintedImageView alloc] initWithImage:imageBlurredTop color:[UIColor bim_midnightBlueColor] size:size];
                        self.tintedTopIV.urlString = url.absoluteString;
                        if (searchBar) {
                            BIMTintedImageView *tintedBottomIV = [[BIMTintedImageView alloc] initWithImage:imageBlurredBottom color:[UIColor bim_midnightBlueColor] size:size];
                            UIImage *backgroundSearchBar = [tintedBottomIV bim_image];
                            [searchBar setBackgroundImage:backgroundSearchBar];
                        }
                        [self.view addSubview:self.tintedTopIV];
                        
                        self.tintedTopIV.alpha = 0;
                        [UIView animateWithDuration:.3 animations:^{
                            self.tintedTopIV.alpha = 1;
                            oldTintedView.alpha = 0;
                        } completion:^(BOOL finished) {
                            [oldTintedView removeFromSuperview];
                        }];
                    });
                });
            }];
        }
    }];
}

- (CGFloat)offsetHeight {
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone35inch:
            return 85.f;
            break;
        case iPhone55inch:
            return 195.f;
//            return 255.f;
            break;
        case iPhone47inch:
            return 170.f;
            break;
        default:
            return 120.f;
            break;
    }
}

#pragma mark -
#pragma mark - Transitions between controllers

- (id <UIViewControllerAnimatedTransitioning>)animatorPushForToVC:(BIMViewController *)toVC {
    return self.animatorPush;
}

- (id <UIViewControllerAnimatedTransitioning>)animatorPopForToVC:(BIMViewController *)toVC {
    return self.animatorPop;
}

#pragma mark -
#pragma mark - Actions

- (void)pressedCloseButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showCurrentItemsWithAnimationWithDuration:(CGFloat)duration direction:(BIMDirectionMode)mode {
}

- (void)hideCurrentItemsWithAnimationWithDuration:(CGFloat)duration direction:(BIMDirectionMode)mode {
}

- (void)displayTitle {
}

- (void)displayPolicy {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:LEGALES_URL]];
}

- (void)displayCGU {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:CGU_URL]];
}

- (void)logout {
    [[[BIMAPIClient sharedClient] logoutUser] subscribeError:^(NSError *error) {
        [self resetVCs];
    } completed:^{
        [self resetVCs];
    }];;
}

- (void)resetVCs {
    [[BIMAPIClient sharedClient] logout];
    BIMAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    BIMLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BIMLoginViewController"];
    loginVC.fromDisconnection = YES;
    [delegate changeRootViewController:loginVC];
}

- (void)startLoader {
    [self.loader startAnimating];
}

- (void)stopLoader {
    [self.loader stopAnimating];
}

@end
