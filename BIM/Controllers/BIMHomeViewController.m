//
//  BIMHomeViewController.m
//  Bim
//
//  Created by Alexis Jacquelin on 02/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMHomeViewController.h"
#import "BIMChoosePlaceView.h"
#import "MDCSwipeToChooseViewOptions.h"
#import "MDCPanState.h"
#import "MDCSwipeToChooseDelegate.h"
#import "BIMInfluencerScrollView.h"
#import "BIMPlaceInformations.h"
#import "BIMDetailsPlaceViewController.h"
#import "BIMAnimatorDetailsPush.h"
#import "BIMAPIClient+Places.h"
#import "UIView+MDCSwipeToChoose.h"
#import "BIMCategoriesViewController.h"

#define MIN_PLACES 15
#define PER_PLACES 30

#define MILES_PLACES 25000

static CGFloat const BiMMinScale = .97;

static NSString * const kSegueDetailsPlace = @"details place";

NSString * const BIMAlreadyBimed = @"BIMAlreadyBimed";
NSString * const BIMAlreadyBashed = @"BIMAlreadyBashed";
NSString * const BIMAlreadyDidNext = @"BIMAlreadyDidNext";

@interface BIMHomeViewController() <MDCSwipeToChooseDelegate, BIMHomeDelegate, BIMPlaceInformationDelegate, UIAlertViewDelegate> {
    BOOL _wsIsRunning;
    BOOL _ignorePlace;
}

@property (nonatomic, strong) UIImageView *bgIV;
@property (nonatomic, strong) NSMutableArray *placesDataSource;
@property (nonatomic, strong) NSMutableArray *enqueuedPlaces;

@property (nonatomic, weak) BIMPlace *currentPlace;

@property (nonatomic, strong) NSLayoutConstraint *constraintTopInfosPlace;
@property (nonatomic, strong) NSLayoutConstraint *okBtnTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *nokBtnTopConstraint;

@property (nonatomic, strong) RACSignal *categoriesSignal;

@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, weak) RACDisposable *placesSubscriber;

@end

@implementation BIMHomeViewController

#pragma mark -
#pragma mark - Lazy Loading

- (NSMutableArray *)placesDataSource {
    if (_placesDataSource == nil) {
        _placesDataSource = [NSMutableArray new];
    }
    return _placesDataSource;
}

- (NSMutableArray *)enqueuedPlaces {
    if (_enqueuedPlaces == nil) {
        _enqueuedPlaces = [NSMutableArray new];
    }
    return _enqueuedPlaces;
}

- (CGFloat)informationPlaceTopPadding {
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone55inch:
            return 44.f;
            break;
        case iPhone47inch:
            return 37.f;
            break;
        default:
            return 35.f;
            break;
    }
}

- (CGFloat)okBtnTopPadding {
    CGFloat padding;
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone55inch:
            padding = 429.f;
            break;
        case iPhone47inch:
            padding = 395.f;
            break;
        case iPhone35inch:
            padding = 217.f;
            break;
        default:
            padding = 303.f;
            break;
    }
    if (HAS_IN_CALL_STATUS_BAR) {
        padding -= HEIGHT_STATUS_BAR;
    }
    return padding;
}

- (CGFloat)cardPlaceBottomPadding {
    CGFloat padding;
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone55inch:
            padding = 257.f;
            break;
        case iPhone47inch:
            padding = 233.f;
            break;
        default:
            padding = 224.f;
            break;
    }
    return padding;
}

- (CGFloat)okBtnTrailing {
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone55inch:
            return -90.f;
            break;
        case iPhone47inch:
            return -93.f;
            break;
        default:
            return -70.f;
            break;
    }
}

- (CGFloat)nOkBtnLeading {
    return fabsf([self okBtnTrailing]);
}

#pragma mark -
#pragma mark - Notif

