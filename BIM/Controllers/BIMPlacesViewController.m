//
//  BIMPlacesViewController.m
//  BIM
//
//  Created by Alexis Jacquelin on 30/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMPlacesViewController.h"
#import "UISearchBar+RAC.h"
#import "BIMPlaceTableViewCell.h"
#import "BIMPlace.h"
#import "BIMMapView.h"
#import "BIMSettingsViewController.h"
#import "BIMDetailsPlaceViewController.h"
#import "BIMAnimatorPlacesPush.h"
#import "BIMAnimatorPush.h"
#import "BIMAPIClient+Places.h"

static NSString * const kCellIdentifierPlace = @"BIMPlaceTableViewCell";
static NSString * const kSegueIdentifierSettings = @"settings";
static NSString * const kSegueIdentifierPlace = @"place";

static NSUInteger const kCellHeightNormal = 155;
static NSUInteger const kCellHeightBig = 185;

typedef NS_ENUM(NSUInteger, BIMModePlaces) {
    BIMModePlacesMap,
    BIMModePlacesList
};

@interface BIMPlacesViewController () <BIMMapDelegate, UIScrollViewDelegate> {
    NSInteger sizeCell;
}

@property (nonatomic, assign) BIMModePlaces currentMode;

@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong) NSArray *placesSearched;
@property (nonatomic, assign) BOOL searching;

@property (nonatomic, strong) UIButton *mapBtn;
@property (strong, nonatomic) BIMMapView *mapPlaces;

@property (nonatomic, strong) BIMAnimatorPush *animatorMapPush;
@property (nonatomic, strong) BIMAnimatorPlacesPush *animatorPush;

@end

@implementation BIMPlacesViewController

#pragma mark -
#pragma mark - Lazy Loading

- (BIMAnimatorPush *)animatorMapPush {
    if (_animatorMapPush == nil) {
        _animatorMapPush = [BIMAnimatorPush new];
    }
    return _animatorMapPush;
}

- (BIMAnimatorPlacesPush *)animatorPush {
    if (_animatorPush == nil) {
        _animatorPush = [BIMAnimatorPlacesPush new];
    }
    return _animatorPush;
}

- (BIMMapView *)mapPlaces {
    if (_mapPlaces == nil) {
        _mapPlaces = [[BIMMapView alloc] init];
        _mapPlaces.showsUserLocation = YES;
        _mapPlaces.placeDelegate = self;
        _mapPlaces.user = self.user;
        [self.view addSubview:_mapPlaces];
        [_mapPlaces autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.listView];
        [_mapPlaces autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.listView];
        [_mapPlaces autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.listView];
        [_mapPlaces autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.listView];
    }
    return _mapPlaces;
}

#pragma mark -
#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self placesSignal];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    [super customize];

    self.navigationItem.hidesBackButton = YES;
    self.currentMode = BIMModePlacesList;
    [self addLoaderOnView:self.view];
    self.searchBar.placeholder = SKYTrad(@"places.searchbar.placeholder");
    
    [self.tableView registerNib:[UINib nibWithNibName:kCellIdentifierPlace bundle:nil] forCellReuseIdentifier:kCellIdentifierPlace];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [UIView new];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    self.noPlaceHolderLabel.hidden = YES;
    
    sizeCell = kCellHeightNormal;
    
    self.noPlaceHolderLabel.text = SKYTrad(@"places.empty.placeholder");
    self.noPlaceHolderLabel.font = [UIFont bim_avenirNextRegularWithSize:15];
    self.noPlaceHolderLabel.textColor = [UIColor whiteColor];
    
    RAC(self, placesSearched) = [self rac_liftSelector:@selector(search:) withSignals:self.searchBar.rac_textSignal, nil];
    
    RAC(self, searching) = [self.searchBar rac_searchingSignal];
    
    @weakify(self);
    [RACObserve(self, placesSearched) subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    [RACObserve(self, places) subscribeNext:^(id x) {
        @strongify(self);
        if (self.searching) {
            self.placesSearched = [self search:self.searchBar.text];
        } else {
            [self.tableView reloadData];
        }
    }];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Viewed Places Page Mode Liste" properties:@{
                                                        @"id" : self.user.uniqueID
                                                        }];
}

