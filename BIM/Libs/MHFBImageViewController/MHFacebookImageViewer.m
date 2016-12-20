//
// MHFacebookImageViewer.m
// Version 2.0
//
// Copyright (c) 2013 Michael Henry Pantaleon (http://www.iamkel.net). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "MHFacebookImageViewer.h"
#import <SDWebImage/UIImageView+WebCache.h>


static const CGFloat kMinBlackMaskAlpha = 0.3f;
static const CGFloat kMaxImageScale = 2.5f;
static const CGFloat kMinImageScale = 1.0f;
static NSString * const cellID = @"mhfacebookImageViewerCell";


@interface MHFacebookImageViewer() <UIGestureRecognizerDelegate,UICollectionViewDataSource, UICollectionViewDelegate> {
    NSMutableArray *_gestures;
    UICollectionView * _collectionView;
    UIView *_blackMask;
    UIImageView * _imageView;
    UIView * _superView;
    CGPoint _panOrigin;
    CGRect _originalFrameRelativeToScreen;
    BOOL _isAnimating;
    BOOL _isDoneAnimating;
    UIStatusBarStyle _statusBarStyle;
}

@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, strong) UIImageView *renderedContentImageView;
@property (nonatomic, strong) UIView *contentDimmingView;

@end


@interface MHFacebookImageViewerCell : UICollectionViewCell <UIGestureRecognizerDelegate,UIScrollViewDelegate> {
    UIImageView * __imageView;
    UIScrollView * __scrollView;
    NSMutableArray *_gestures;
    CGPoint _panOrigin;
    BOOL _isAnimating;
    BOOL _isDoneAnimating;
    BOOL _isLoaded;
}

@property(nonatomic,assign) CGRect originalFrameRelativeToScreen;
@property(nonatomic,weak) UIViewController * rootViewController;
@property(nonatomic,weak) MHFacebookImageViewer * viewController;
@property(nonatomic,weak) UIView * blackMask;
@property(nonatomic,weak) UIButton * doneButton;
@property(nonatomic,weak) UIImageView * senderView;
@property(nonatomic,assign) NSInteger imageIndex;
@property(nonatomic,weak) UIImage * defaultImage;
@property(nonatomic,assign) NSInteger initialIndex;
@property (nonatomic,weak) MHFacebookImageViewerOpeningBlock openingBlock;
@property (nonatomic,weak) MHFacebookImageViewerClosingBlock closingBlock;
@property(nonatomic,weak) UIView * superView;
@property(nonatomic) UIStatusBarStyle statusBarStyle;

@end


@implementation MHFacebookImageViewerCell

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadAllRequiredViews];
    }
    return self;
}

- (void)loadAllRequiredViews {
    CGRect frame = self.bounds;
    __scrollView = [[UIScrollView alloc]initWithFrame:frame];
    __scrollView.delegate = self;
    __scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:__scrollView];
    [_doneButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Loading and presentation

- (void)setImageURL:(NSURL *)imageURL defaultImage:(UIImage*)defaultImage imageIndex:(NSInteger)imageIndex {
    _imageIndex = imageIndex;
    _defaultImage = defaultImage;

    dispatch_async(dispatch_get_main_queue(), ^{
        self->_senderView.alpha = 0.0f;
        if(!self->__imageView){
            self->__imageView = [[UIImageView alloc]init];
            [self->__scrollView addSubview:self->__imageView];
            self->__imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
        __block UIImageView * _imageViewInTheBlock = self->__imageView;
        __block MHFacebookImageViewerCell * _justMeInsideTheBlock = self;
        __block UIScrollView * _scrollViewInsideBlock = self->__scrollView;

        [self->__imageView sd_setImageWithURL:imageURL placeholderImage:defaultImage options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                NSLog(@"Image From URL Not loaded. Error: %@", error);
                return;
            }
            [_scrollViewInsideBlock setZoomScale:1.0f animated:YES];
            [_imageViewInTheBlock setImage:image];
            _imageViewInTheBlock.frame = [_justMeInsideTheBlock centerFrameFromImage:_imageViewInTheBlock.image];
        }];

        if(self->_imageIndex == self->_initialIndex && !self->_isLoaded){
            self->__imageView.frame = self->_originalFrameRelativeToScreen;
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:0 animations:^{
                self->__imageView.frame = [self centerFrameFromImage:self->__imageView.image];
                // Move content backward
                _justMeInsideTheBlock.viewController.renderedContentImageView.transform = CGAffineTransformMakeScale(0.95f, 0.95f);
                self->_blackMask.alpha = 1;
            }   completion:^(BOOL finished) {
                if (finished) {
                    self->_isAnimating = NO;
                    self->_isLoaded = YES;
                    if(self->_openingBlock)
                        self->_openingBlock();
                }
            }];

            dispatch_async(dispatch_get_main_queue(), ^{
                self->_viewController.prefersStatusBarHidden = YES;
                [UIView animateWithDuration:0.3 animations:^{
                    [self->_viewController setNeedsStatusBarAppearanceUpdate];
                }];
            });
        }
        self->__imageView.userInteractionEnabled = YES;
        [self addPanGestureToView:self->__imageView];
        [self addMultipleGesture];

    });
}

