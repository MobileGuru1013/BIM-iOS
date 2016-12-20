//
//  BIMMainContainerViewController.m
//  BIM
//
//  Created by Alexis Jacquelin on 21/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMMainContainerViewController.h"
#import "BIMCategoriesViewController.h"
#import "BIMHomeViewController.h"
#import "BIMFriendsViewController.h"
#import "BIMCategoriesSliderItem.h"
#import "BIMHomeSliderItem.h"
#import "BIMFriendsSliderItem.h"
#import "BIMLoginViewController.h"
#import "BIMDetailsPlaceViewController.h"
#import "BIMAnimatorDetailsPush.h"

static NSString * const kSegueIdentifierConnect = @"connect";
static CGFloat const kDefaultPage = 1;

@interface BIMMainContainerViewController () <UIScrollViewDelegate> {
    CGPoint _startPos;
    CGFloat _minPosX;
    CGFloat _maxPosX;
    
    CGFloat _topNavBar;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) BIMAnimatorDetailsPush *animatorDetailsPush;

@property (nonatomic, strong) NSMutableArray *arrayOfHeightConstraints;

@end

@implementation BIMMainContainerViewController

#pragma mark -
#pragma mark - Lazy Loading

- (BIMAnimatorDetailsPush *)animatorDetailsPush {
    if (_animatorDetailsPush == nil) {
        _animatorDetailsPush = [BIMAnimatorDetailsPush new];
    }
    return _animatorDetailsPush;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage == currentPage)
        return;
    _currentPage = currentPage;
    self.slidingNavBar.currentPage = currentPage;

    [self resetVCsNotVisible];
}

- (BIMSliderNavBar *)slidingNavBar {
    return (BIMSliderNavBar *)self.navigationController.navigationBar;
}

- (BIMViewController *)currentViewController {
    if (self.currentPage > self.arrayOfViewControllers.count) {
        SKYLog(@"CURRENT PAGE OUT OF BOUNDS");
        return nil;
    } else {
        return self.arrayOfViewControllers[self.currentPage];
    }
}

