//
//  BIMLoginViewController.m
//  BIM
//
//  Created by Alexis Jacquelin on 22/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMLoginViewController.h"
#import "SMPageControl.h"
#import "BIMUser.h"
#import "BIMSplashAnimatedView.h"
#import "AppDelegate+AddOn.h"
#import "BIMCategoriesViewController.h"

#define TUTO_COUNT 3

@interface BIMLoginViewController () <UIScrollViewDelegate> {
}

@property (weak, nonatomic) IBOutlet UIImageView *logoIV;
@property (weak, nonatomic) IBOutlet UIImageView *loginBgIV;
@property (weak, nonatomic) IBOutlet BIMButtonWithLoader *facebookBtn;
@property (weak, nonatomic) IBOutlet UIButton *policyBtn;
@property (weak, nonatomic) IBOutlet UIButton *cguBtn;

@property (weak, nonatomic) IBOutlet UILabel *facebookDescriptionLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewTitle;

@property (nonatomic, strong) SMPageControl *pageControl;

//constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTitleTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomPadding;

@property (nonatomic, strong) BIMSplashAnimatedView *splashAnimatedView;

@end

@implementation BIMLoginViewController

#pragma mark -
#pragma mark - Lazy Loading

- (BIMSplashAnimatedView *)splashAnimatedView {
    if (_splashAnimatedView == nil) {
        _splashAnimatedView = [[BIMSplashAnimatedView alloc] initWithFrame:self.view.bounds];
        [_splashAnimatedView setBackgroundColor:[UIColor clearColor]];
    }
    return _splashAnimatedView;
}

#pragma mark -
#pragma mark - Lifecycle

- (void)loadView {
    [super loadView];
    
    //I add the scrollView because I need it to customize the layout on viewDidLoad
    [self.view addSubview:self.scrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.fromDisconnection) {
        [self displaySplashAnimation];
        self.fromDisconnection = NO;
    }
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Viewed Login Page"];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.view bringSubviewToFront:self.pageControl];
}

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    [super customize];
    
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setPagingEnabled:YES];
    
    self.facebookBtn.imageLoader = @"white-loader";
    
    if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
        self.loginBgIV.image = [UIImage imageNamed:@"login-background-iPhone6"];
    }
    
    [UIView performWithoutAnimation:^{
        [self.facebookBtn setSKYTitle:SKYTrad(@"login.facebook.btn.title")];
        [self.facebookDescriptionLabel setText:SKYTrad(@"login.facebook.description")];
        [self.policyBtn setSKYTitle:SKYTrad(@"login.private.policy.title")];
        [self.cguBtn setSKYTitle:SKYTrad(@"login.cgu.title")];
        
        switch ([SDiPhoneVersion deviceSize]) {
            case iPhone55inch:
                [self.facebookBtn.titleLabel setFont:[UIFont bim_avenirNextRegularWithSizeAndWithoutChangeSize:23.f]];
                break;
            default:
                [self.facebookBtn.titleLabel setFont:[UIFont bim_avenirNextRegularWithSize:18.5f]];
                break;
        }
        [self.facebookDescriptionLabel setFont:[UIFont bim_avenirNextRegularWithSize:10.f]];
        [self.policyBtn.titleLabel setFont:[UIFont bim_avenirNextRegularWithSize:10.5f]];
        [self.cguBtn.titleLabel setFont:[UIFont bim_avenirNextRegularWithSize:10.5f]];
        [self.facebookBtn setSKYTitleColor:[UIColor whiteColor]];
        [self.facebookDescriptionLabel setTextColor:[UIColor bim_blueColor]];
        [self.policyBtn setSKYTitleColor:[UIColor bim_darkBlueColor]];
        [self.cguBtn setSKYTitleColor:[UIColor bim_darkBlueColor]];
        
        [self.policyBtn.layer setCornerRadius:4];
        [self.cguBtn.layer setCornerRadius:4];

        [self.policyBtn setBackgroundColor:[UIColor bim_midnightBlueColor]];
        [self.cguBtn setBackgroundColor:[UIColor bim_midnightBlueColor]];
        
        if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
            [self.facebookBtn setTitleEdgeInsets:UIEdgeInsetsMake(4, 45, 0, 0)];
        } else {
            [self.facebookBtn setTitleEdgeInsets:UIEdgeInsetsMake(2, 45, 0, 0)];
        }
        [self.policyBtn setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
        [self.cguBtn setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
    }];
    [self setupConstraints];
    [self setupScrollView];
    [self setupPageControl];

    @weakify(self);
    [[self.facebookBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(BIMButtonWithLoader *facebookBtn_) {
        @strongify(self);
        [facebookBtn_ startLoader];
        [self facebookConnect];
    }];
    
    [[self.policyBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self displayPolicy];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Viewed Policy Page"];
    }];

    [[self.cguBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self displayCGU];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Viewed CGU Page"];
    }];
}