- (void)addCustomItems {
    [self addLeftBtnsItems];
    [self addRightBtnItem];
}

- (void)addLeftBtnsItems {
    UIButton *backBtn = [UIButton bim_getBackBtn];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];

    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -13.f;

    if ([self.user isCurrentUser]) {
        UIButton *settingsBtn = [UIButton bim_getSettingsBtn];
        [settingsBtn setImage:[UIImage imageNamed:@"settings-btn"] forState:UIControlStateNormal];
        settingsBtn.frame = CGRectMake(0, 0, 40, 40);
        [settingsBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
        UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithCustomView:settingsBtn];

        self.navigationItem.leftBarButtonItems = @[spaceItem, backItem, settingsItem];
        
        [[settingsBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn_) {
            if (IOS8) {
                [self performSegueWithIdentifier:kSegueIdentifierSettings sender:nil];
            } else {
                BIMSettingsViewController *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BIMSettingsViewController"];
                [self.navigationController pushViewController:settingsVC animated:YES];
            }
        }];
    } else {
        self.navigationItem.leftBarButtonItems = @[spaceItem, backItem];
    }

    [[backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn_) {
        [self.navigationController popViewControllerAnimated:YES];
        
        if ([self.searchBar isFirstResponder]) {
            [self.searchBar resignFirstResponder];
        }
    }];
}

- (void)displayTitle {
    self.navigationItem.title = [self.user getDescriptionUser];
}

- (void)addRightBtnItem {
    self.mapBtn = [UIButton bim_getMapBtn];
    if (self.currentMode == BIMModePlacesMap) {
        self.mapBtn.selected = YES;
    }
    UIBarButtonItem *mapItem = [[UIBarButtonItem alloc] initWithCustomView:self.mapBtn];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -15.f;
    self.navigationItem.rightBarButtonItems = @[spaceItem, mapItem];
    
    @weakify(self);
    [[self.mapBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn_) {
        @strongify(self);
        btn_.userInteractionEnabled = NO;
        if (btn_.selected) {
            btn_.selected = NO;
            [self displayMode:BIMModePlacesList];
            
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [mixpanel track:@"Viewed Places Page Mode Liste" properties:@{
                                                               @"id" : self.user.uniqueID
                                                               }];
        } else {
            btn_.selected = YES;
            [self displayMode:BIMModePlacesMap];

            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [mixpanel track:@"Viewed Places Page Mode Map" properties:@{
                                                                          @"id" : self.user.uniqueID
                                                                          }];
        }
    }];
}

- (void)displayData {
    if (self.places.count == 0) {
        [self displayNoPlaceHolder];
    } else {
        [self displayTableView];
    }
}

- (void) displayTableView {
    if (self.tableView.hidden == YES) {
        sizeCell = kCellHeightBig;
        self.noPlaceHolderLabel.hidden = YES;
        self.tableView.hidden = NO;
        self.tableView.alpha = 0;
        
        CGFloat oldTop = self.tableView.top;
        self.tableView.top += 60;
        
        [UIView animateWithDuration:.3 animations:^{
            self.tableView.top = oldTop;
            self.tableView.alpha = 1;
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->sizeCell = kCellHeightNormal;
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        });
    } else {
        [self.tableView reloadData];
    }
}

- (void)displayNoPlaceHolder {
    self.tableView.hidden = YES;
    self.noPlaceHolderLabel.hidden = NO;
    self.noPlaceHolderLabel.alpha = 0;
    
    CGFloat oldTop = self.noPlaceHolderLabel.top;
    self.noPlaceHolderLabel.top += 20;
    [UIView animateWithDuration:.3 animations:^{
        self.noPlaceHolderLabel.alpha = 1;
        self.noPlaceHolderLabel.top = oldTop;
    }];
}

