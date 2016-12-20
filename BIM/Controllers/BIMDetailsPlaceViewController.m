//
//  BIMDetailsPlaceViewController.m
//  BIM
//
//  Created by Alexis Jacquelin on 23/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMDetailsPlaceViewController.h"
#import "BIMAnimatorDetailsPop.h"
#import "BIMButtonWithCenteredTitle.h"
#import "BIMInfluencerScrollView.h"
#import "BIMPlaceInformations.h"
#import "BIMChoosePlaceView.h"
#import "BIMMainContainerViewController.h"
#import "SMPageControl.h"
#import "BIMAPIClient+Places.h"
#import "BIMHomeViewController.h"
#import "MHFacebookImageViewer.h"

@interface BIMDetailsPlaceViewController () <UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, BIMPlaceInformationDelegate, MHFacebookImageViewerDatasource>

@property (nonatomic, strong) BIMButtonWithCenteredTitle *bookBtn;
@property (nonatomic, strong) BIMButtonWithCenteredTitle *shareBtn;
@property (nonatomic, strong) BIMButtonWithCenteredTitle *goBtn;

@property (nonatomic, strong) UIButton *bashBtn;
@property (nonatomic, strong) UIButton *bimBtn;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) BIMAnimatorDetailsPop *animatorDetailsPop;

@property (nonatomic, strong) NSMutableArray *placeViews;
@property (nonatomic, assign) CGPoint currentOffset;
@property (nonatomic, assign) BOOL isPopping;
@property (nonatomic, assign) BOOL firstTime;

@property (nonatomic, strong) SMPageControl *pageControl;

@property (nonatomic, weak) NSLayoutConstraint *constraintTopInformationPlace;
@property (nonatomic, weak) NSLayoutConstraint *constraintHeightInformationPlace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightScrollView;

//To retain the views when pushing on placesVC
@property (nonatomic, strong) BIMInfluencerScrollView *influencerScrollView_retain;
@property (nonatomic, strong) BIMPlaceInformations *informationPlace_retain;

@property (nonatomic, weak) BIMChoosePlaceView *firstPlaceView;
@property (nonatomic, strong) UIImageView *bufferIV;

@property (nonatomic, assign) BOOL facebookViewerIsVisible;

@end

@implementation BIMDetailsPlaceViewController

#pragma mark -
#pragma mark - Lazy Loading

- (BIMAnimatorDetailsPop *)animatorDetailsPop {
    if (_animatorDetailsPop == nil) {
        _animatorDetailsPop = [BIMAnimatorDetailsPop new];
    }
    return _animatorDetailsPop;
}

- (UIButton *)bimBtn {
    if (_bimBtn == nil) {
        _bimBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bimBtn setImage:[UIImage imageNamed:@"check-btn-small"] forState:UIControlStateNormal];
        _bimBtn.alpha = 0;
        [_bimBtn sizeToFit];
    }
    return _bimBtn;
}

- (UIButton *)bashBtn {
    if (_bashBtn == nil) {
        _bashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bashBtn setImage:[UIImage imageNamed:@"close-btn-small-opaque"] forState:UIControlStateNormal];
        _bashBtn.alpha = 0;
        [_bashBtn sizeToFit];
    }
    return _bashBtn;
}

- (UIButton *)closeBtn {
    if (_closeBtn == nil) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"arrow-top-btn-small"] forState:UIControlStateNormal];
        _closeBtn.alpha = 0;
        [_closeBtn sizeToFit];
    }
    return _closeBtn;
}

- (SMPageControl *)pageControl {
    if (_pageControl == nil) {
        self.pageControl = [[SMPageControl alloc] init];
        _pageControl.numberOfPages = [self.place.images count];
        _pageControl.pageIndicatorImage = [UIImage imageNamed:@"page-dot"];
        _pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"current-page-light-dot"];
        _pageControl.indicatorMargin = 5;
        _pageControl.userInteractionEnabled = NO;
        [_pageControl sizeToFit];
        _pageControl.alpha = 0;
    }
    return _pageControl;
}

