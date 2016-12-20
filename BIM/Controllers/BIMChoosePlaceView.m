//
//  BIMChoosePlaceView.m
//  BIM
//
//  Created by Alexis Jacquelin on 22/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMChoosePlaceView.h"

static CGFloat const kBufferHorizontalPadding = 10.f;
static CGFloat const kBufferTopPadding = 73.f;
static CGFloat const kTopOverlayHeight = 74.f;
static CGFloat const kBottomOverlayHeight = 100.f;
static CGFloat const kBottomOverlayBottomPadding = 38.f;

@interface BIMChoosePlaceView()

@property (nonatomic, strong) UIImageView *bottomOverlay;
@property (nonatomic, strong) UIImageView *topOverlay;

//Used to cancel the swipe
- (void)mdc_returnToOriginalCenter;
- (void)mdc_executeOnPanBlockForTranslation:(CGPoint)translation;

@end

#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation BIMChoosePlaceView

#pragma mark -
#pragma mark - Lazy Loading

- (CGFloat)scheduleTrailing {
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone55inch:
            return 7.f;
            break;
        case iPhone47inch:
            return 4.f;
            break;
        default:
            return 3.f;
            break;
    }
}

- (CGFloat)scheduleBottomPadding {
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone55inch:
            return 3.f;
            break;
        case iPhone47inch:
            return 3.f;
            break;
        default:
            return 1.f;
            break;
    }
}

#pragma mark -
#pragma mark - View Cycle

- (instancetype)initWithFrame:(CGRect)frame
                     andPlace:(BIMPlace *)place withOptions:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame options:options];
    if (self) {
        _place = place;
        
        [self constructSchedulePlace];

        self.imageView.image = [BIMPlace getBigPlaceHolder];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];

        if (options) {
            [self preloadIVWithURL:[place getThumbnailImageStringURL]];
        } else {
            for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
                [self removeGestureRecognizer:gesture];
            }
        }
        @weakify(self);
        [RACObserve(self, place) subscribeNext:^(BIMPlace *place_) {
            [place_ isOpenWithCompletionBlock:^(BIMScheduleModeState state, NSError *error) {
                @strongify(self);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        self.scheduleView.hidden = YES;
                    } else {
                        switch (state) {
                            case BIMScheduleModeStateOpen:
                                self.scheduleView.hidden = NO;
                                self.scheduleView.isOpen = YES;
                                break;
                            case BIMScheduleModeStateClose:
                                self.scheduleView.hidden = NO;
                                self.scheduleView.isOpen = NO;
                                break;
                            case BIMScheduleModeStateUnknown:
                                self.scheduleView.hidden = YES;
                                break;
                            default:
                                break;
                        }
                    }
                });
            }];
        }];
        
        [[RACObserve(self, imageURLString) filter:^BOOL(NSString *imageURLString_) {
            return imageURLString_ ? YES : NO;
        }] subscribeNext:^(NSString *imageURLString_) {
            @strongify(self);
            [self preloadIVWithURL:[NSURL bim_getURLFromString:imageURLString_]];
        }];
    }
    return self;
}

- (void)cancelPanGesture {
    [self mdc_returnToOriginalCenter];
    [self mdc_executeOnPanBlockForTranslation:CGPointZero];
}

#pragma mark -
#pragma mark - Internal methods

- (void)preloadIVWithURL:(NSURL *)url {
    if (url) {
        @weakify(self);
        [self.imageView sd_setImageWithURL:url placeholderImage:[BIMPlace getBigPlaceHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            @strongify(self);
            if (cacheType == SDImageCacheTypeNone && image) {
                [self constructTopOverlay];
                [self constructBottomOverlay];
                [self.bottomOverlay setAlpha:0];
                [self.topOverlay setAlpha:0];
                [UIView transitionWithView:self.imageView
                                  duration:0.3
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    [self.bottomOverlay setAlpha:1];
                                    [self.topOverlay setAlpha:1];
                                } completion:nil];
            } else {
                [self constructTopOverlay];
                [self constructBottomOverlay];
            }
        }];
    } else {
        [self.imageView setImage:[BIMPlace getBigPlaceHolder]];
    }
}

- (void)setupView {}

- (void)constructLikedView {
    UIImageView *bufferIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bim"]];
    [bufferIV sizeToFit];
    CGRect frame = CGRectMake(kBufferHorizontalPadding,
                              kBufferTopPadding,
                              bufferIV.width,
                              bufferIV.height);
    self.likedView = [[UIView alloc] initWithFrame:frame];
    bufferIV.frame = self.likedView.bounds;
    
    self.likedView.alpha = 0.f;
    [self.likedView addSubview:bufferIV];
    [self.imageView addSubview:self.likedView];
}

- (void)constructNopeImageView {
    UIImageView *bufferIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bash"]];
    [bufferIV sizeToFit];
    CGRect frame = CGRectMake(self.width - kBufferHorizontalPadding - bufferIV.width,
                              kBufferTopPadding,
                              bufferIV.width,
                              bufferIV.height);
    self.nopeView = [[UIView alloc] initWithFrame:frame];
    bufferIV.frame = self.nopeView.bounds;
    
    self.nopeView.alpha = 0.f;
    [self.nopeView addSubview:bufferIV];
    [self.imageView addSubview:self.nopeView];
}

- (void)constructTopOverlay {
    if (self.topOverlay.superview) {
        return;
    }
    self.topOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top-overlay"]];

    [self.imageView insertSubview:self.topOverlay belowSubview:self.scheduleView];
    
    [self.topOverlay autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.imageView];
    [self.topOverlay autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.imageView];
    [self.topOverlay autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.imageView];
    [self.topOverlay autoSetDimension:ALDimensionHeight toSize:kTopOverlayHeight];
}

- (void)constructBottomOverlay {
    if (self.bottomOverlay.superview) {
        return;
    }

    self.bottomOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom-overlay"]];
    
    [self.imageView insertSubview:self.bottomOverlay belowSubview:self.scheduleView];

    [self.bottomOverlay autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.imageView];
    [self.bottomOverlay autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.imageView];
    [self.bottomOverlay autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.imageView withOffset:kBottomOverlayBottomPadding];
    [self.bottomOverlay autoSetDimension:ALDimensionHeight toSize:kBottomOverlayHeight];
}
 
- (void)constructSchedulePlace {
    self.scheduleView = [BIMScheduleView new];
    
    [self.imageView addSubview:self.scheduleView];

    [self.scheduleView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.imageView withOffset:-[self scheduleBottomPadding]];
    [self.scheduleView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.imageView withOffset:-[self scheduleTrailing]];
    [self.scheduleView autoSetDimensionsToSize:CGSizeMake([BIMScheduleView scheduleWidthWithMode:BIMScheduleModeColorGreen], [BIMScheduleView scheduleHeight])];
}

@end
