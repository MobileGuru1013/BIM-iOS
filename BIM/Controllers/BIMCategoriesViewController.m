//
//  BIMCategoriesViewController.m
//  BIM
//
//  Created by Alexis Jacquelin on 21/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMCategoriesViewController.h"
#import "BIMCategoryButton.h"
#import "BIMGooglePlace.h"
#import "BIMHomeViewController.h"
#import "BIMSearchLocationViewController.h"

typedef NS_ENUM(NSUInteger, BIMCategoryFilter) {
    BIMCategoryFilterEat = 1,
    BIMCategoryFilterDrink = 2,
    BIMCategoryFilterDaylife = 3,
    BIMCategoryFilterNightlife = 4
};

typedef NS_ENUM(NSUInteger, BIMEuroFilter) {
    BIMEuroFilter1 = 1,
    BIMEuroFilter2 = 2,
    BIMEuroFilter3 = 3,
    BIMEuroFilter4 = 4
};

static NSUInteger const kTagCategory = 50;
static NSUInteger const kTagEuro = 30;
static NSString * const kSegueIdentifierSomeWhereElse = @"go somewhere else";

@interface BIMCategoriesViewController () {
    BOOL _firstTime;
}

@end

@implementation BIMCategoriesViewController

#pragma mark -
#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_firstTime) {
        _firstTime = NO;
        [self initializeCategories];
        [self initializeEuros];
        [self initializeModeLocation];
    }
}

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    [super customize];
    
    _firstTime = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToHomeVC)];
    [self.logoIV addGestureRecognizer:tapGesture];
    self.logoIV.userInteractionEnabled = YES;
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(refreshLocation) name:kRefreshLocation object:nil];
    
    [self activeAfterScrolling];
    
    for (BIMCategoryButton *btn in self.categoryBtns) {
        switch ((BIMCategoryFilter)(btn.tag - kTagCategory)) {
            case BIMCategoryFilterEat:
                [btn setCustomTitle:SKYTrad(@"menu.eat")];
                break;
            case BIMCategoryFilterDrink:
                [btn setCustomTitle:SKYTrad(@"menu.drink")];
                break;
            case BIMCategoryFilterDaylife:
                [btn setCustomTitle:SKYTrad(@"menu.daylife")];
                break;
            case BIMCategoryFilterNightlife:
                [btn setCustomTitle:SKYTrad(@"menu.nightlife")];
                break;
            default:
                break;
        }
    }
    for (BIMEuroButton *btn in self.euroBtns) {
        switch ((BIMEuroFilter)(btn.tag - kTagEuro)) {
            case BIMEuroFilter1:
                [btn setSKYTitle:SKYTrad(@"menu.euro1")];
                break;
            case BIMEuroFilter2:
                [btn setSKYTitle:SKYTrad(@"menu.euro2")];
                break;
            case BIMEuroFilter3:
                [btn setSKYTitle:SKYTrad(@"menu.euro3")];
                break;
            case BIMEuroFilter4:
                [btn setSKYTitle:SKYTrad(@"menu.euro4")];
                break;
            default:
                break;
        }
    }
    [self.aroundMeButton setSKYTitle:SKYTrad(@"menu.around.me")];
    [self.aroundMeButton setImage:[UIImage imageNamed:@"map-icon-transluscent"] forState:UIControlStateNormal];
    [self.aroundMeButton setImage:[UIImage imageNamed:@"map-icon"] forState:UIControlStateSelected];
    self.aroundMeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 1, 12);
    
    [self.somewhereElseButton setSKYTitle:SKYTrad(@"menu.somewhere.else")];
    [self.somewhereElseButton setImage:[UIImage imageNamed:@"magnifying-icon-transluscent"] forState:UIControlStateNormal];
    [self.somewhereElseButton setImage:[UIImage imageNamed:@"magnifying-icon"] forState:UIControlStateSelected];
    self.somewhereElseButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 1, 12);
    
    for (BIMCategoryButton *btn in self.categoryBtns) {
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(BIMCategoryButton *btn_) {
            [self displayOkBtnWithAnimation:YES];
            
            NSArray *array = [USER_DEFAULT objectForKey:kCategoryChoice];
            NSNumber *index = @(btn_.tag - kTagCategory);
            if (array == nil) {
                btn_.selected = YES;
                [USER_DEFAULT setObject:[NSArray arrayWithObject:index] forKey:kCategoryChoice];
                [USER_DEFAULT synchronize];
            } else {
                NSMutableArray *tempArray = [array mutableCopy];
                if ([tempArray containsObject:index]) {
                    btn_.selected = NO;
                    [tempArray removeObject:index];
                } else {
                    btn_.selected = YES;
                    [tempArray addObject:index];
                }
                [USER_DEFAULT setObject:tempArray.copy forKey:kCategoryChoice];
                [USER_DEFAULT synchronize];
            }
            [self initializeCategories];
        }];
    }
    for (BIMEuroButton *btn in self.euroBtns) {
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(BIMEuroButton *btn_) {
            [self displayOkBtnWithAnimation:YES];
            
            NSArray *array = [USER_DEFAULT objectForKey:kEuroChoice];
            NSNumber *index = @(btn_.tag - kTagEuro);
            if (array == nil) {
                btn_.selected = YES;
                [USER_DEFAULT setObject:[NSArray arrayWithObject:index] forKey:kEuroChoice];
                [USER_DEFAULT synchronize];
            } else {
                NSMutableArray *tempArray = [array mutableCopy];
                if ([tempArray containsObject:index]) {
                    btn_.selected = NO;
                    [tempArray removeObject:index];
                } else {
                    btn_.selected = YES;
                    [tempArray addObject:index];
                }
                [USER_DEFAULT setObject:tempArray.copy forKey:kEuroChoice];
                [USER_DEFAULT synchronize];
            }
            [self initializeEuros];
        }];
    }
    
    [[self.okBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self goToHomeVC];
    }];
    
    @weakify(self)
    [[RACObserve(self.somewhereElseButton, selected) filter:^BOOL(id value) {
        @strongify(self)
        return (self->_firstTime == NO);
    }] subscribeNext:^(NSNumber *selected_) {
        @strongify(self)
        if ([selected_ boolValue]) {
            NSData *googlePlaceData = [USER_DEFAULT objectForKey:kModeLocation];
            BIMGooglePlace *googlePlace = [NSKeyedUnarchiver unarchiveObjectWithData:googlePlaceData];
            if (googlePlace && [googlePlace isKindOfClass:[BIMGooglePlace class]]) {
                self.aroundMeButton.selected = NO;
                [self.categoryDelegate resetPlaces];
                [self.categoryDelegate geolocChanged:[googlePlace getLocation]];
            } else {
                [self disableSomeWhereElse];
            }
        } else {
            [self disableSomeWhereElse];
        }
    }];

    [[RACObserve(self.aroundMeButton, selected) filter:^BOOL(id value) {
        @strongify(self)
        return (self->_firstTime == NO);
    }] subscribeNext:^(NSNumber *selected_) {
        @strongify(self)
        if ([selected_ boolValue]) {
            self.somewhereElseButton.selected = NO;
            [USER_DEFAULT setObject:@(YES) forKey:kModeLocation];
        } else {
            [self disableAroundMe];
            //Doesn't need to stop the locationManager because we only use one time location request
        }
        [USER_DEFAULT synchronize];
    }];
    
    [[[[self.aroundMeButton rac_signalForControlEvents:UIControlEventTouchUpInside] filter:^BOOL(BIMBottomButtonWithLoader *btn_) {
        if (btn_.selected) {
            return NO;
        }
        return YES;
    }] flattenMap:^RACStream *(BIMBottomButtonWithLoader *btn_) {
        [btn_ startLoader];
        [self.categoryDelegate resetPlaces];
        return [self locationSignal];
    }] subscribeNext:^(CLLocation *location) {
        self.aroundMeButton.selected = YES;
        [self.aroundMeButton stopLoader];
        [self.categoryDelegate geolocChanged:location];

        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel.people set:@"Around me" to:@"Location Selected"];
    } error:^(NSError *error) {
        [self.aroundMeButton stopLoader];
        self.aroundMeButton.selected = NO;
        [self.categoryDelegate geolocChanged:nil];

        [error displayAlert];
    }];

    [[self.somewhereElseButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(BIMBottomButton *btn_) {
        @strongify(self)
        [self performSegueWithIdentifier:kSegueIdentifierSomeWhereElse sender:nil];
    }];
    
    [self setupConstraints];    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifierSomeWhereElse]) {
        BIMSearchLocationViewController *searchLocationVC = (BIMSearchLocationViewController *)[segue.destinationViewController topViewController];
        NSData *googlePlaceData = [USER_DEFAULT objectForKey:kModeLocation];
        if ([googlePlaceData isKindOfClass:[NSData class]]) {
            BIMGooglePlace *googlePlace = [NSKeyedUnarchiver unarchiveObjectWithData:googlePlaceData];
            if (googlePlace && [googlePlace isKindOfClass:[BIMGooglePlace class]]) {
                searchLocationVC.googlePlace = googlePlace;
            }
        }
    }
}