- (BIMButtonWithCenteredTitle *)bookBtn {
    if (_bookBtn == nil) {
        _bookBtn = [BIMButtonWithCenteredTitle buttonWithType:UIButtonTypeCustom];
        [_bookBtn setBackgroundImage:[UIImage imageNamed:@"white-btn-bg"] forState:UIControlStateNormal];
        [_bookBtn setImage:[UIImage imageNamed:@"book-btn"] forState:UIControlStateNormal];
        [_bookBtn setTitle:SKYTrad(@"place.book.btn.title") forState:UIControlStateNormal];
        [_bookBtn setTitleColor:[UIColor bim_darkGrayColor] forState:UIControlStateNormal];
        [_bookBtn.titleLabel setFont:[UIFont bim_avenirNextRegularWithSize:14]];
        _bookBtn.alpha = 0;
        [_bookBtn sizeToFit];
        
        NSURL *url = [self.place getPhoneURL];
        if (url == nil) {
            _bookBtn.enabled = NO;
        }
        [[_bookBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            if (!url) {
                SKYLog(@"BOOK IS EMPTY");
                return;
            }
            [[UIApplication sharedApplication] openURL:url];
        }];
    }
    return _bookBtn;
}

- (BIMButtonWithCenteredTitle *)shareBtn {
    if (_shareBtn == nil) {
        _shareBtn = [BIMButtonWithCenteredTitle buttonWithType:UIButtonTypeCustom];
        [_shareBtn setBackgroundImage:[UIImage imageNamed:@"white-btn-bg"] forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageNamed:@"share-btn"] forState:UIControlStateNormal];
        [_shareBtn setTitle:SKYTrad(@"place.share.btn.title") forState:UIControlStateNormal];
        [_shareBtn setTitleColor:[UIColor bim_darkGrayColor] forState:UIControlStateNormal];
        [_shareBtn.titleLabel setFont:[UIFont bim_avenirNextRegularWithSize:14]];
        _shareBtn.alpha = 0;
        [_shareBtn sizeToFit];
        
        @weakify(self);
        [[_shareBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            UIActionSheet *actionSheet = [UIActionSheet getShareActionSheet];
            actionSheet.delegate = self;
            [actionSheet showInView:self.view];
        }];
    }
    return _shareBtn;
}

- (BIMButtonWithCenteredTitle *)goBtn {
    if (_goBtn == nil) {
        _goBtn = [BIMButtonWithCenteredTitle buttonWithType:UIButtonTypeCustom];
        [_goBtn setBackgroundImage:[UIImage imageNamed:@"white-btn-bg"] forState:UIControlStateNormal];
        [_goBtn setImage:[UIImage imageNamed:@"go-btn"] forState:UIControlStateNormal];
        [_goBtn setTitle:SKYTrad(@"place.go.btn.title") forState:UIControlStateNormal];
        [_goBtn setTitleColor:[UIColor bim_darkGrayColor] forState:UIControlStateNormal];
        [_goBtn.titleLabel setFont:[UIFont bim_avenirNextRegularWithSize:14]];
        _goBtn.alpha = 0;
        [_goBtn sizeToFit];
        
        NSURL *url = [self.place getAddressURL];
        if (url == nil) {
            _goBtn.enabled = NO;
        }
        [[_goBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            if (!url) {
                SKYLog(@"ADDRESS IS EMPTY");
                return;
            }
            [[UIApplication sharedApplication] openURL:url];
        }];
    }
    return _goBtn;
}

- (CGFloat)sizeHeightScrollView {
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone35inch:
            return 171.f;
            break;
        case iPhone47inch:
            return 264.f;
            break;
        case iPhone55inch:
            return 284.f;
            break;
        default:
            return 224.f;
    }
}

- (CGFloat)btnOkTop {
    CGFloat top = 0;
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone35inch:
            top = 217.f;
            break;
        case iPhone55inch:
            top = 433.f;
            break;
        case iPhone47inch:
            top = 396.f;
            break;
        default:
            top = 303.f;
            break;
    }
    if (self.fromPlacesVC) {
        top -= [self offsetHeight];
    }
    return top;
}

+ (CGFloat)offsetInfosPlace {
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone35inch:
            return 120.f;
            break;
        case iPhone47inch:
            return 207.f;
            break;
        case iPhone55inch:
            return 239.f;
            break;
        default:
            return 155.f;
            break;
    }
}

