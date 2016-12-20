//
//  BIMSettingsViewController.m
//  BIM
//
//  Created by Alexis Jacquelin on 31/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMSettingsViewController.h"

static NSString * const OMTSURLString =  @"http://www.onemorethingstudio.com";

@interface BIMSettingsViewController() <MFMailComposeViewControllerDelegate> {
}

@property (nonatomic, assign) BOOL blueMode;

@end

@implementation BIMSettingsViewController

#pragma mark -
#pragma mark - Lifecycle

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.blueCircle.layer.cornerRadius = round(self.blueCircle.width / 2);
}

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    [super customize];
    
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone47inch:
            self.widthCircleConstraint.constant = 190;
            break;
        case iPhone55inch:
            self.widthCircleConstraint.constant = 210;
            break;
        default:
            break;
    }
    
    self.blueMode = NO;
    
    self.navigationItem.hidesBackButton = YES;
    self.blueCircle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue-color"]];
    [self.blueCircle.layer setMasksToBounds:YES];

    if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
        self.logoIV.image = [UIImage imageNamed:@"white-logo-iPhone6"];
    }

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeBackground)];
    self.logoIV.userInteractionEnabled = YES;
    [self.logoIV addGestureRecognizer:tapGesture];
    
    [UIView performWithoutAnimation:^{
        [self.feedbackBtn setSKYTitle:SKYTrad(@"settings.feedback.title")];
        [self.guruBtn setSKYTitle:SKYTrad(@"settings.guru.title")];
        [self.disconnectBtn setSKYTitle:SKYTrad(@"settings.disconnect.title")];
        [self.policyBtn setSKYTitle:SKYTrad(@"login.private.policy.title")];
        [self.cguBtn setSKYTitle:SKYTrad(@"login.cgu.title")];
        
        [self.feedbackBtn.titleLabel setFont:[UIFont bim_avenirNextRegularWithSize:21.f]];
        [self.guruBtn.titleLabel setFont:[UIFont bim_avenirNextRegularWithSize:21.f]];
        [self.disconnectBtn.titleLabel setFont:[UIFont bim_avenirNextRegularWithSize:21.f]];
        [self.policyBtn.titleLabel setFont:[UIFont bim_avenirNextRegularWithSize:10.5f]];
        [self.cguBtn.titleLabel setFont:[UIFont bim_avenirNextRegularWithSize:10.5f]];
        
        [self.feedbackBtn setSKYTitleColor:[UIColor bim_darkBlueColor]];
        [self.guruBtn setSKYTitleColor:[UIColor bim_darkBlueColor]];
        [self.disconnectBtn setSKYTitleColor:[UIColor whiteColor]];
        [self.policyBtn setSKYTitleColor:[UIColor bim_darkBlueColor]];
        [self.cguBtn setSKYTitleColor:[UIColor bim_darkBlueColor]];
        
        [self.feedbackBtn.layer setCornerRadius:4];
        [self.guruBtn.layer setCornerRadius:4];
        [self.disconnectBtn.layer setCornerRadius:4];
        [self.policyBtn.layer setCornerRadius:4];
        [self.cguBtn.layer setCornerRadius:4];
        
        [self.feedbackBtn setTintColor:[UIColor bim_darkBlueColor]];
        [self.guruBtn setTintColor:[UIColor bim_darkBlueColor]];

        [self.feedbackBtn setBackgroundColor:[UIColor bim_blackColor]];
        [self.guruBtn setBackgroundColor:[UIColor bim_blackColor]];
        [self.disconnectBtn setBackgroundColor:[UIColor bim_redColor]];
        [self.policyBtn setBackgroundColor:[UIColor bim_midnightBlueColor]];
        [self.cguBtn setBackgroundColor:[UIColor bim_midnightBlueColor]];
        
        [self.feedbackBtn setImageEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 15)];
        [self.guruBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
        [self.disconnectBtn setImageEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 10)];

        [self.feedbackBtn setTitleEdgeInsets:UIEdgeInsetsMake(2, 15, 0, 0)];
        [self.guruBtn setTitleEdgeInsets:UIEdgeInsetsMake(2, 15, 0, 0)];
        [self.disconnectBtn setTitleEdgeInsets:UIEdgeInsetsMake(1, 10, 0, 0)];
        [self.policyBtn setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
        [self.cguBtn setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
    }];
    
    @weakify(self);
    [[self.disconnectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self logout];
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
    
    [[self.feedbackBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Feedback Sent"];

        NSString *iPhoneVersion = [NSObject bim_deviceDescription];
        
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            [mailComposer setSubject:SKYTrad(@"mail.feedback.title")];
            [mailComposer setMessageBody:SKYTrad(@"mail.feedback.description", iPhoneVersion) isHTML:NO];
            [mailComposer setToRecipients:FEEDBACK_RECIPIENTS];
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
    }];

    [[self.guruBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Become Guru Sent"];
        
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            [mailComposer setSubject:SKYTrad(@"mail.become.guru.title")];
            [mailComposer setMessageBody:SKYTrad(@"mail.become.guru.description") isHTML:NO];
            [mailComposer setToRecipients:GURU_RECIPIENTS];
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
    }];

    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Viewed Settings Page"];
}

- (void)addCustomItems {
    [self addLeftBackBtnItem];
}

- (void)displayTitle {
    self.navigationItem.title = SKYTrad(@"settings.title");
}

#pragma mark -
#pragma mark - Tap Gesture

- (void)changeBackground {
    CGFloat multiplier = 1;
    if (self.blueMode == NO) {
        if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
            multiplier = 8;
        } else if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
            multiplier = 9;
        } else {
            multiplier = 7;
        }
    }
    self.blueMode = !self.blueMode;
    [self.blueCircle pop_removeAnimationForKey:@"scale"];
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(multiplier, multiplier)];
    scaleAnimation.springSpeed = 4;
    [self.blueCircle.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
}

#pragma mark -
#pragma mark - Animations

- (void)showCurrentItemsWithAnimationWithDuration:(CGFloat)duration direction:(BIMDirectionMode)mode {
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
    
    POPSpringAnimation *translateAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    translateAnimation.fromValue = [NSValue valueWithCGRect:CGRectOffset(backBtn.frame, translation, 0)];
    translateAnimation.toValue = [NSValue valueWithCGRect:CGRectOffset(backBtn.frame, 0, 0)];
    [backBtn pop_addAnimation:translateAnimation forKey:@"translation"];
    
    POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnimation.duration = duration;
    alphaAnimation.toValue = @(1);
    [backBtn pop_addAnimation:alphaAnimation forKey:@"alpha"];
    
    [alphaAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        [self addCustomItems];
        [backBtn removeFromSuperview];
    }];
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
    
    POPSpringAnimation *translateAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    translateAnimation.fromValue = [NSValue valueWithCGRect:CGRectOffset(backBtn.frame, 0, 0)];
    translateAnimation.toValue = [NSValue valueWithCGRect:CGRectOffset(backBtn.frame, translation, 0)];
    [backBtn pop_addAnimation:translateAnimation forKey:@"translation"];
    
    POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnimation.duration = duration;
    alphaAnimation.toValue = @(0);
    [backBtn pop_addAnimation:alphaAnimation forKey:@"alpha"];
    
    [alphaAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        [backBtn removeFromSuperview];
    }];
}

#pragma mark -
#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