#pragma mark - Add Pan Gesture

- (void)addPanGestureToView:(UIView*)view {
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerDidPan:)];
    panGesture.cancelsTouchesInView = YES;
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];
    [_gestures addObject:panGesture];
    panGesture = nil;
}

# pragma mark - Avoid Unwanted Horizontal Gesture

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:__scrollView];
    return fabs(translation.y) > fabs(translation.x) ;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    _panOrigin = __imageView.frame.origin;
    gestureRecognizer.enabled = YES;
    return !_isAnimating;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    Class panClass = [UIPanGestureRecognizer class];
    if (gestureRecognizer.view == __imageView && [gestureRecognizer isKindOfClass:panClass] &&
        [otherGestureRecognizer isKindOfClass:panClass] && [otherGestureRecognizer.view isKindOfClass:[UICollectionView class]]) {
        return NO;
    }

    return YES;
}

#pragma mark - Handle Panning Activity

- (void) gestureRecognizerDidPan:(UIPanGestureRecognizer*)panGesture {
    if(__scrollView.zoomScale != 1.0f || _isAnimating)return;
    if(_imageIndex==_initialIndex){
        if(_senderView.alpha!=0.0f)
            _senderView.alpha = 0.0f;
    }else {
        if(_senderView.alpha!=1.0f)
            _senderView.alpha = 1.0f;
    }
    // Hide the Done Button
    [self hideDoneButton];
    __scrollView.bounces = NO;
    CGSize windowSize = _blackMask.bounds.size;
    CGPoint currentPoint = [panGesture translationInView:__scrollView];
    CGFloat y = currentPoint.y + _panOrigin.y;
    CGRect frame = __imageView.frame;
    frame.origin = CGPointMake(0, y);
    __imageView.frame = frame;
    CGFloat yDiff = abs((y + __imageView.frame.size.height/2) - windowSize.height/2);
    _blackMask.alpha = MAX(1 - yDiff/(windowSize.height/2),kMinBlackMaskAlpha);

    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.33 animations:^{
            self->_viewController.prefersStatusBarHidden = NO;
            [self->_viewController setNeedsStatusBarAppearanceUpdate];
        }];
    }

    if ((panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) && __scrollView.zoomScale == 1.0f) {

        if(_blackMask.alpha < 0.7) {
            [self dismissViewController];
        }else {
            [self rollbackViewController];
        }
    }
}

#pragma mark - Just Rollback

- (void)rollbackViewController
{
    _isAnimating = YES;
    [UIView animateWithDuration:0.2f delay:0.0f options:0 animations:^{
        self->__imageView.frame = [self centerFrameFromImage:self->__imageView.image];
        self->_blackMask.alpha = 1;
        self->_viewController.prefersStatusBarHidden = YES;
        [self->_viewController setNeedsStatusBarAppearanceUpdate];
    }   completion:^(BOOL finished) {
        if (finished) {
            self->_isAnimating = NO;
        }
    }];
}

#pragma mark - Dismiss

- (void)dismissViewController {
    _isAnimating = YES;
    [self.viewController.imageDatasource willRemoveFacebookViewer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideDoneButton];
        self->__imageView.clipsToBounds = YES;
        CGFloat screenHeight =  [[UIScreen mainScreen] bounds].size.height;
        CGFloat imageYCenterPosition = self->__imageView.frame.origin.y + self->__imageView.frame.size.height/2 ;
        BOOL isGoingUp =  imageYCenterPosition < screenHeight/2;
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:0 animations:^{

            self->__imageView.frame = CGRectMake(self->__imageView.frame.origin.x, isGoingUp?-screenHeight:screenHeight, self->__imageView.frame.size.width, self->__imageView.frame.size.height);

            self->_viewController.renderedContentImageView.transform = CGAffineTransformIdentity;
            self->_blackMask.alpha = 0.0f;

            self->_viewController.prefersStatusBarHidden = NO;
            [self->_viewController setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished) {
            if (finished) {
                [self->_viewController.view removeFromSuperview];
                [self->_viewController removeFromParentViewController];
                self->_senderView.alpha = 1.0f;
                [UIApplication sharedApplication].statusBarHidden = NO;
                [UIApplication sharedApplication].statusBarStyle = self->_statusBarStyle;
                self->_isAnimating = NO;
                if(self->_closingBlock)
                    self->_closingBlock();
            }
        }];
    });
}