- (void)setupConstraints {
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone55inch:
            self.widthEuroBtn.constant += 24;
            self.topCategoryBtn.constant += 5;
            self.centerXEuroBtn.constant = -round((self.widthEuroBtn.constant + 10) / 2) + 1;
            self.heightCategoryBtn.constant += 22;
            break;
        case iPhone47inch:
            self.logoIV.image = [UIImage imageNamed:@"white-logo-small-iPhone6"];
            self.widthEuroBtn.constant += 16;
            self.topCategoryBtn.constant += 10;
            self.centerXEuroBtn.constant = -round((self.widthEuroBtn.constant + 10) / 2) + 1;
            self.heightCategoryBtn.constant += 15;
            break;
        case iPhone35inch:
            self.logoIV.hidden = YES;
            self.okBtn.hidden = YES;
            if (IOS8) {
                self.topCategoryBtn.constant = -83;
            } else {
                self.topCategoryBtn.constant = -91;
            }
            break;
        default:
            break;
    }
}

- (RACSignal *)locationSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[MMPReactiveCoreLocation instance]
           singleLocationSignalWithAccuracy:kCLLocationAccuracyHundredMeters timeout:15.0]
          deliverOn:[RACScheduler mainThreadScheduler]]
         subscribeNext:^(CLLocation *location) {
             [subscriber sendNext:location];
             [subscriber sendCompleted];
         }
         error:^(NSError *error) {
            NSError *errorBIM = [error getFormartedErrorForRACSignalLocationError];
             [subscriber sendError:errorBIM];
         }];
        return nil;
    }];
}