- (NSArray *)search:(NSString *)searchText {
    if (searchText.length == 0) {
        return self.places;
    } else {
        NSMutableArray *results = [NSMutableArray new];
        for (BIMPlace *place in self.places) {
            if ([place.getDescriptionPlaceSearched.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound) {
                [results addObject:place];
            }
        }
        return results.copy;
    }
}

- (void)displayMode:(BIMModePlaces)mode {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }

    self.currentMode = mode;
    UIView *fromView = nil;
    UIView *toView = nil;
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionShowHideTransitionViews;
    switch (mode) {
        case BIMModePlacesList:
            fromView = self.mapPlaces;
            toView = self.listView;
        options = UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionShowHideTransitionViews;
            break;
        default:
            fromView = self.listView;
            toView = self.mapPlaces;
            break;
    }
    [UIView transitionFromView:fromView toView:toView duration:.5 options:options completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.mapBtn.userInteractionEnabled = YES;
        });
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifierPlace]) {
        NSParameterAssert([sender isKindOfClass:[BIMPlace class]]);
        BIMDetailsPlaceViewController *detailsPlaceVC = segue.destinationViewController;
        detailsPlaceVC.fromPlacesVC = YES;
        detailsPlaceVC.place = sender;
    }
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BIMPlace *place = nil;
    if (self.searching && self.searchBar.text.length > 0) {
        place = self.placesSearched[indexPath.row];
    } else {
        place = self.places[indexPath.row];
    }
    if (IOS8) {
        [self performSegueWithIdentifier:kSegueIdentifierPlace sender:place];
    } else {
        BIMDetailsPlaceViewController *detailsPlaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BIMDetailsPlaceViewController"];
        detailsPlaceVC.fromPlacesVC = YES;
        detailsPlaceVC.place = place;
        [self.navigationController pushViewController:detailsPlaceVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return sizeCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searching) {
        return [self.placesSearched count];
    } else {
        return [self.places count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BIMPlaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierPlace forIndexPath:indexPath];
    
    if (self.searching) {
        [cell setPlaceObject:self.placesSearched[indexPath.row]];
    } else {
        [cell setPlaceObject:self.places[indexPath.row]];
    }
    return cell;
}

#pragma mark -
#pragma mark - WS

- (void)placesSignal {
    if (self.places.count == 0) {
        self.noPlaceHolderLabel.hidden = YES;
        self.tableView.hidden = YES;
        
        [self startLoader];
    }
    [self.view layoutIfNeeded];

    __block NSMutableArray *refreshedPlaces = [NSMutableArray new];
    @weakify(self);
    [[[BIMAPIClient sharedClient] fetchBimsForUser:self.user] subscribeNext:^(BIMPlace *place) {
        [refreshedPlaces addObject:place];
    } error:^(NSError *error) {
        @strongify(self);
        [self stopLoader];
        [self displayData];
    } completed:^{
        @strongify(self);
        [self stopLoader];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel.people set:@"Places count" to:@(refreshedPlaces.count)];

        self.places = refreshedPlaces;
        [self displayData];
    }];
}

#pragma mark -
#pragma mark - Animations

- (void)showCurrentItemsWithAnimationWithDuration:(CGFloat)duration direction:(BIMDirectionMode)mode {
    UIButton *backBtn = [UIButton bim_getBackBtn];
    UIButton *mapBtn = [UIButton bim_getMapBtn];
    if (self.mapBtn.selected) {
        mapBtn.selected = YES;
    }
    backBtn.alpha = 0;
    mapBtn.alpha = 0;
    
    CGFloat translation = kItemTranslationX;
    if (mode == BIMDirectionModeLeft) {
        translation *= -1;
    }

    if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        [backBtn setFrame:CGRectOffset(backBtn.frame, 7, 2)];
        [mapBtn setFrame:CGRectOffset(mapBtn.frame, WIDTH_DEVICE - 50, -1)];
    } else {
        [backBtn setFrame:CGRectOffset(backBtn.frame, 3, 2)];
        [mapBtn setFrame:CGRectOffset(mapBtn.frame, WIDTH_DEVICE - 46, -1)];
    }
    [self.navigationController.navigationBar addSubview:backBtn];
    [self.navigationController.navigationBar addSubview:mapBtn];
    
    NSArray *array = nil;
    if ([self.user isCurrentUser]) {
        UIButton *settingsBtn = [UIButton bim_getSettingsBtn];
        settingsBtn.alpha = 0;
        if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
            [settingsBtn setFrame:CGRectOffset(settingsBtn.frame, 50, 2)];
        } else {
            [settingsBtn setFrame:CGRectOffset(settingsBtn.frame, 46, 2)];
        }
        [self.navigationController.navigationBar addSubview:settingsBtn];
        
        array = @[backBtn, settingsBtn, mapBtn];
    } else {
        array = @[backBtn, mapBtn];
    }
    for (UIButton *btn in array) {
        POPSpringAnimation *translateAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        translateAnimation.fromValue = [NSValue valueWithCGRect:CGRectOffset(btn.frame, translation, 0)];
        translateAnimation.toValue = [NSValue valueWithCGRect:CGRectOffset(btn.frame, 0, 0)];
        [btn pop_addAnimation:translateAnimation forKey:@"translation"];
        
        POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation.duration = duration;
        alphaAnimation.toValue = @(1);
        [btn pop_addAnimation:alphaAnimation forKey:@"alpha"];
        
        if ([array lastObject] == btn) {
            [alphaAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
                [self addCustomItems];
                for (UIButton *btn in array) {
                    [btn removeFromSuperview];
                }
            }];
        }
    }
}