#pragma mark - Compute the new size of image relative to width(window)

- (CGRect) centerFrameFromImage:(UIImage*) image {
    if(!image) return CGRectZero;

    CGRect windowBounds = _rootViewController.view.bounds;
    CGSize newImageSize = [self imageResizeBaseOnWidth:windowBounds
                           .size.width oldWidth:image
                           .size.width oldHeight:image.size.height];
    // Just fit it on the size of the screen
    newImageSize.height = MIN(windowBounds.size.height,newImageSize.height);
    return CGRectMake(0.0f, windowBounds.size.height/2 - newImageSize.height/2, newImageSize.width, newImageSize.height);
}

- (CGSize)imageResizeBaseOnWidth:(CGFloat) newWidth oldWidth:(CGFloat) oldWidth oldHeight:(CGFloat)oldHeight {
    CGFloat scaleFactor = newWidth / oldWidth;
    CGFloat newHeight = oldHeight * scaleFactor;
    return CGSizeMake(newWidth, newHeight);

}

# pragma mark - UIScrollView Delegate

- (void)centerScrollViewContents {
    CGSize boundsSize = _rootViewController.view.bounds.size;
    CGRect contentsFrame = __imageView.frame;

    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }

    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    __imageView.frame = contentsFrame;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return __imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _isAnimating = YES;
    [self hideDoneButton];
    [self centerScrollViewContents];
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    _isAnimating = NO;
}

- (void)addMultipleGesture {
    UITapGestureRecognizer *twoFingerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTwoFingerTap:)];
    twoFingerTapGesture.numberOfTapsRequired = 1;
    twoFingerTapGesture.numberOfTouchesRequired = 2;
    [__scrollView addGestureRecognizer:twoFingerTapGesture];

    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [__scrollView addGestureRecognizer:singleTapRecognizer];

    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDobleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [__scrollView addGestureRecognizer:doubleTapRecognizer];

    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];

    __scrollView.minimumZoomScale = kMinImageScale;
    __scrollView.maximumZoomScale = kMaxImageScale;
    __scrollView.zoomScale = 1;
    [self centerScrollViewContents];
}

#pragma mark - For Zooming

- (void)didTwoFingerTap:(UITapGestureRecognizer*)recognizer {
    CGFloat newZoomScale = __scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, __scrollView.minimumZoomScale);
    [__scrollView setZoomScale:newZoomScale animated:YES];
}

#pragma mark - Showing of Done Button if ever Zoom Scale is equal to 1

- (void)didSingleTap:(UITapGestureRecognizer*)recognizer {
    if (_doneButton) {
        if(_doneButton.superview){
            [self hideDoneButton];
        }else {
            if(__scrollView.zoomScale == __scrollView.minimumZoomScale){
                if(!_isDoneAnimating){
                    _isDoneAnimating = YES;
                    [self.viewController.view addSubview:_doneButton];
                    _doneButton.alpha = 0.0f;
                    [UIView animateWithDuration:0.2f animations:^{
                        self->_doneButton.alpha = 1.0f;
                    } completion:^(BOOL finished) {
                        [self.viewController.view bringSubviewToFront:self->_doneButton];
                        self->_isDoneAnimating = NO;
                    }];
                }
            }else {
                CGPoint pointInView = [recognizer locationInView:__imageView];
                [self zoomInZoomOut:pointInView];
            }
        }
    } else {
        if(__scrollView.zoomScale == __scrollView.minimumZoomScale){
            [self close:nil];
        }else {
            CGPoint pointInView = [recognizer locationInView:__imageView];
            [self zoomInZoomOut:pointInView];
        }
    }
}

#pragma mark - Zoom in or Zoom out

- (void)didDobleTap:(UITapGestureRecognizer*)recognizer {
    CGPoint pointInView = [recognizer locationInView:__imageView];
    [self zoomInZoomOut:pointInView];
}

- (void)zoomInZoomOut:(CGPoint)point {
    // Check if current Zoom Scale is greater than half of max scale then reduce zoom and vice versa
    CGFloat newZoomScale = __scrollView.zoomScale > (__scrollView.maximumZoomScale/2)?__scrollView.minimumZoomScale:__scrollView.maximumZoomScale;

    CGSize scrollViewSize = __scrollView.bounds.size;
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = point.x - (w / 2.0f);
    CGFloat y = point.y - (h / 2.0f);
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    [__scrollView zoomToRect:rectToZoomTo animated:YES];
}