- (void)refreshLocation {
    self.somewhereElseButton.selected = YES;
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people set:@"Somewhere else" to:@"Location Selected"];
}

#pragma mark -
#pragma mark - Internal methods

- (void)initializeModeLocation {
    id value = [USER_DEFAULT objectForKey:kModeLocation];
    if (value && [value isKindOfClass:[NSData class]]) {
        self.somewhereElseButton.selected = YES;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        //Simulate a click to fire the location signal
        [self.aroundMeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        self.somewhereElseButton.selected = NO;
        self.aroundMeButton.selected = NO;
        [self.categoryDelegate geolocChanged:nil];
    }
}

- (void)initializeCategories {
    [self.categoryBtns setValue:@(NO) forKey:@"selected"];
    
    id value = [USER_DEFAULT objectForKey:kCategoryChoice];
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *indexes = value;
        for (NSNumber *index in indexes) {
            [self.categoryBtns[index.integerValue - 1] setSelected:YES];
        }
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel.people set:[value componentsJoinedByString:@", "] to:@"Categories selected"];
    } else {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel.people set:@"" to:@"Categories selected"];
    }
    [self.categoryDelegate resetPlaces];
    [self.categoryDelegate filterCategoriesChanged:value];
}

- (void)initializeEuros {
    [self.euroBtns setValue:@(NO) forKey:@"selected"];
    
    id value = [USER_DEFAULT objectForKey:kEuroChoice];
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *indexes = value;
        for (NSNumber *index in indexes) {
            [self.euroBtns[index.integerValue - 1] setSelected:YES];
        }
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel.people set:[value componentsJoinedByString:@", "] to:@"Euros selected"];
    } else {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel.people set:@"" to:@"Euros selected"];
    }
    [self.categoryDelegate resetPlaces];
    [self.categoryDelegate filterEurosChanged:value];
}