#pragma mark -
#pragma mark - Lifecycle

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (self.fromPlacesVC) {
        [self.view bringSubviewToFront:self.informationPlace];
        [self.view bringSubviewToFront:self.bookBtn];
        [self.view bringSubviewToFront:self.shareBtn];
        [self.view bringSubviewToFront:self.goBtn];
        [self.view bringSubviewToFront:self.influencerScrollView];
    } else {
        if (_pageControl) {
            [self.view bringSubviewToFront:self.pageControl];
        }
    }
}

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    [super customize];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(statusBarFrameChanged:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];

    self.firstTime = YES;
    
    self.constraintHeightScrollView.constant = [self sizeHeightScrollView];
    
    self.navigationItem.hidesBackButton = YES;
    self.isPopping = NO;
    [self.scrollViewIV setShowsHorizontalScrollIndicator:NO];
    @weakify(self);
    [[RACObserve(self, place) filter:^BOOL(BIMPlace *place_) {
        return place_ ? YES : NO;
    }] subscribeNext:^(BIMPlace *place_) {
        @strongify(self);
        
        if (!self.firstTime) {
            return;
        }
        self.firstTime = NO;
        [self customizeScrollView];
        if (self.fromPlacesVC) {
            [self prefillVC];
        }
        
        switch (self.place.userReview) {
            case BIMUserReviewBim:
                [self displayBIM:YES withAnimation:NO];
                break;
            case BIMUserReviewBash:
                [self displayBIM:NO withAnimation:NO];
                break;
            case BIMUserReviewEmpty:
            default:
                break;
        }
        [self.view layoutIfNeeded];
    }];
    [[RACObserve(self, influencerScrollView) filter:^BOOL(BIMInfluencerScrollView *influencerScrollView_) {
        return influencerScrollView_ ? YES : NO;
    }] subscribeNext:^(BIMInfluencerScrollView *influencerScrollView_) {
        @strongify(self);
        [self.view addSubview:self.influencerScrollView];
        
        //Prevent duplicate height constraint
        for (NSLayoutConstraint *constraint in self.influencerScrollView.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight &&
                constraint.firstItem == self.influencerScrollView &&
                constraint.secondItem == nil) {
                [self.influencerScrollView removeConstraint:constraint];
            }
        }
        [self.influencerScrollView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
        [self.influencerScrollView autoSetDimension:ALDimensionHeight toSize:kInfluencerScrollViewHeight];
        [self.influencerScrollView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.view];
        [self.influencerScrollView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.view];
    }];
    [[RACObserve(self, informationPlace) filter:^BOOL(BIMPlaceInformations *informationPlace_) {
        return informationPlace_ ? YES : NO;
    }] subscribeNext:^(BIMPlaceInformations *informationPlace_) {
        @strongify(self);
        CGFloat offsetY = self.informationPlace.top;
        if (self.fromPlacesVC) {
            offsetY = [self sizeHeightScrollView];
        }
        self.informationPlace.delegatePlaceInfos = self;
        
        [self.informationPlace removeConstraints:self.informationPlace.constraints];
        
        [self.view insertSubview:self.informationPlace belowSubview:self.bookBtn];
        self.constraintTopInformationPlace = [self.informationPlace autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:offsetY];
        [self.informationPlace autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.view];
        [self.informationPlace autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.view];
        self.constraintHeightInformationPlace = [self.informationPlace autoSetDimension:ALDimensionHeight toSize:[self.informationPlace getPlaceInformationsHeight]];
    }];
    
    if (self.fromPlacesVC) {
        self.informationPlace.nextBtn.hidden = YES;
        [[[self.bimBtn rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^RACStream *(id value) {
            [self displayBIM:YES withAnimation:YES];
            return [[BIMAPIClient sharedClient] bim:self.place];
        }] subscribeNext:^(BIMPlace *place) {
            [self.place mergeValuesForKeysFromModel:place];
        } error:^(NSError *error) {
            if ([error isAnAuthenticatedError]) {
                [self logout];
            } else {
                [error displayAlert];
                [self hideBuffer];
            }
        }];
        
        [[[self.bashBtn rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^RACStream *(id value) {
            [self displayBIM:NO withAnimation:YES];
            return [[BIMAPIClient sharedClient] bash:self.place];
        }] subscribeNext:^(BIMPlace *place) {
            [self.place mergeValuesForKeysFromModel:place];
        } error:^(NSError *error) {
            [error displayAlert];
            [self hideBuffer];
        }];

    } else {
        [[self.bimBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.facebookViewerIsVisible) {
                return;
            }
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegateHome prepareToBimCurrentPlaceForVC:self];
        }];

        [[self.bashBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.facebookViewerIsVisible) {
                return;
            }
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegateHome prepareToBashCurrentPlaceForVC:self];
        }];
    }
    
    [[self.closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.facebookViewerIsVisible) {
            return;
        }
        self.isPopping = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Viewed Details Place Page" properties:@{
                                                              @"id" : self.place.uniqueID
                                                              }];
}