#pragma mark - Hide the Done Button

- (void)hideDoneButton {
    if(_doneButton && !_isDoneAnimating){
        if(_doneButton.superview) {
            _isDoneAnimating = YES;
            _doneButton.alpha = 1.0f;
            [UIView animateWithDuration:0.2f animations:^{
                self->_doneButton.alpha = 0.0f;
            } completion:^(BOOL finished) {
                self->_isDoneAnimating = NO;
                [self->_doneButton removeFromSuperview];
            }];
        }
    }
}

- (void)close:(UIButton *)sender {
    self.userInteractionEnabled = NO;
    [sender removeFromSuperview];
    [self dismissViewController];
}

@end


@implementation MHFacebookImageViewer

#pragma mark - Class

static BOOL __usesDoneButtonByDefault = NO;

+ (void)setUsesDoneButtonByDefault:(BOOL)usesDoneButton {
    __usesDoneButtonByDefault = usesDoneButton;
}

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _usesDoneButton = __usesDoneButtonByDefault;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _usesDoneButton = __usesDoneButtonByDefault;
    }
    return self;
}

- (void)loadView {
    [super loadView];

    _statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [UIApplication sharedApplication].statusBarHidden = YES;

    CGRect windowBounds = [[UIScreen mainScreen] bounds];
    self.view.frame = windowBounds;

    // Compute Original Frame Relative To Screen
    CGRect newFrame = [_senderView convertRect:_senderView.bounds toView:nil];
    _originalFrameRelativeToScreen = newFrame;

    // Add content dimming view
    _contentDimmingView = [[UIView alloc] initWithFrame:windowBounds];
    _contentDimmingView.backgroundColor = [UIColor blackColor];
    _contentDimmingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_contentDimmingView];

    // Add rendered view hierarchy
    _renderedContentImageView = [[UIImageView alloc] initWithFrame:windowBounds];
    _renderedContentImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_renderedContentImageView];

    // Add mask view
    _blackMask = [[UIView alloc] initWithFrame:windowBounds];
    _blackMask.backgroundColor = [UIColor blackColor];
    _blackMask.alpha = 0.0f;
    _blackMask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_blackMask];

    // Add a collection view
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0.f;
    flowLayout.minimumLineSpacing = 0.f;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    [_collectionView registerClass:[MHFacebookImageViewerCell class] forCellWithReuseIdentifier:cellID];
    [self.view addSubview:_collectionView];
    _collectionView.pagingEnabled = YES;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    [_collectionView setContentOffset:CGPointMake(_initialIndex * self.view.bounds.size.width, 0.f)];
}

#pragma mark - Custom getters

- (UIButton *)doneButton {
    if (!_doneButton) {
        CGRect windowBounds = [[UIScreen mainScreen] bounds];
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.frame = CGRectMake(windowBounds.size.width - (51.0f + 9.0f),15.0f, 51.0f, 26.0f);
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _doneButton.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3];
        [_doneButton setTitle:NSLocalizedString(@"Done", @"Facebook image viewver done button title") forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        CALayer *doneButtonLayer = _doneButton.layer;
        doneButtonLayer.cornerRadius = 5.f;
        doneButtonLayer.borderColor = [UIColor whiteColor].CGColor;
        doneButtonLayer.borderWidth = 1.f;
    }
    return _doneButton;
}

#pragma mark - Show

- (void)presentFromRootViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self presentFromViewController:rootViewController];
}

- (void)presentFromViewController:(UIViewController *)controller {
    _rootViewController = controller;

    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    [window addSubview:self.view];

    // Needs to be called after the view is loaded
    _renderedContentImageView.image = [self snapshot:controller.view];

    [controller addChildViewController:self];
    [self didMoveToParentViewController:controller];
}