- (void)statusBarFrameChanged:(NSNotification *)notification {
    self.okBtnTopConstraint.constant = [self okBtnTopPadding];
    self.nokBtnTopConstraint.constant = [self okBtnTopPadding];
    
    CGFloat heightFront = self.frontCardView.imageView.height;
    CGFloat heightBack = self.backCardView.imageView.height;

    CGFloat offsetTopInfosPlace = (self.view.height - [self cardPlaceBottomPadding] + [self informationPlaceTopPadding]);

    if (HAS_IN_CALL_STATUS_BAR) {
        heightFront -= HEIGHT_STATUS_BAR;
        heightBack -= HEIGHT_STATUS_BAR;
        offsetTopInfosPlace -= HEIGHT_STATUS_BAR;
    } else {
        heightFront += HEIGHT_STATUS_BAR;
        heightBack += HEIGHT_STATUS_BAR;
        offsetTopInfosPlace += HEIGHT_STATUS_BAR;
    }
    
    [UIView animateWithDuration:.2 animations:^{
        self.frontCardView.imageView.height = heightFront;
        self.backCardView.imageView.height = heightBack;
    }];
    
    self.constraintTopInfosPlace.constant = offsetTopInfosPlace;
}

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    [super customize];
 
    [NOTIFICATION_CENTER addObserver:self selector:@selector(statusBarFrameChanged:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];

    @weakify(self);
    [[RACObserve(self, influencerScrollView) filter:^BOOL(BIMInfluencerScrollView *influencerScrollView_) {
        return influencerScrollView_ ? YES : NO;
    }] subscribeNext:^(BIMInfluencerScrollView *influencerScrollView_) {
        @strongify(self);
        if (self.backCardView) {
            [self.view insertSubview:self.influencerScrollView belowSubview:self.backCardView];
        } else {
            [self.view addSubview:self.influencerScrollView];
        }
        
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
        self.informationPlace.delegatePlaceInfos = self;
        self.informationPlace.place = self.currentPlace;
        [self.informationPlace removeConstraints:self.informationPlace.constraints];
        
        if (self.backCardView) {
            [self.view insertSubview:self.informationPlace belowSubview:self.backCardView];
        } else {
            [self.view addSubview:self.informationPlace];
        }
        
        self.constraintTopInfosPlace =  [self.informationPlace autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:(self.view.height - [self cardPlaceBottomPadding] + [self informationPlaceTopPadding])];
        [self.informationPlace autoSetDimension:ALDimensionHeight toSize:[self.informationPlace getPlaceInformationsHeight]];
        [self.informationPlace autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.view];
        [self.informationPlace autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.view];
    }];
    
    [RACObserve(self, currentPlace) subscribeNext:^(BIMPlace *place_ ) {
        @strongify(self);
        self.informationPlace.location = self.lastLocation;
        [self.informationPlace setPlace:place_];
        [self.influencerScrollView setPlace:place_];
    }];

    [self addBGIV];
    [self addNoPlaceHolderLabel];
    [self addLoaderOnView:self.view];

    self.informationPlace = [[[NSBundle mainBundle] loadNibNamed:@"BIMPlaceInformations" owner:self options:nil] firstObject];
    self.influencerScrollView = [[BIMInfluencerScrollView alloc] initWithPlace:self.currentPlace];
    [self addOkBtn];
    [self addNOkBtn];
    [self addTapGesture];

    [[self rac_signalForSelector:@selector(resetPlaces) fromProtocol:@protocol(BIMCategoryDelegate)] subscribeNext:^(id x) {
        if (self.frontCardView.superview) {
            [self.frontCardView removeFromSuperview];
            self.frontCardView = nil;
            self.currentPlace = nil;
        }
        if (self.backCardView.superview) {
            [self.backCardView removeFromSuperview];
            self.backCardView = nil;
        }
        self.placesDataSource = nil;
        [self displayViews:NO];
        [self startLoader];
    }];
    
    RACSignal *filterEurosSignal = [[self rac_signalForSelector:@selector(filterEurosChanged:) fromProtocol:@protocol(BIMCategoryDelegate)] map:^id(NSArray *euros_) {
        if (euros_ && euros_.count > 0) {
            return euros_;
        } else {
            return nil;
        }
    }];
    
    RACSignal *filterCategoriesSignal = [[self rac_signalForSelector:@selector(filterCategoriesChanged:) fromProtocol:@protocol(BIMCategoryDelegate)] map:^id(NSArray *categories_) {
        if (categories_ && categories_.count > 0) {
            return categories_;
        } else {
            return nil;
        }
    }];

    RACSignal *geolocSignal = [[self rac_signalForSelector:@selector(geolocChanged:) fromProtocol:@protocol(BIMCategoryDelegate)] map:^id(CLLocation *location) {
        return location;
    }];

    RACSignal *launchWSSignal = [self rac_signalForSelector:@selector(launchWS)];
    
    self.categoriesSignal = [RACSignal combineLatest:@[filterEurosSignal, filterCategoriesSignal, geolocSignal, launchWSSignal]];
    
    [self initializePlaceSignal];

    [self displayViews:NO];
    [self launchWS];
}