- (void)hideBuffer {
    NSArray *views = @[self.bimBtn, self.bashBtn, self.bufferIV];
    for (UIView *view in views) {
        POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnim.duration = .4;
        if (view != self.bufferIV) {
            alphaAnim.toValue = @(1);
        } else {
            alphaAnim.toValue = @(0);
            [alphaAnim setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
                [view removeFromSuperview];
            }];
        }
        [self.bufferIV pop_addAnimation:alphaAnim forKey:@"alpha"];
    }
}

- (void)displayBIM:(BOOL)bim withAnimation:(BOOL)animated {
    NSString *imageName = nil;
    if (bim) {
        imageName = @"bim";
    } else {
        imageName = @"bash";
    }
    self.bufferIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [self.firstPlaceView addSubview:self.bufferIV];
    
    CGFloat offsetX = 10;
    CGFloat offsetY = 76;
    if (bim) {
        [self.bufferIV autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.firstPlaceView withOffset:offsetX];
    } else {
        [self.bufferIV autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.firstPlaceView withOffset:-offsetX];
    }
    [self.bufferIV autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.firstPlaceView withOffset:offsetY];
    
    if (animated) {
        self.bufferIV.alpha = 0;
        
        POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnim.duration = .4;
        alphaAnim.fromValue = @(0);
        alphaAnim.toValue = @(1);
        [self.bufferIV pop_addAnimation:alphaAnim forKey:@"alpha"];
        
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.duration = .4;
        scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        [self.bufferIV.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
    }
    
    NSArray *views = @[self.bimBtn, self.bashBtn];
    for (UIView *view in views) {
        POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnim.duration = .4;
        alphaAnim.toValue = @(0);
        [view pop_addAnimation:alphaAnim forKey:@"alpha"];
    }
}

- (void)disableInteraction:(BOOL)interaction {
    self.view.userInteractionEnabled = interaction;
    self.bimBtn.userInteractionEnabled = interaction;
    self.bashBtn.userInteractionEnabled = interaction;
}

- (void)setupPageControl {
    [self.view addSubview:self.pageControl];
    
    [self.pageControl autoSetDimension:ALDimensionWidth toSize:self.pageControl.width];
    [self.pageControl autoSetDimension:ALDimensionHeight toSize:self.pageControl.height];
    [self.pageControl autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.closeBtn withOffset:0];
    [self.pageControl autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnim.toValue = @(1);
    [self.pageControl pop_addAnimation:alphaAnim forKey:@"alpha"];
}

#pragma mark -
#pragma mark - Internal methods

- (void)addTopBtns {
    [self.view addSubview:self.bimBtn];
    [self.view addSubview:self.bashBtn];
    [self.view addSubview:self.closeBtn];
}

- (void)addMiddleBtn {
    self.bookBtn.alpha = 1;
    self.shareBtn.alpha = 1;
    self.goBtn.alpha = 1;

    [self.view addSubview:self.bookBtn];
    [self.view addSubview:self.shareBtn];
    [self.view addSubview:self.goBtn];
}


- (void)customizeScrollView {
    CGFloat offsetX = 0;

    self.placeViews = [NSMutableArray new];
    
    NSUInteger index = 0;
    for (NSString *imageStringURL in [self.place getImages]) {
        BIMChoosePlaceView *placeView = [[BIMChoosePlaceView alloc] initWithFrame:CGRectMake(offsetX, 0, WIDTH_DEVICE, [self sizeHeightScrollView]) andPlace:self.place withOptions:nil];
        placeView.imageURLString = imageStringURL;
        [self.scrollViewIV addSubview:placeView];
        if (offsetX == 0) {
            self.firstPlaceView = placeView;
        }
        offsetX += placeView.width + 2;
        
        [self.placeViews addObject:placeView];
        
        [placeView.imageView setupImageViewerWithDatasource:self initialIndex:index onOpen:nil onClose:nil];
        index++;
    }
    self.scrollViewIV.contentSize = CGSizeMake(offsetX, [self sizeHeightScrollView]);
}

#pragma mark -
#pragma mark - MHFacebookImageViewerDatasource

- (void)willRemoveFacebookViewer {
    self.facebookViewerIsVisible = NO;
}

- (void)willShowFacebookViewer {
    self.facebookViewerIsVisible = YES;
}

- (NSInteger)numberImagesForImageViewer:(MHFacebookImageViewer*)imageViewer {
    return [self.place.images count];
}

- (NSURL *)imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*)imageViewer {
    NSString *urlString = self.place.images[index];
    return [NSURL bim_getURLFromString:urlString];
}

- (UIImage *)imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer {
    return  [BIMPlace getBigPlaceHolder];
}

#pragma mark -
#pragma mark - Transitions between controllers

- (id <UIViewControllerAnimatedTransitioning>)animatorPopForToVC:(BIMViewController *)toVC {
    if ([toVC isKindOfClass:[BIMMainContainerViewController class]]) {
        return self.animatorDetailsPop;
    } else {
        return [super animatorPopForToVC:toVC];
    }
}

- (NSUInteger)currentPage {
    NSUInteger currentPage = round(self.scrollViewIV.contentOffset.x / self.scrollViewIV.width);
    return MIN(currentPage, self.placeViews.count - 1);
}

- (BIMChoosePlaceView *)getCurrentPlaceViewDisplayed {
    NSUInteger page = [self currentPage];
    return self.placeViews[page];
}

- (NSString *)getCurrentImageString {
    BIMChoosePlaceView *placeView = [self getCurrentPlaceViewDisplayed];
    return placeView.imageURLString;
}

- (void)setCurrentImageString:(NSString *)imageString {
    NSUInteger page = 0;
    if (imageString == nil || [imageString length] == 0) {
        return;
    }
    for (BIMChoosePlaceView *placeView in self.placeViews) {
        if (placeView.imageURLString == imageString) {
            break;
        }
        page++;
    }
    [self.scrollViewIV setContentOffset:CGPointMake(self.scrollViewIV.width * page, 0)];
}

/*
 *
 *
 *
 *
 From home
 *
 *
 *
 *
*/

- (void)setupFrameBtns {
    CGFloat offset = 40;
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone47inch:
        case iPhone55inch:
            offset = 50;
            break;
        default:
            break;
    }
    self.bookBtn.frame = CGRectOffset(self.bookBtn.frame, offset, [self btnOkTop]);
    self.shareBtn.frame = CGRectOffset(self.shareBtn.frame, round((WIDTH_DEVICE - self.shareBtn.width) / 2), self.bookBtn.top);
    self.goBtn.frame = CGRectOffset(self.goBtn.frame, WIDTH_DEVICE - self.bookBtn.left - self.goBtn.width, self.bookBtn.top);

    offset = 27;
    if (self.fromPlacesVC) {
        offset -= 20;
    }
    self.bimBtn.frame = CGRectOffset(self.bimBtn.frame, WIDTH_DEVICE - 10 - self.bimBtn.width, offset);
    self.bashBtn.frame = CGRectOffset(self.bashBtn.frame, self.bimBtn.left - self.bashBtn.width - 10, offset);
    self.closeBtn.frame = CGRectOffset(self.closeBtn.frame, 10, offset);
}