- (void)setupConstraints {
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone35inch:
            self.logoIV.hidden = YES;
            [self.loginBgIV autoSetDimension:ALDimensionHeight toSize:350];
            [self.scrollView autoSetDimension:ALDimensionHeight toSize:252];
            self.scrollViewTitleTopConstraint.constant = -90;
            break;
        default:
            break;
    }
}

- (void)setupScrollView {
    CGFloat offset = 0;
    int i = 1;
    while (i <= TUTO_COUNT) {
        NSString *nameImage = [NSString stringWithFormat:@"tuto%d", i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:nameImage]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.scrollView addSubview:imageView];
        
        if (IOS8) {
            [imageView autoSetDimension:ALDimensionWidth toSize:WIDTH_DEVICE];
            [imageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.scrollView];
            [imageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:offset];
            [imageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        } else {
            imageView.frame = CGRectMake(offset, 0, WIDTH_DEVICE, 255);
        }
        UILabel *label = [UILabel new];
        NSString *title = [NSString stringWithFormat:@"tuto%d", i];
        label.text = SKYTrad(title);
        label.font = [UIFont bim_avenirNextRegularWithSize:16.5f];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        //setup constraint
        [self.scrollViewTitle addSubview:label];
        if (IOS8) {
            [label autoSetDimension:ALDimensionWidth toSize:WIDTH_DEVICE];
            [label autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.scrollViewTitle];
            [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:offset * 2];
            [label autoPinEdgeToSuperviewEdge:ALEdgeTop];
        } else {
            label.frame = CGRectMake(offset * 2, 0, WIDTH_DEVICE, 32);
        }
        offset += WIDTH_DEVICE;
        i++;
    }
    [self.scrollView setContentSize:CGSizeMake(offset, 0)];
    [self.scrollViewTitle setContentSize:CGSizeMake(offset, 0)];
}

- (void)setupPageControl {
    self.pageControl = [[SMPageControl alloc] init];
    self.pageControl.numberOfPages = TUTO_COUNT;
    self.pageControl.pageIndicatorImage = [UIImage imageNamed:@"current-page-dot"];
    self.pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"page-dot"];
    self.pageControl.indicatorMargin = 5;
    self.pageControl.userInteractionEnabled = NO;
    [self.pageControl sizeToFit];
    [self.view addSubview:self.pageControl];

    [self.pageControl autoSetDimension:ALDimensionWidth toSize:self.pageControl.width];
    [self.pageControl autoSetDimension:ALDimensionHeight toSize:self.pageControl.height];
    [self.pageControl autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.scrollView];
    [self.pageControl autoAlignAxisToSuperviewAxis:ALAxisVertical];
}

- (void)displayHome {
    BIMAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    UINavigationController *containerNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"containerNavVC"];
    
    [delegate changeRootViewController:containerNavVC];
}