- (void)reachabilityChanged {
    [self observePlacesDataSource];
}

- (void)launchWS {
    //Used to call the ws on a tap gesture or when there is < MIN_PLACES on the datasource
}

- (void)observePlacesDataSource {
    if (self.placesDataSource.count < MIN_PLACES) {
        [self launchWS];
    }
}

- (void)panGestureOnWithState:(MDCPanState *)state {
    [self.view removeGestureRecognizer:self.tapGesture];
    self.tapGesture = nil;
    if (_ignorePlace) {
        self.frontCardView.nopeView.hidden = YES;
    } else {
        self.frontCardView.nopeView.hidden = NO;
    }
    [UIView animateWithDuration:.2 animations:^{
        [self.okBtn setAlpha:0];
        [self.nokBtn setAlpha:0];
    }];
    CGFloat scale = BiMMinScale + ((1 - BiMMinScale) * state.thresholdRatio);
    self.backCardView.layer.transform = CATransform3DMakeScale(scale, scale, 1);
}

- (void)panGestureOff {
    [self addTapGesture];
    [UIView animateWithDuration:.2 animations:^{
        [self.okBtn setAlpha:1];
        [self.nokBtn setAlpha:1];
    }];
}

- (void)initializePlaceSignal {
    @weakify(self);
    [self.categoriesSignal subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        [self.placesSubscriber dispose];
        self->_wsIsRunning = YES;
        
        if (self.placesDataSource.count == 0 &&
            !self.frontCardView.superview &&
            !self.backCardView.superview) {
            [self displayViews:NO];
            [self startLoader];
        }
        [self.view layoutIfNeeded];
        
        //Shift the per by the enqueuedPlaces and the places currently displayed
        NSUInteger perPlaces = PER_PLACES;
        if (self.frontCardView.superview) {
            perPlaces++;
        }
        if (self.backCardView.superview) {
            perPlaces++;
        }
        
        NSMutableDictionary *params = @{
                                        @"page" : @1,
                                        @"per" : @(perPlaces),
                                        @"radius" : @(MILES_PLACES)
                                        }.mutableCopy;
        @try {
            if ([tuple.first first]) {
                NSArray *array = [tuple.first first];
                if (array.count > 0) {
                    params[@"price_tiers"] = [tuple.first first];
                }
            }
            if ([tuple.second first]) {
                NSArray *array = [tuple.second first];
                if (array.count > 0) {
                    params[@"category_ids"] = [tuple.second first];
                }
            }
            if ([tuple.third first]) {
                CLLocation *location = [tuple.third first];
                params[@"latitude"] = @(location.coordinate.latitude);
                params[@"longitude"] = @(location.coordinate.longitude);
                if ([[USER_DEFAULT objectForKey:kModeLocation] isKindOfClass:[NSNumber class]]) {
                    self.lastLocation = location; //around me
                } else {
                    self.lastLocation = nil;
                }
            } else {
                //Error
                SKYLog(@"LOCATION IS EMPTY");
                self->_wsIsRunning = NO;
                [self stopLoader];
                NSError *locationError = [NSError getLocationErrorEmpty];
                [self displayNoPlaceHolderIfNecessary:locationError];
                self.lastLocation = nil;
                return;
            }
        }
        @catch (NSException *exception) {
            SKYLog(@"ERROR ON CALLING WS GET PLACES %@", exception.userInfo);
            self->_wsIsRunning = NO;
            [self stopLoader];
            NSError *parsingError =  [NSError getParsingError];
            [self displayNoPlaceHolderIfNecessary:parsingError];
            return;
        }

        //Call WS
        __block NSMutableArray *refreshedPlaces = [NSMutableArray new];
        @weakify(self);
        
        self.placesSubscriber = [[[BIMAPIClient sharedClient] fetchPlacesWithParams:params] subscribeNext:^(BIMPlace *place) {
            [refreshedPlaces addObject:place];
        } error:^(NSError *error) {
            @strongify(self);
            if ([error isAnAuthenticatedError]) {
                [self logout];
            } else {
                self->_wsIsRunning = NO;
                [self stopLoader];
                [self displayNoPlaceHolderIfNecessary:error];
            }
        } completed:^{
            @strongify(self);
            [self stopLoader];

            BOOL hasChanged = NO;
            for (BIMPlace *refreshedPlace in refreshedPlaces) {
                if (![self.placesDataSource containsObject:refreshedPlace] &&
                    ![self.enqueuedPlaces containsObject:refreshedPlace] &&
                    [self placeView:self.frontCardView containPlace:refreshedPlace] &&
                    [self placeView:self.backCardView containPlace:refreshedPlace]) {
                    [self.placesDataSource addObject:refreshedPlace];
                    hasChanged = YES;
                }
            }
            if (hasChanged &&
                self.placesDataSource.count > 0 &&
                (self.frontCardView == nil || self.backCardView == nil)) {
                    [self refreshCards];
            }
            [self displayNoPlaceHolderIfNecessary:nil];
            self->_wsIsRunning = NO;
            self.enqueuedPlaces = nil;
        }];
    } error:^(NSError *error) {
        @strongify(self);
        self->_wsIsRunning = NO;
        [self stopLoader];
        [self displayNoPlaceHolderIfNecessary:error];
        
        if ([error isAnAuthenticatedError]) {
            [self logout];
        }
    }];
}