- (void)vcIsPushedWithDuration:(CGFloat)duration withCompletionBlock:(void (^)(void))completionBlock onContainerView:(UIView *)containerView {
    [self setupFrameBtns];

    [containerView addSubview:self.bookBtn];
    [containerView addSubview:self.shareBtn];
    [containerView addSubview:self.goBtn];
    [containerView addSubview:self.bimBtn];
    [containerView addSubview:self.bashBtn];
    [containerView addSubview:self.closeBtn];
    
    NSArray *views  = @[self.bookBtn, self.shareBtn, self.goBtn, self.bimBtn, self.bashBtn, self.closeBtn];
    __block BOOL firstOne = YES;
    for (UIView *view in views) {
        
        if ((view == self.bimBtn || view == self.bashBtn) &&
            self.place.userReview != BIMUserReviewEmpty) {
            continue;
        }

        POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnim.duration = duration * .8;
        alphaAnim.fromValue = @(0);
        alphaAnim.toValue = @(1);
        if (![view isKindOfClass:[BIMButtonWithCenteredTitle class]]) {
            alphaAnim.beginTime = CACurrentMediaTime() + duration * .3;
        }
        [view pop_addAnimation:alphaAnim forKey:@"alpha"];
        
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.duration = duration * .8;
        if (![view isKindOfClass:[BIMButtonWithCenteredTitle class]]) {
            scaleAnimation.beginTime = CACurrentMediaTime() + duration * .3;
        }
        scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(.5, .5)];
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        [view.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
        
        if ([view isKindOfClass:[BIMButtonWithCenteredTitle class]]) {
            [UIView animateWithDuration:duration animations:^{
                view.top -= [self offsetHeight];
            } completion:^(BOOL finished) {
                if (firstOne) {
                    [self addMiddleBtn];
                    [self addTopBtns];
                    [self setupPageControl];
                    if (completionBlock) {
                        completionBlock();
                    }
                    firstOne = NO;
                }
            }];
        }
    }
}