- (void)disableSomeWhereElse {
    [self.somewhereElseButton setSKYTitle:SKYTrad(@"menu.somewhere.else")];

    id value = [USER_DEFAULT objectForKey:kModeLocation];
    if (value && [value isKindOfClass:[NSData class]]) {
        [USER_DEFAULT removeObjectForKey:kModeLocation];
        [USER_DEFAULT synchronize];
    }
}

- (void)disableAroundMe {
    id value = [USER_DEFAULT objectForKey:kModeLocation];
    if ([value isKindOfClass:[NSNumber class]]) {
        [USER_DEFAULT removeObjectForKey:kModeLocation];
        [USER_DEFAULT synchronize];
    }
}

- (void)displayOkBtnWithAnimation:(BOOL)animated {
    if ([SDiPhoneVersion deviceSize] == iPhone35inch ||
        self.okBtn.hidden == NO) {
        return;
    }
    if (animated == NO) {
        self.okBtn.hidden = NO;
        self.logoIV.hidden = YES;
        return;
    }
    [self crossAnimationBetween:self.logoIV and:self.okBtn];
}

- (void)displayLogoIVWithAnimation:(BOOL)animated {
    if (self.logoIV.hidden == NO) {
        return;
    }
    if (animated == NO) {
        self.okBtn.hidden = YES;
        self.logoIV.hidden = NO;
        return;
    }
    [self crossAnimationBetween:self.okBtn and:self.logoIV];
}

- (void)crossAnimationBetween:(UIView *)viewToHide and:(UIView *)viewToDisplay {
    viewToDisplay.alpha = 0;
    viewToDisplay.hidden = NO;
    POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnim.toValue = @(1);
    [viewToDisplay pop_addAnimation:alphaAnim forKey:@"alpha"];
    
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(.5, .5)];
    scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    [viewToDisplay.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
    
    alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnim.toValue = @(0);
    [viewToHide pop_addAnimation:alphaAnim forKey:@"alpha"];
    
    scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    [viewToHide.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
    [scaleAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        viewToHide.hidden = YES;
        viewToHide.alpha = 1;
        viewToHide.layer.transform = CATransform3DIdentity;
    }];
}

#pragma mark -
#pragma mark - BIMSliderViewControllerProtocol

- (void)activeAfterScrolling {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Viewed Categories Page"];
}

- (void)resetVCAfterScrolling {
    self.okBtn.hidden = YES;
    if ([SDiPhoneVersion deviceSize] != iPhone35inch) {
        [self displayLogoIVWithAnimation:YES];
    }
}

- (void)goToHomeVC {
    BIMMainContainerViewController *mainVC = (BIMMainContainerViewController *)self.parentViewController;
    [mainVC setCurrentPage:1 withAnimation:YES];
    
    [self displayLogoIVWithAnimation:YES];
}

@end