- (BOOL)placeView:(BIMChoosePlaceView *)placeView containPlace:(BIMPlace *)place {
    return (!placeView.superview || ![placeView.place isEqual:place]);
}

- (void)displayNoPlaceHolderIfNecessary:(NSError *)error {
    if (self.placesDataSource.count == 0 &&
        self.backCardView.superview == nil && self.frontCardView.superview == nil) {
        switch (error.code) {
            case BIMUserLocationErrorEmptyMode:
                self.noPlaceHolderLabel.text = SKYTrad(@"location.mode.empty");
                break;
            case BIMUserLocationErrorAccessForbidden:
            case BIMUserLocationErrorTimeOut:
            case BIMUserLocationErrorGeneric:
                self.noPlaceHolderLabel.text = SKYTrad(@"location.permission.denied");
                break;
            case BIMClientErrorJSONParsingFailed:
                self.noPlaceHolderLabel.text = SKYTrad(@"error.generic");
                break;
            default:
                self.noPlaceHolderLabel.text = SKYTrad(@"places.placeholder.empty");
                break;
        }
        [self displayNoPlaceHolder];
    }
}

- (void)displayViews:(BOOL)display {
    NSMutableArray *views = @[self.informationPlace, self.influencerScrollView, self.okBtn, self.nokBtn].mutableCopy;
    if (self.frontCardView) {
        [views addObject:self.frontCardView];
    }
    if (self.backCardView) {
        [views addObject:self.backCardView];
    }
    if (display == NO) {
        [views addObject:self.noPlaceHolderLabel];
    }
    if (display == NO) {
        for (UIView *view in views) {
            view.hidden = YES;
        }
    } else {
        if (self.informationPlace.hidden == YES) {
            for (UIView *view in views) {
                view.hidden = NO;
                view.alpha = 0;
                
                CGFloat oldTop = view.top;
                view.top += 60;
                [UIView animateWithDuration:.3 animations:^{
                    view.top = oldTop;
                    view.alpha = 1;
                }];
            }
        }
    }
}