- (void)vcIsPoppingWithDuration:(CGFloat)duration withCompletionBlock:(void (^)(void))completionBlock {
    //Buttons
    NSArray *views  = @[self.bookBtn, self.shareBtn, self.goBtn, self.bimBtn, self.bashBtn, self.closeBtn];
    for (UIView *view in views) {
        
        if ((view == self.bimBtn || view == self.bashBtn) &&
            self.place.userReview != BIMUserReviewEmpty) {
            continue;
        }

        POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnim.duration = duration * .8;
        alphaAnim.fromValue = @(1);
        alphaAnim.toValue = @(0);
        [view pop_addAnimation:alphaAnim forKey:@"alpha"];
        
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.duration = duration * .8;
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.5, 1.5)];
        [view.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
        
        if ([view isKindOfClass:[BIMButtonWithCenteredTitle class]]) {
            [UIView animateWithDuration:duration * .8 animations:^{
                view.top += [self offsetHeight];
            } completion:nil];
        }
    }
    
    POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnim.duration = duration * .4;
    alphaAnim.toValue = @(0);
    [self.pageControl pop_addAnimation:alphaAnim forKey:@"alpha"];

    POPBasicAnimation *offsetAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPScrollViewContentOffset];
    offsetAnimation.fromValue = [NSValue valueWithCGPoint:self.currentOffset];
    offsetAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake([self currentPage] * self.scrollViewIV.width, 0)];
    offsetAnimation.duration = duration * .8;
    [self.scrollViewIV pop_addAnimation:offsetAnimation forKey:@"offset"];
    
    //Scale up the current image displayed
    //CurrentOffset is lost when poping, so I store it on a property
    BIMChoosePlaceView *placeView = [self getCurrentPlaceViewDisplayed];
    UIImageView *imageView = placeView.imageView;
    CGFloat newLeft = fmodf(self.currentOffset.x, self.scrollViewIV.width);
    if (newLeft > (self.scrollViewIV.width / 2)) {
        //do nothing
        newLeft = self.scrollViewIV.width - newLeft;
    } else {
        newLeft = -newLeft;
    }
    CGRect rect = CGRectMake(newLeft, placeView.top, placeView.width, placeView.height);
    [self.view insertSubview:imageView belowSubview:self.bookBtn];
    imageView.frame = rect;

    self.constraintTopInformationPlace.constant += [self.class offsetInfosPlace];
    self.constraintHeightInformationPlace.constant -= [self.class offsetInfosPlace];

    [UIView animateWithDuration:duration * .8 animations:^{
        imageView.frame = CGRectMake(0, 0, imageView.width, imageView.height + [self offsetHeight]);
        self.informationPlace.scrollView.contentOffset = CGPointZero;
        self.informationPlace.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.view layoutIfNeeded];
    }];
}