- (void)hideCurrentItemsWithAnimationWithDuration:(CGFloat)duration direction:(BIMDirectionMode)mode {
    UIButton *backBtn = [UIButton bim_getBackBtn];
    UIButton *mapBtn = [UIButton bim_getMapBtn];
    if (self.mapBtn.selected) {
        mapBtn.selected = YES;
    }

    CGFloat translation = kItemTranslationX;
    if (mode == BIMDirectionModeLeft) {
        translation *= -1;
    }
    
    if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        [backBtn setFrame:CGRectOffset(backBtn.frame, 7, 2)];
        [mapBtn setFrame:CGRectOffset(mapBtn.frame, WIDTH_DEVICE - 50, -1)];
    } else {
        [backBtn setFrame:CGRectOffset(backBtn.frame, 3, 2)];
        [mapBtn setFrame:CGRectOffset(mapBtn.frame, WIDTH_DEVICE - 46, -1)];
    }
    [self.navigationController.navigationBar addSubview:backBtn];
    [self.navigationController.navigationBar addSubview:mapBtn];
    
    //Remove the current
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = nil;

    NSArray *array = nil;
    if ([self.user isCurrentUser]) {
        UIButton *settingsBtn = [UIButton bim_getSettingsBtn];
        if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
            [settingsBtn setFrame:CGRectOffset(settingsBtn.frame, 50, 2)];
        } else {
            [settingsBtn setFrame:CGRectOffset(settingsBtn.frame, 46, 2)];
        }
        [self.navigationController.navigationBar addSubview:settingsBtn];

        array = @[backBtn, settingsBtn, mapBtn];
    } else {
        array = @[backBtn, mapBtn];
    }
    for (UIButton *btn in array) {
        POPSpringAnimation *translateAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        translateAnimation.fromValue = [NSValue valueWithCGRect:CGRectOffset(btn.frame, 0, 0)];
        translateAnimation.toValue = [NSValue valueWithCGRect:CGRectOffset(btn.frame, translation, 0)];
        [btn pop_addAnimation:translateAnimation forKey:@"translation"];
        
        POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation.duration = duration;
        alphaAnimation.toValue = @(0);
        [btn pop_addAnimation:alphaAnimation forKey:@"alpha"];
        
        if ([array lastObject] == btn) {
            [alphaAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
                for (UIButton *btn in array) {
                    [btn removeFromSuperview];
                }
            }];
        }
    }
}

#pragma mark -
#pragma mark - BIMMapDelegate

- (void)displayPlace:(BIMPlace *)place for:(BIMMapView *)mapView {
    if (IOS8) {
        [self performSegueWithIdentifier:kSegueIdentifierPlace sender:place];
    } else {
        BIMDetailsPlaceViewController *detailsPlaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BIMDetailsPlaceViewController"];
        detailsPlaceVC.fromPlacesVC = YES;
        detailsPlaceVC.place = place;
        [self.navigationController pushViewController:detailsPlaceVC animated:YES];
    }
}

#pragma mark -
#pragma mark - Transitions between controllers

- (id<UIViewControllerAnimatedTransitioning>)animatorPushForToVC:(BIMViewController *)toVC {
    switch (self.currentMode) {
        case BIMModePlacesList:
            return self.animatorMapPush;
            return self.animatorPush;
            break;
        case BIMModePlacesMap:
        default:
            return self.animatorMapPush;
            break;
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}

@end