- (void)displayNoPlaceHolder {
    [self displayViews:NO];
    self.noPlaceHolderLabel.hidden = NO;
    self.noPlaceHolderLabel.alpha = 0;
    
    CGFloat oldTop = self.noPlaceHolderLabel.top;
    self.noPlaceHolderLabel.top += 20;
    [UIView animateWithDuration:.3 animations:^{
        self.noPlaceHolderLabel.alpha = 1;
        self.noPlaceHolderLabel.top = oldTop;
    }];
}

#pragma mark -
#pragma mark - Actions

- (void)tapGestureHandle {
    if ([self.loader isAnimating]) {
        return;
    }
    if (self.noPlaceHolderLabel.hidden == YES) {
        if (IOS8) {
            [self performSegueWithIdentifier:kSegueDetailsPlace sender:nil];
        } else {
            BIMDetailsPlaceViewController *detailsPlaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BIMDetailsPlaceViewController"];
            detailsPlaceVC.delegatePlaceInfos = self;
            detailsPlaceVC.place = self.currentPlace;
            detailsPlaceVC.delegateHome = self;
            [self.navigationController pushViewController:detailsPlaceVC animated:YES];
        }
    } else {
        [self launchWS];
    }
}

#pragma mark -
#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueDetailsPlace]) {
        BIMDetailsPlaceViewController *detailsPlaceVC = segue.destinationViewController;
        detailsPlaceVC.delegatePlaceInfos = self;
        detailsPlaceVC.place = self.currentPlace;
        detailsPlaceVC.delegateHome = self;
    }
}

#pragma mark -
#pragma mark - Internal methods

- (void)addBGIV {
    self.bgIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue-background"]];
    [self.view addSubview:self.bgIV];
    [self.bgIV autoCenterInSuperview];
    [self.bgIV autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
    [self.bgIV autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.view];
}

- (void)addNoPlaceHolderLabel {
    self.noPlaceHolderLabel = [UILabel new];
    self.noPlaceHolderLabel.font = [UIFont bim_avenirNextRegularWithSize:15];
    self.noPlaceHolderLabel.text = SKYTrad(@"places.placeholder.empty");
    self.noPlaceHolderLabel.textColor = [UIColor whiteColor];
    self.noPlaceHolderLabel.textAlignment = NSTextAlignmentCenter;
    self.noPlaceHolderLabel.numberOfLines = 2;
    
    [self.view addSubview:self.noPlaceHolderLabel];
    [self.noPlaceHolderLabel autoCenterInSuperview];
    [self.noPlaceHolderLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.view withOffset:10];
    [self.noPlaceHolderLabel autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.view withOffset:-10];
}

- (void)addFrontCard {
    self.frontCardView = [self popPlaceViewWithFrame:[self frontCardViewFrame]];
    if (self.okBtn) {
        [self.view insertSubview:self.frontCardView belowSubview:self.okBtn];
    } else {
        [self.view addSubview:self.frontCardView];
    }
}

- (void)addBackCard {
    self.backCardView = [self popPlaceViewWithFrame:[self backCardViewFrame]];
    self.backCardView.layer.transform = CATransform3DMakeScale(BiMMinScale, BiMMinScale, 1);
    [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
}

- (void)addOkBtn {
    self.okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.okBtn setImage:[UIImage imageNamed:@"bim-btn"] forState:UIControlStateNormal];
    [self.okBtn sizeToFit];
    [self.view addSubview:self.okBtn];
    self.okBtnTopConstraint = [self.okBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:[self okBtnTopPadding]];
    [self.okBtn autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.view withOffset:[self okBtnTrailing]];
    [self.okBtn autoSetDimensionsToSize:self.okBtn.size];
    
    [[self.okBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {

        [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
    }];
}

- (void)addNOkBtn {
    self.nokBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nokBtn setImage:[UIImage imageNamed:@"bash-btn"] forState:UIControlStateNormal];
    [self.nokBtn sizeToFit];
    [self.view addSubview:self.nokBtn];
    self.nokBtnTopConstraint = [self.nokBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:[self okBtnTopPadding]];
    [self.nokBtn autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.view withOffset:[self nOkBtnLeading]];
    [self.nokBtn autoSetDimensionsToSize:self.nokBtn.size];
    
    [[self.nokBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
    }];
}

- (void)addTapGesture {
    if (self.tapGesture == nil) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle)];
        [self.view addGestureRecognizer:self.tapGesture];
    }
}