/*
 *
 *
 *
 *
 From map
 *
 *
 *
 *
 */

- (void)showCurrentItemsWithAnimationWithDuration:(CGFloat)duration direction:(BIMDirectionMode)mode {
    //Back btn
    UIButton *backBtn = [UIButton bim_getBackBtn];
    backBtn.alpha = 0;
    CGFloat translation = kItemTranslationX;
    if (mode == BIMDirectionModeLeft) {
        translation *= -1;
    }
    if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        [backBtn setFrame:CGRectOffset(backBtn.frame, 7, 2)];
    } else {
        [backBtn setFrame:CGRectOffset(backBtn.frame, 3, 2)];
    }
    [self.navigationController.navigationBar addSubview:backBtn];
    [self.navigationController.navigationBar addSubview:self.bashBtn];
    [self.navigationController.navigationBar addSubview:self.bimBtn];
    [self.navigationController.navigationBar addSubview:self.pageControl];

    NSArray *btns = @[backBtn, self.bashBtn, self.bimBtn, self.pageControl];
    BOOL firstTime = YES;
    for (UIButton *btn in btns) {
        
        if ((btn == self.bimBtn || btn == self.bashBtn) &&
            self.place.userReview != BIMUserReviewEmpty) {
                continue;
        }
        POPSpringAnimation *translateAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        translateAnimation.fromValue = [NSValue valueWithCGRect:CGRectOffset(btn.frame, translation, 0)];
        translateAnimation.toValue = [NSValue valueWithCGRect:CGRectOffset(btn.frame, 0, 0)];
        [btn pop_addAnimation:translateAnimation forKey:@"translation"];
        
        POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation.duration = duration;
        alphaAnimation.toValue = @(1);
        [btn pop_addAnimation:alphaAnimation forKey:@"alpha"];
        
        if (firstTime) {
            [alphaAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
                [self addCustomItems];
                [backBtn removeFromSuperview];
            }];
            firstTime = NO;
        }
    }
}

- (void)hideCurrentItemsWithAnimationWithDuration:(CGFloat)duration direction:(BIMDirectionMode)mode {
    UIButton *backBtn = [UIButton bim_getBackBtn];
    
    CGFloat translation = kItemTranslationX;
    if (mode == BIMDirectionModeLeft) {
        translation *= -1;
    }    
    if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        [backBtn setFrame:CGRectOffset(backBtn.frame, 7, 2)];
    } else {
        [backBtn setFrame:CGRectOffset(backBtn.frame, 3, 2)];
    }
    [self.navigationController.navigationBar addSubview:backBtn];
    
    //Remove the current
    self.navigationItem.leftBarButtonItems = nil;
    
    NSArray *btns = @[backBtn, self.bashBtn, self.bimBtn, self.pageControl];
    for (UIButton *btn in btns) {

        if ((btn == self.bimBtn || btn == self.bashBtn) &&
            self.place.userReview != BIMUserReviewEmpty) {
            continue;
        }

        POPSpringAnimation *translateAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        translateAnimation.fromValue = [NSValue valueWithCGRect:CGRectOffset(btn.frame, 0, 0)];
        translateAnimation.toValue = [NSValue valueWithCGRect:CGRectOffset(btn.frame, translation, 0)];
        [btn pop_addAnimation:translateAnimation forKey:@"translation"];
        
        POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation.duration = duration;
        alphaAnimation.toValue = @(0);
        [btn pop_addAnimation:alphaAnimation forKey:@"alpha"];
        
        [alphaAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
            [btn removeFromSuperview];
        }];
    }
}

- (void)addCustomItems {
    [self addLeftBackBtnItem];
}