- (void)facebookConnect {
    @weakify(self);
    [[[self facebookConnectSignal] flattenMap:^RACStream *(RACTuple *tuple) {
        @strongify(self);
        RACTupleUnpack(NSString *uid,
                       NSString *token) = tuple;
        return [self connectSignalWithUDID:uid token:token];
    }] subscribeError:^(NSError *error) {
        @strongify(self);
        [self.facebookBtn stopLoader];
        [error displayAlert];
    } completed:^{
        @strongify(self);
        [self.facebookBtn stopLoader];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Login"];
        
        [USER_DEFAULT setObject:@YES forKey:kModeLocation];
        [self performSelector:@selector(displayHome) withObject:nil afterDelay:.15];
    }];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = round(self.scrollView.contentOffset.x /self.scrollView.width);
    
    if (self.pageControl.currentPage != page) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        NSString *string = [NSString stringWithFormat:@"Viewed Tuto Page %d", page];
        [mixpanel track:string];
    }
    
    self.pageControl.currentPage = page;
    
    self.scrollViewTitle.contentOffset = CGPointMake(scrollView.contentOffset.x * 2, scrollView.contentOffset.y);
    
    //Alpha on scrollViewTitle
    if (scrollView.contentOffset.x >= 0 &&
        scrollView.contentOffset.x <= (scrollView.contentSize.width - scrollView.width)) {
        
        CGFloat offset = scrollView.contentOffset.x - (page * scrollView.width);
        offset = fabsf(offset);
        CGFloat alpha = 0;
        const CGFloat maxOffset = 30;
        if (offset <= maxOffset) {
            alpha = (maxOffset - offset) / maxOffset;
        }
        self.scrollViewTitle.alpha = alpha;
    } else {
        self.scrollViewTitle.alpha = 1;
    }
}

#pragma mark -
#pragma mark - WS

- (RACSignal *)facebookConnectSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.facebookBtn startLoader];
        [[SKYFacebookManager sharedSKYFacebookManager] connectWithCompletionHandler:^(NSDictionary *infos, NSString *token) {
            if (infos) {
                [[RACSignal return:RACTuplePack(infos[@"id"], token)] subscribe:subscriber];
            } else {
                NSError *errorGeneric = [NSError getAuthentificationFacebookFailed];
                [subscriber sendError:errorGeneric];
            }
        } andFailureHandler:^(NSError *error) {
            NSError *errorFacebook = [error getFormartedErrorForFacebookError];;
            [subscriber sendError:errorFacebook];
        }];
        return nil;
    }];
}

- (RACSignal *)connectSignalWithUDID:(NSString *)uid token:(NSString *)token {
    BIMUser *user = [BIMUser userWithRawUID:uid];
    return [[BIMAPIClient sharedClient] signInAsUser:user token:token];
}

#pragma mark -
#pragma mark - Splash animation

- (void)displaySplashAnimation {
    self.scrollViewTitle.alpha = 0;
    self.pageControl.alpha = 0;
    self.scrollView.alpha = 0;
    
    [self.view addSubview:self.splashAnimatedView];
    
    [self.splashAnimatedView startAnimationWithAnimations:^{
        POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnim.beginTime = CACurrentMediaTime() + .35;
        alphaAnim.toValue = @(1);
        [self.scrollViewTitle pop_addAnimation:alphaAnim forKey:@"alpha"];
        
        alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnim.beginTime = CACurrentMediaTime() + .35;
        alphaAnim.toValue = @(1);
        [self.scrollView pop_addAnimation:alphaAnim forKey:@"alpha"];
        
        POPSpringAnimation *translateAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
        translateAnimation.beginTime = CACurrentMediaTime() + .35;
        translateAnimation.fromValue = @(-5);
        translateAnimation.toValue = @(0);
        [self.scrollViewBottomPadding pop_addAnimation:translateAnimation forKey:@"translate"];
        
        alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnim.beginTime = CACurrentMediaTime() + .35;
        alphaAnim.toValue = @(1);
        [self.pageControl pop_addAnimation:alphaAnim forKey:@"alpha"];
        
    } andCompletionBlock:^{
        [self.splashAnimatedView removeFromSuperview];
    }];
}

@end