- (BIMChoosePlaceView *)popPlaceViewWithFrame:(CGRect)frame {
    if ([self.placesDataSource count] == 0) {
        return nil;
    }
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 100.f;
    options.onPan = ^(MDCPanState *state) {
        [self panGestureOnWithState:state];
    };
    BIMPlace *place = [self.placesDataSource first];
    [self.placesDataSource removeObject:place];
    [self observePlacesDataSource];
    
    if (self.currentPlace == nil) {
        self.currentPlace = place;
    }
    BIMChoosePlaceView *placeView = [[BIMChoosePlaceView alloc] initWithFrame:frame
                                                                    andPlace:place
                                                                   withOptions:options];
    return placeView;
}

#pragma mark -
#pragma mark - Action

- (void)bim:(BIMPlace *)place {
    if (_ignorePlace) {
        _ignorePlace = NO;
        return;
    }
    [self.enqueuedPlaces addObject:place];
    [[[BIMAPIClient sharedClient] bim:place] subscribeError:^(NSError *error) {
        SKYLog(@"ErrorBim %@", place);
        [self.enqueuedPlaces removeObject:place];
    } completed:^{
        SKYLog(@"BIM %@", place);
    }];
}

- (void)bash:(BIMPlace *)place {
    if (_ignorePlace) {
        _ignorePlace = NO;
        return;
    }
    [self.enqueuedPlaces addObject:place];
    [[[BIMAPIClient sharedClient] bash:place] subscribeError:^(NSError *error) {
        SKYLog(@"ErrorBash %@", place);
        [self.enqueuedPlaces removeObject:place];
    } completed:^{
        SKYLog(@"BASH %@", place);
    }];
}

#pragma mark -
#pragma mark - MDCSwipeToChooseDelegate

- (void)viewDidCancelSwipe:(UIView *)view {
    [self panGestureOff];
}

- (void)displayAlertViewForDirection:(MDCSwipeDirection)direction {
    UIAlertView *alertView = nil;
    switch (direction) {
        case MDCSwipeDirectionLeft:
            if (_ignorePlace) {
                alertView = [[UIAlertView alloc] initWithTitle:SKYTrad(@"alert.title.next") message:SKYTrad(@"alert.description.next") delegate:self cancelButtonTitle:SKYTrad(@"alert.cancel") otherButtonTitles:SKYTrad(@"alert.ok"), nil];
                [USER_DEFAULT setBool:YES forKey:BIMAlreadyDidNext];
            } else {
                alertView = [[UIAlertView alloc] initWithTitle:SKYTrad(@"alert.title.bash") message:SKYTrad(@"alert.description.bash") delegate:self cancelButtonTitle:SKYTrad(@"alert.cancel") otherButtonTitles:SKYTrad(@"alert.ok"), nil];
                [USER_DEFAULT setBool:YES forKey:BIMAlreadyBashed];
            }
            break;
        case MDCSwipeDirectionRight:
            alertView = [[UIAlertView alloc] initWithTitle:SKYTrad(@"alert.title.bim") message:SKYTrad(@"alert.description.bim") delegate:self cancelButtonTitle:SKYTrad(@"alert.cancel") otherButtonTitles:SKYTrad(@"alert.ok"), nil];
            [USER_DEFAULT setBool:YES forKey:BIMAlreadyBimed];
            break;
        default:
            SKYLog(@"Error direction unknown %d", (int)direction);
            return;
            break;
    }
    [USER_DEFAULT synchronize];
    [alertView show];
    
    /*
     MDCSwipeResult *state = [MDCSwipeResult new];
     state.view = self;
     state.translation = translation;
     state.direction = direction;
     state.onCompletion = ^{
     if ([delegate respondsToSelector:@selector(view:wasChosenWithDirection:)]) {
     [delegate view:self wasChosenWithDirection:direction];
     }
     };
     self.mdc_options.onChosen(state);
     
     */

}

