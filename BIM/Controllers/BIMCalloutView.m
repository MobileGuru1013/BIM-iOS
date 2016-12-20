//
//  BIMCalloutView.m
//  BIM
//
//  Created by Alexis Jacquelin on 04/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMCalloutView.h"
#import "BIMPlace.h"

@interface BIMCalloutView() {
}

@property (nonatomic, strong) UIImageView *categoryIV;
@property (nonatomic, strong) UIButton *containerView;
@property (nonatomic, strong) UILabel *titlePlaceLabel;
@property (nonatomic, strong) UIView *titleView;

@end

@implementation BIMCalloutView

#pragma mark -
#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.containerView setBackgroundColor:RGBCOLOR(20, 41, 48)];
        self.containerView.layer.borderWidth = .5f;
        self.containerView.layer.borderColor = [UIColor blackColor].CGColor;
        
        [[RACObserve(self, place) filter:^BOOL(BIMPlace *place_) {
            return (place_) ? YES : NO;
        }] subscribeNext:^(BIMPlace *place_) {
            self.categoryIV.image = [place_ getCategoryImage];
            self.titlePlaceLabel.text = place_.name;
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleView.top -= 5;
}

+ (BIMCalloutView *)platformCalloutView {
    BIMCalloutView *calloutView = [BIMCalloutView new];
    
    //title
    calloutView.titlePlaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 17)];
    calloutView.titlePlaceLabel.textColor = [UIColor whiteColor];
    calloutView.titlePlaceLabel.font = [UIFont bim_avenirNextRegularWithSize:15];
    [calloutView.titlePlaceLabel setBackgroundColor:[UIColor clearColor]];
    calloutView.titleView = [[UIView alloc] initWithFrame:calloutView.titlePlaceLabel.bounds];
    [calloutView.titleView setBackgroundColor:[UIColor clearColor]];
    [calloutView.titleView addSubview:calloutView.titlePlaceLabel];

    //description - meters
    
    //leftview
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 31, 40)];
    [leftView setBackgroundColor:[UIColor bim_blueMapColor]];
    calloutView.categoryIV = [[UIImageView alloc] initWithFrame:leftView.bounds];
    [calloutView.categoryIV setContentMode:UIViewContentModeCenter];
    [leftView addSubview:calloutView.categoryIV];
    calloutView.leftAccessoryView = leftView;

    //disclosure indicator
    UIButton *disclosure = [UIButton buttonWithType:UIButtonTypeCustom];
    [disclosure setImage:[UIImage imageNamed:@"disclosure-btn"] forState:UIControlStateNormal];
    [disclosure sizeToFit];
    disclosure.userInteractionEnabled = NO;
    calloutView.rightAccessoryView = disclosure;

    calloutView.containerView.userInteractionEnabled = NO;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:calloutView action:@selector(calloutClicked)];
    [calloutView addGestureRecognizer:tapGesture];
    calloutView.userInteractionEnabled = YES;
    
    return calloutView;
}

- (void)calloutClicked {
    if ([self.delegate respondsToSelector:@selector(calloutViewClicked:)]) {
        [self.delegate calloutViewClicked:self];
    }
}

#pragma mark -
#pragma mark - Private methods

- (CGFloat)calloutContainerHeight {
    return 40;
}

@end