- (void)prefillVC {
    [self setupFrameBtns];
    self.pageControl.center = CGPointMake(round(self.navigationController.navigationBar.width / 2), round(self.navigationController.navigationBar.height / 2));
    [self addMiddleBtn];

    self.informationPlace_retain = [[[NSBundle mainBundle] loadNibNamed:@"BIMPlaceInformations" owner:self options:nil] firstObject];
    self.informationPlace_retain.place = self.place;
    self.informationPlace = self.informationPlace_retain;
    self.informationPlace.withoutAnimation = YES;
    self.informationPlace.mode = BIMPlaceModeComplexe;
    
    self.influencerScrollView_retain = [[BIMInfluencerScrollView alloc] initWithPlace:self.place];
    self.influencerScrollView_retain.place = self.place;
    self.influencerScrollView = self.influencerScrollView_retain;
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isPopping) {
        int page = round(scrollView.contentOffset.x /scrollView.width);
        self.pageControl.currentPage = page;
        self.currentOffset = self.scrollViewIV.contentOffset;
    }
}

#pragma mark -
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImage *image = [self.view bim_image];
    NSString *titlebtn = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([titlebtn isEqualToString:SKYTrad(@"place.share.on.message")]) {
        //message
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *smsComposer = [[MFMessageComposeViewController alloc] init];
            smsComposer.messageComposeDelegate = self;
            [smsComposer addAttachmentData:UIImagePNGRepresentation(image) typeIdentifier:@"kUTTypeImage" filename:@"place.png"];
            if ([self.place.URLString isKindOfClass:[NSString class]]) {
                [smsComposer setBody:SKYTrad(@"sms.share.place.body", [self.place getDescriptionPlace], self.place.URLString)];
            } else {
                [smsComposer setBody:SKYTrad(@"sms.share.place.body.without.url", [self.place getDescriptionPlace])];
            }
            [self presentViewController:smsComposer animated:YES completion:nil];
        }
    } else if ([titlebtn isEqualToString:SKYTrad(@"place.share.on.mail")]) {
        //mail
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            [mailComposer setSubject:SKYTrad(@"mail.share.place.title")];
            [mailComposer addAttachmentData:UIImagePNGRepresentation(image) mimeType:@"png" fileName:@"place.png"];

            if ([self.place.URLString isKindOfClass:[NSString class]]) {
                [mailComposer setMessageBody:SKYTrad(@"mail.share.place.body", [self.place getDescriptionPlace], self.place.URLString) isHTML:NO];
            } else {
                [mailComposer setMessageBody:SKYTrad(@"mail.share.place.body.without.url", [self.place getDescriptionPlace]) isHTML:NO];
            }
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
    } else if ([titlebtn isEqualToString:SKYTrad(@"place.share.on.facebook")]) {
        //facebook
        [[SKYFacebookManager sharedSKYFacebookManager] openWriteSessionWithSuccess:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *initialText = SKYTrad(@"facebook.share.place.description", [self.place getDescriptionPlace]);
                BOOL displayedNativeDialog = [FBDialogs presentOSIntegratedShareDialogModallyFrom:self initialText:initialText image:image url:nil handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
                    if (error) {
                        [error displayAlert];
                    }
                }];
                if (!displayedNativeDialog) {
                    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                    [params setValue:SKYTrad(@"facebook.share.place.description", [self.place getDescriptionPlace]) forKey:@"description"];

                    
                    if ([self.place.URLString isKindOfClass:[NSString class]]) {
                        [params setValue:self.place.URLString forKey:@"link"];
                    }
                    // Invoke the dialog
                    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                                           parameters:params
                                                              handler:
                     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                         if (error) {
                             [error displayAlert];
                         }
                     }];
                }
            });
        } andFailure:^(NSError *error) {
            [error displayAlert];
        }];
    } else {
        //cancel
        return;
    }
}

#pragma mark -
#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - BIMPlaceInformationDelegate

- (void)getNextPlaceFor:(BIMPlaceInformations *)placeInfos {
    if (self.facebookViewerIsVisible) {
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegateHome prepareToNextCurrentPlaceForVC:self];
}

- (void)goBackToSyntheticView:(BIMPlaceInformations *)placeInfos {
    if (self.facebookViewerIsVisible) {
        return;
    }
    if (!self.fromPlacesVC) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark - Notif

- (void)statusBarFrameChanged:(NSNotification *)notification {
    CGFloat heightSV = [self.informationPlace getPlaceInformationsHeight];
    if (HAS_IN_CALL_STATUS_BAR) {
        heightSV -= HEIGHT_STATUS_BAR;
    }
    self.constraintHeightInformationPlace.constant = heightSV;
}

@end