- (BOOL)view:(UIView *)view shouldBeChosenWithDirection:(MDCSwipeDirection)direction {
    switch (direction) {
        case MDCSwipeDirectionLeft:
            if (_ignorePlace) {
                if (![USER_DEFAULT objectForKey:BIMAlreadyDidNext]) {
                    [self displayAlertViewForDirection:direction];
                    return NO;
                }
            } else {
                if (![USER_DEFAULT objectForKey:BIMAlreadyBashed]) {
                    [self displayAlertViewForDirection:direction];
                    return NO;
                }
            }
            break;
        case MDCSwipeDirectionRight:
            if (![USER_DEFAULT objectForKey:BIMAlreadyBimed]) {
                [self displayAlertViewForDirection:direction];
                return NO;
            }
            break;
        default:
            break;
    }
    return YES;
}

- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    [self panGestureOff];
    
    if (direction == MDCSwipeDirectionLeft) {
        [self bash:self.currentPlace];
    } else {
        [self bim:self.currentPlace];
    }
    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    [self refreshCards];
}

- (void)refreshCards {
    if (!self.frontCardView.superview && self.backCardView.superview) { // there is no front card but a backCard
        self.frontCardView = self.backCardView;
        self.frontCardView.layer.transform = CATransform3DIdentity;
        if ((self.backCardView = [self popPlaceViewWithFrame:[self backCardViewFrame]])) {
            // Fade the back card into view.
            self.backCardView.layer.transform = CATransform3DMakeScale(BiMMinScale, BiMMinScale, 1);
            self.backCardView.alpha = 0.f;
            [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.backCardView.alpha = 1.f;
                             } completion:nil];
        }
    } else if (self.frontCardView.superview && !self.backCardView.superview) { // there is a front card but no backcard
            [self addBackCard];
    } else if (!self.frontCardView.superview && !self.backCardView.superview) { //there is nothing
        if (self.placesDataSource.count > 0) {
            //Add with some cool animation
            [self addFrontCard];
            [self addBackCard];
            [self displayViews:YES];
        } else {
            [self displayNoPlaceHolderIfNecessary:nil];
        }
    }
    self.currentPlace = self.frontCardView.place;
}

#pragma mark -
#pragma mark - View Contruction

- (CGRect)frontCardViewFrame {
    return CGRectMake(0,
                      0,
                      CGRectGetWidth(self.view.frame),
                      CGRectGetHeight(self.view.frame) - [self cardPlaceBottomPadding]);
}

- (CGRect)backCardViewFrame {
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}

#pragma mark -
#pragma mark - BIMSliderViewControllerProtocol

- (void)activeAfterScrolling {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Viewed Home Page"];
}

#pragma mark -
#pragma mark - Transitions between controllers

