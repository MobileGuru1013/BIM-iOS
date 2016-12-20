//
//  BIMInfluencerScrollView.m
//  BIM
//
//  Created by Alexis Jacquelin on 23/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMInfluencerScrollView.h"
#import "BIMInfluencerButton.h"

@interface BIMInfluencerScrollView() {
}

@property (nonatomic, strong) NSMutableArray *arrayOfInfluencers;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation BIMInfluencerScrollView

#pragma mark -
#pragma mark - Lazy Loading

- (NSMutableArray *)arrayOfInfluencers {
    if (_arrayOfInfluencers == nil) {
        _arrayOfInfluencers = [NSMutableArray new];
    }
    return _arrayOfInfluencers;
}

#pragma mark -
#pragma mark - View Cycle

-(instancetype)initWithPlace:(BIMPlace *)place {
    self = [self init];
    
    if (self) {
        _place = place;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self addBackgroundIV];
        [self addScrollView];
        
        @weakify(self);
        [RACObserve(self, place) subscribeNext:^(BIMPlace *place) {
            @strongify(self);
            [self removeOldInfluencers];
            [self displayInfluencers];
        }];
    }
    return self;
}

#pragma mark -
#pragma mark - Look & Feel

- (void)displayInfluencers {
    int i = 0;
    CGFloat offset = kButtonSpace;
    for (NSString *nameInfluencer in [self.place getInfluencers]) {
        BIMInfluencerButton *btn = [BIMInfluencerButton buttonWithType:UIButtonTypeCustom];
        [btn setSKYTitle:nameInfluencer];
        [self.scrollView addSubview:btn];

        [btn autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.scrollView];
        CGFloat sizeWidthBtn = [btn getCalculatedWidth];
        [btn autoSetDimensionsToSize:CGSizeMake(sizeWidthBtn, kInfluencerButtonHeight)];
        [btn autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.scrollView withOffset:offset];

        [self.arrayOfInfluencers addObject:btn];
        offset += sizeWidthBtn + kButtonSpace;
        i++;
    }
    [self.scrollView setContentSize:CGSizeMake(offset, kInfluencerScrollViewHeight)];
}

#pragma mark -
#pragma mark - Internal methods

- (void)addBackgroundIV {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"translucent-bg"]];
    [self addSubview:imageView];
    [imageView autoCenterInSuperview];
    [imageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [imageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
}

- (void)addScrollView {
    self.scrollView = [UIScrollView new];
    [self addSubview:self.scrollView];
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    
    [self.scrollView autoCenterInSuperview];
    [self.scrollView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [self.scrollView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
}

- (void)removeOldInfluencers {
    for (BIMInfluencerButton *btn in _arrayOfInfluencers) {
        [btn removeFromSuperview];
    }
    _arrayOfInfluencers = nil;
}

@end