- (UIImage *)snapshot:(UIView *)view {

    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // Match the item size to the view size (= gallery size due to sizing constrains)
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    CGSize availableSize = self.view.bounds.size;
    if (!CGSizeEqualToSize(availableSize, layout.itemSize)) {
        layout.itemSize = availableSize;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(!self.imageDatasource) return 1;
    return [self.imageDatasource numberImagesForImageViewer:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MHFacebookImageViewerCell *imageViewerCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    imageViewerCell.originalFrameRelativeToScreen = _originalFrameRelativeToScreen;
    imageViewerCell.viewController = self;
    imageViewerCell.blackMask = _blackMask;
    imageViewerCell.rootViewController = _rootViewController;
    imageViewerCell.closingBlock = _closingBlock;
    imageViewerCell.openingBlock = _openingBlock;
    imageViewerCell.superView = _senderView.superview;
    imageViewerCell.senderView = _senderView;
    imageViewerCell.doneButton = _usesDoneButton ? self.doneButton : nil;
    imageViewerCell.initialIndex = _initialIndex;
    imageViewerCell.statusBarStyle = _statusBarStyle;
    imageViewerCell.backgroundColor = [UIColor clearColor];

    if(!self.imageDatasource) {
        [imageViewerCell setImageURL:_imageURL defaultImage:_senderView.image imageIndex:0];
    } else {
        [imageViewerCell setImageURL:[self.imageDatasource imageURLAtIndex:indexPath.row imageViewer:self] defaultImage:[self.imageDatasource imageDefaultAtIndex:indexPath.row imageViewer:self]imageIndex:indexPath.row];
    }
    return imageViewerCell;
}

@end


@interface MHFacebookImageViewerTapGestureRecognizer : UITapGestureRecognizer
@property(nonatomic,strong) NSURL * imageURL;
@property(nonatomic,strong) MHFacebookImageViewerOpeningBlock openingBlock;
@property(nonatomic,strong) MHFacebookImageViewerClosingBlock closingBlock;
@property(nonatomic,weak) id<MHFacebookImageViewerDatasource> imageDatasource;
@property(nonatomic,assign) NSInteger initialIndex;
@end


@implementation MHFacebookImageViewerTapGestureRecognizer
@end


@interface UIImageView()<UITabBarControllerDelegate>
@end


@implementation UIImageView (MHFacebookImageViewer)

#pragma mark - Initializer for UIImageView

- (void) setupImageViewer {
    [self setupImageViewerWithCompletionOnOpen:nil onClose:nil];
}

- (void) setupImageViewerWithCompletionOnOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close {
    [self setupImageViewerWithImageURL:nil onOpen:open onClose:close];
}

- (void) setupImageViewerWithImageURL:(NSURL*)url {
    [self setupImageViewerWithImageURL:url onOpen:nil onClose:nil];
}

- (void) setupImageViewerWithImageURL:(NSURL *)url onOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close{
    self.userInteractionEnabled = YES;
    MHFacebookImageViewerTapGestureRecognizer *  tapGesture = [[MHFacebookImageViewerTapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.imageURL = url;
    tapGesture.openingBlock = open;
    tapGesture.closingBlock = close;
    [self addGestureRecognizer:tapGesture];
    tapGesture = nil;
}

- (void) setupImageViewerWithDatasource:(id<MHFacebookImageViewerDatasource>)imageDatasource onOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close {
    [self setupImageViewerWithDatasource:imageDatasource initialIndex:0 onOpen:open onClose:close];
}

- (void) setupImageViewerWithDatasource:(id<MHFacebookImageViewerDatasource>)imageDatasource initialIndex:(NSInteger)initialIndex onOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close{
    self.userInteractionEnabled = YES;
    MHFacebookImageViewerTapGestureRecognizer *tapGesture = [[MHFacebookImageViewerTapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.imageDatasource = imageDatasource;
    tapGesture.openingBlock = open;
    tapGesture.closingBlock = close;
    tapGesture.initialIndex = initialIndex;
    [self addGestureRecognizer:tapGesture];
    tapGesture = nil;
}

#pragma mark - Handle Tap

- (void) didTap:(MHFacebookImageViewerTapGestureRecognizer*)gestureRecognizer {
    MHFacebookImageViewer * imageBrowser = [[MHFacebookImageViewer alloc]init];
    imageBrowser.senderView = self;
    imageBrowser.imageURL = gestureRecognizer.imageURL;
    imageBrowser.openingBlock = gestureRecognizer.openingBlock;
    imageBrowser.closingBlock = gestureRecognizer.closingBlock;
    imageBrowser.imageDatasource = gestureRecognizer.imageDatasource;
    imageBrowser.initialIndex = gestureRecognizer.initialIndex;
    if(self.image) [imageBrowser presentFromRootViewController];
    
    [gestureRecognizer.imageDatasource willShowFacebookViewer];
}

#pragma mark Removal

- (void) removeImageViewer {
    for (UIGestureRecognizer * gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[MHFacebookImageViewerTapGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
            MHFacebookImageViewerTapGestureRecognizer *tapGesture = (MHFacebookImageViewerTapGestureRecognizer *)gesture;
            tapGesture.imageURL = nil;
            tapGesture.openingBlock = nil;
            tapGesture.closingBlock = nil;
        }
    }
}

@end