- (void)vcIsPushingWithDuration:(CGFloat)duration withCompletionBlock:(void (^)(void))completionBlock {
    POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnim.duration = duration * .8;
    alphaAnim.toValue = @(0);
    [self.okBtn pop_addAnimation:alphaAnim forKey:@"alpha"];
    
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.duration = duration * .8;
    scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.5, 1.5)];
    [self.okBtn.layer pop_addAnimation:scaleAnimation forKey:@"scale"];

    alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnim.duration = duration * .8;
    alphaAnim.toValue = @(0);
    [self.nokBtn pop_addAnimation:alphaAnim forKey:@"alpha"];
    
    scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.duration = duration * .8;
    scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.5, 1.5)];
    [self.nokBtn.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
    
    self.informationPlace.mode = BIMPlaceModeComplexe;
    [UIView animateWithDuration:duration animations:^{
        self.okBtn.top -= [self offsetHeight];
        self.nokBtn.top -= [self offsetHeight];
        
        self.frontCardView.imageView.height -= [self offsetHeight];
        self.backCardView.imageView.height -= [self offsetHeight];
        
        switch ([SDiPhoneVersion deviceSize]) {
            case iPhone35inch:
                self.informationPlace.top -= [BIMDetailsPlaceViewController offsetInfosPlace];
                self.informationPlace.height += [BIMDetailsPlaceViewController offsetInfosPlace];
                break;
            case iPhone55inch:
                self.informationPlace.top -= [BIMDetailsPlaceViewController offsetInfosPlace];
                self.informationPlace.height += [BIMDetailsPlaceViewController offsetInfosPlace];
                break;
            case iPhone47inch:
                self.informationPlace.top -= [BIMDetailsPlaceViewController offsetInfosPlace];
                self.informationPlace.height += [BIMDetailsPlaceViewController offsetInfosPlace];
                break;
            default:
                self.informationPlace.top -= [BIMDetailsPlaceViewController offsetInfosPlace];
                self.informationPlace.height += [BIMDetailsPlaceViewController offsetInfosPlace];
                break;
        }
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)vcIsPoppedWithDuration:(CGFloat)duration withCompletionBlock:(void (^)(void))completionBlock onContainerView:(UIView *)containerView {
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setImage:[UIImage imageNamed:@"bim-btn"] forState:UIControlStateNormal];
    [okBtn sizeToFit];
    okBtn.frame = CGRectOffset(okBtn.frame, self.view.width + [self okBtnTrailing] - okBtn.width, [self okBtnTopPadding] - [self offsetHeight]);
    okBtn.alpha = 0;
    
    UIButton *nokBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nokBtn setImage:[UIImage imageNamed:@"bash-btn"] forState:UIControlStateNormal];
    [nokBtn sizeToFit];
    nokBtn.frame = CGRectOffset(nokBtn.frame, [self nOkBtnLeading], [self okBtnTopPadding] - [self offsetHeight]);
    nokBtn.alpha = 0;
    
    [containerView addSubview:okBtn];
    [containerView addSubview:nokBtn];
    
    NSArray *views  = @[okBtn, nokBtn];
    for (UIView *view in views) {
        POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnim.duration = duration * .8;
        alphaAnim.fromValue = @(0);
        alphaAnim.toValue = @(1);
        [view pop_addAnimation:alphaAnim forKey:@"alpha"];
        
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.duration = duration * .8;
        scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)];
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        [view.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
        
        [UIView animateWithDuration:duration * .8 animations:^{
            view.top += [self offsetHeight];
        }];
    }
    [UIView animateWithDuration:duration animations:^{
        self.okBtn.top += [self offsetHeight];
        self.nokBtn.top += [self offsetHeight];

        self.frontCardView.imageView.height += [self offsetHeight];
        self.backCardView.imageView.height += [self offsetHeight];
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            [okBtn removeFromSuperview];
            [nokBtn removeFromSuperview];
            self.okBtn.alpha = 1;
            self.okBtn.transform = CGAffineTransformIdentity;
            self.nokBtn.alpha = 1;
            self.nokBtn.transform = CGAffineTransformIdentity;
            
            completionBlock();
        }
    }];
    self.informationPlace.mode = BIMPlaceModeStandard;
}

- (void)setCurrentImageString:(NSString *)imageString {
    self.frontCardView.imageURLString = imageString;
}

- (NSString *)getCurrentImageString {
    return self.frontCardView.imageURLString;
}

#pragma mark -
#pragma mark - BIMHomeDelegate

- (void)prepareToBimCurrentPlaceForVC:(BIMViewController *)vc {
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
    });
}

- (void)prepareToBashCurrentPlaceForVC:(BIMViewController *)vc {
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
    });
}

- (void)prepareToNextCurrentPlaceForVC:(BIMViewController *)vc {
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self getNextPlaceFor:nil];
    });
}

#pragma mark -
#pragma mark - BIMPlaceInformationDelegate

- (void)getNextPlaceFor:(BIMPlaceInformations *)placeInfos {
    _ignorePlace = YES;
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.frontCardView cancelPanGesture];
    } else {
        if ([alertView.title isEqualToString:SKYTrad(@"alert.title.bim")]) {
            [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
        } else if ([alertView.title isEqualToString:SKYTrad(@"alert.title.bash")]) {
            [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
        } else if ([alertView.title isEqualToString:SKYTrad(@"alert.title.next")]) {
            [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
        } else {
            SKYLog(@"Error on AlertView, title unkown %@", alertView.title);
        }
    }
}

@end