#pragma mark -
#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.panGesture.enabled = YES;
    if (!IOS8) {
        //iOS7.1 Yeah!
        self.scrollView.delegate = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setCurrentPage:self.currentPage withAnimation:NO];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.panGesture.enabled = NO;

    if (!IOS8) {
        //iOS7.1 Yeah!
        self.scrollView.delegate = nil;
    }
}

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    [super customize];
    
    //force to initialize the first time
    _currentPage = -1;
    _topNavBar = 20;
    [self.slidingNavBar setMainContainer:self];
    [self.scrollView setDelaysContentTouches:NO];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    BIMCategoriesViewController *categoriesVC   = [self.storyboard instantiateViewControllerWithIdentifier:@"BIMCategoriesViewController"];
    BIMHomeViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BIMHomeViewController"];
    categoriesVC.categoryDelegate = homeVC;
    BIMFriendsViewController *friendsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BIMFriendsViewController"];
    
    self.arrayOfViewControllers = @[categoriesVC, homeVC, friendsVC];
    
    [self initScrollViewWithViewControllers:self.arrayOfViewControllers];
    [self initButtonsInNavigationBar];
    [self addPanGestureOnNavBar];
    
    if (IOS8) {
        [self setCurrentPage:kDefaultPage withAnimation:NO];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setCurrentPage:kDefaultPage withAnimation:NO];
        });
    }
    
    //Prevent a bug when the state of the app became backgroud -> foreground.
    //The top of the navBar is reseted
    [NOTIFICATION_CENTER addObserver:self selector:@selector(getTopBarOnForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(setTopBarOnActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(statusBarFrameChanged:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

- (void)resetVCsNotVisible {
    for (BIMViewController <BIMSliderViewControllerProtocol>*vc in self.arrayOfViewControllers) {
        if (self.currentPage == [self.arrayOfViewControllers indexOfObject:vc]) {
            if ([vc respondsToSelector:@selector(activeAfterScrolling)]) {
                [vc performSelector:@selector(activeAfterScrolling) withObject:nil];
            }
        } else {
            if ([vc respondsToSelector:@selector(resetVCAfterScrolling)]) {
                [vc performSelector:@selector(resetVCAfterScrolling) withObject:nil];
            }
        }
    }
}

#pragma mark -
#pragma mark - Notif

- (void)getTopBarOnForeground {
    BIMSliderNavBar *navBar = (BIMSliderNavBar *)[self.navigationController navigationBar];
    _topNavBar = navBar.top;
}

- (void)setTopBarOnActive {
    BIMSliderNavBar *navBar = (BIMSliderNavBar *)[self.navigationController navigationBar];
    navBar.top = _topNavBar;
}

- (void)statusBarFrameChanged:(NSNotification *)notification {
    for (NSLayoutConstraint *constraint in self.arrayOfHeightConstraints) {
        constraint.constant = HEIGHT_DEVICE + HEIGHT_STATUS_BAR;
    }
    self.scrollView.contentSize = CGSizeMake(WIDTH_DEVICE * [self.arrayOfViewControllers count], HEIGHT_DEVICE + HEIGHT_STATUS_BAR);
}

#pragma mark -
#pragma mark - Container

- (void)initScrollViewWithViewControllers:(NSArray *)viewControllers {
    self.arrayOfHeightConstraints = [NSMutableArray new];
    for (int i = 0; i < [viewControllers count]; i++) {
        BIMViewController *vc = viewControllers[i];
        [self.scrollView addSubview:vc.view];
        [vc willMoveToParentViewController:self];
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];

        [vc.view autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.scrollView];
        [vc.view autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.scrollView withOffset:WIDTH_DEVICE * i];
        [vc.view autoSetDimension:ALDimensionWidth toSize:WIDTH_DEVICE];
        [self.arrayOfHeightConstraints addObject:[vc.view autoSetDimension:ALDimensionHeight toSize:HEIGHT_DEVICE + HEIGHT_STATUS_BAR]];
    }
    self.scrollView.contentSize = CGSizeMake(WIDTH_DEVICE * [viewControllers count], HEIGHT_DEVICE + HEIGHT_STATUS_BAR);
}

- (void)initButtonsInNavigationBar {
    BIMCategoriesSliderItem *categoriesItem = [BIMCategoriesSliderItem new];
    BIMHomeSliderItem *homeItem = [BIMHomeSliderItem new];
    BIMFriendsSliderItem *friendsItem = [BIMFriendsSliderItem new];
    self.slidingNavBar.arrayOfItems = @[categoriesItem, homeItem, friendsItem];
}

- (void)addPanGestureOnNavBar {
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerHandle:)];
    self.slidingNavBar.userInteractionEnabled = YES;
    [self.slidingNavBar addGestureRecognizer:self.panGesture];
}

- (void)setCurrentPage:(NSInteger)page withAnimation:(BOOL)animated {
    page = MAX(0, page);
    page = MIN(page, self.arrayOfViewControllers.count - 1);
    [self.scrollView setContentOffset:CGPointMake(page * WIDTH_DEVICE, 0) animated:animated];

    self.currentPage = page;
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentPage = round(scrollView.contentOffset.x / WIDTH_DEVICE);
    self.currentPage = currentPage;

    self.slidingNavBar.contentOffset = scrollView.contentOffset;
}

#pragma mark -
#pragma mark - PanGesture

- (void)panGestureRecognizerHandle:(UIPanGestureRecognizer *)panGestureRecognizer {
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            _minPosX = 0;
            _maxPosX = WIDTH_DEVICE * (self.arrayOfViewControllers.count - 1);
            _startPos = self.scrollView.contentOffset;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translate = [panGestureRecognizer translationInView:panGestureRecognizer.view];
            CGPoint newPos;
            
            newPos = CGPointMake(_startPos.x - translate.x, _startPos.y);
            if (newPos.x < _minPosX) {
                newPos.x = _minPosX;
                translate = CGPointMake(newPos.x - _startPos.x, 0);
            }
            if (newPos.x > _maxPosX) {
                newPos.x = _maxPosX;
                translate = CGPointMake(newPos.x - _startPos.x, 0);
            }
            [panGestureRecognizer setTranslation:translate inView:self.scrollView];
            self.scrollView.contentOffset = newPos;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGPoint vectorVelocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
            CGFloat axisVelocity = vectorVelocity.x;
            int offset_scroll = (int)self.scrollView.contentOffset.x % (int)WIDTH_DEVICE;
            int differential = MAX(WIDTH_DEVICE, offset_scroll) - MIN(offset_scroll, WIDTH_DEVICE);
            
            NSInteger currentPage = round(_startPos.x / WIDTH_DEVICE);
            if (axisVelocity > 0) {
                //go to left ?
                if (differential > 20 && offset_scroll != 0) {
                    [self setCurrentPage:(currentPage - 1) withAnimation:YES];
                    break;
                }
            } else if (axisVelocity) {
                //go to rigth ?
                if (differential > 20 && offset_scroll != 0) {
                    [self setCurrentPage:(currentPage + 1) withAnimation:YES];
                    break;                }
            }
            [self setCurrentPage:currentPage withAnimation:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark - Transitions between controllers

- (id <UIViewControllerAnimatedTransitioning>)animatorPushForToVC:(BIMViewController *)toVC {
    if ([toVC isKindOfClass:[BIMDetailsPlaceViewController class]]) {
        return self.animatorDetailsPush;
    } else {
        return [super animatorPushForToVC:toVC];
    }
}

- (void)vcIsPushingWithDuration:(CGFloat)duration withCompletionBlock:(void (^)(void))completionBlock {
    BIMSliderNavBar *navBar = (BIMSliderNavBar *)[self.navigationController navigationBar];
    [UIView animateWithDuration:duration delay:0 options:0 animations:^{
        navBar.top = -60;
    } completion:^(BOOL finished) {
        navBar.hidden = YES;
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)vcIsPoppedWithDuration:(CGFloat)duration withCompletionBlock:(void (^)(void))completionBlock {
    BIMSliderNavBar *navBar = (BIMSliderNavBar *)[self.navigationController navigationBar];
    navBar.hidden = NO;
    [UIView animateWithDuration:duration * .8 delay:0 options:0 animations:^{
        navBar.top = 20;
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[SDImageCache sharedImageCache] clearMemory];
}

@end
    
