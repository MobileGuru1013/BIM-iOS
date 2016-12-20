//
//  BIMPlaceInformation.m
//  BIM
//
//  Created by Alexis Jacquelin on 23/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMPlaceInformations.h"
#import "BIMTagsPlaceView.h"
#import "BIMSchedulePlaceView.h"
#import "BIMCategory.h"
#import "BIMLabelWalkingDead.h"

@interface BIMPlaceInformations() {
}

@property (weak, nonatomic) IBOutlet UIImageView *crossIV;
@property (weak, nonatomic) IBOutlet UIImageView *walkingManIV;
@property (weak, nonatomic) IBOutlet UIImageView *categoryIV;
@property (weak, nonatomic) IBOutlet UIImageView *euroIV;
@property (weak, nonatomic) IBOutlet UIImageView *scheduleIV;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet BIMLabelWalkingDead *walkingLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceCross;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerYEuroConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerYScheduleConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerXCategoryConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerXWalkingManConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCrossConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftCrossConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightCrossConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraintTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraintAddress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraintCategory;

@property (nonatomic, strong) BIMTagsPlaceView *tagsPlaceView;
@property (nonatomic, strong) BIMSchedulePlaceView *schedulePlaceView;

@property (nonatomic, strong) NSLayoutConstraint *heightSchedulePlaceView;
@property (nonatomic, strong) NSLayoutConstraint *heightTagView;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation BIMPlaceInformations

#pragma mark -
#pragma mark - Lazy load

- (void)setMode:(BIMPlaceInformationsMode)mode {
    _mode = mode;
    if (_mode == BIMPlaceModeComplexe) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:self.tapGesture];
        self.userInteractionEnabled = YES;
    } else {
        [self removeGestureRecognizer:self.tapGesture];
    }
}

#pragma mark -
#pragma mark - View Cycle

- (void)awakeFromNib {
    [super awakeFromNib];

    [self setBackgroundColor:[UIColor clearColor]];
    
    [self.titleLabel setFont:[UIFont bim_avenirNextUltraLightWithSize:39]];
    [self.categoryNameLabel setFont:[UIFont bim_avenirNextUltraLightWithSize:19]];
    self.addressLabel.font = self.categoryNameLabel.font;
    self.walkingLabel.font = self.categoryNameLabel.font;
    [self setupConstraintScrollView];
    [self setupConstraint];
    [UIView performWithoutAnimation:^{
        [self layoutIfNeeded];
    }];
    
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone47inch:
        case iPhone55inch:
            self.widthConstraintTitle.constant = WIDTH_DEVICE - 50;
            self.widthConstraintAddress.constant = WIDTH_DEVICE - 50;
            self.widthConstraintCategory.constant = WIDTH_DEVICE / 3.4;
            break;
        default:
            break;
    }
    
    @weakify(self);
    [RACObserve(self, place) subscribeNext:^(BIMPlace *place_) {
        @strongify(self);
        self.titleLabel.text = [place_ getDescriptionPlace];
        self.addressLabel.text = [place_ getAddressPlace];
        self.categoryIV.image = [place_ getThumbnailCategoryImage];
        self.categoryNameLabel.text = place_.subCategory.name;
        self.euroIV.image = [place_ getThumbnailEuroImage];
        
        if (self.location) {
            self.walkingLabel.location = self.location;
            self.walkingLabel.place = place_;
        } else {
            self.walkingLabel.place = place_;
        }
        [UIView performWithoutAnimation:^{
            [self.categoryNameLabel layoutIfNeeded];
            [self layoutIfNeeded];
        }];
    }];
    [RACObserve(self, mode) subscribeNext:^(NSNumber *mode_) {
        @strongify(self);
        switch ((BIMPlaceInformationsMode)[mode_ integerValue]) {
            case BIMPlaceModeStandard: {
                self.scrollView.scrollEnabled = NO;
                [self setupConstraintScrollView];

                if (!IOS8) {
                    self.schedulePlaceView.alpha = 0;
                    self.tagsPlaceView.alpha = 0;
                    self.addressLabel.alpha = 0;
                }
                void (^block)() = ^{
                    self.schedulePlaceView.alpha = 0;
                    self.tagsPlaceView.alpha = 0;
                    self.scheduleIV.alpha = 0;
                    self.addressLabel.alpha = 0;
                    [self layoutIfNeeded];
                };
                if (self.withoutAnimation) {
                    block();
                } else {
                    [UIView animateWithDuration:.2 animations:^{
                        block();
                    } completion:nil];
                }
                break;
            }
            case BIMPlaceModeComplexe: {
                [self displaySchedule];
                [self displayTags];
                [self setupConstraintScrollView];
                self.scrollView.scrollEnabled = YES;
                self.schedulePlaceView.alpha = 0;
                self.tagsPlaceView.alpha = 0;
                
                void (^block)() = ^{
                    self.schedulePlaceView.alpha = 1;
                    self.tagsPlaceView.alpha = 1;
                    self.scheduleIV.alpha = 1;
                    self.addressLabel.alpha = 1;
                    [self layoutIfNeeded];
                };
                if (self.withoutAnimation) {
                    if (IOS8) {
                        self.scrollView.contentInset = UIEdgeInsetsMake(-20.f, 0, 0, 0);
                    } else {
                        self.scrollView.contentInset = UIEdgeInsetsMake(45.f, 0, 0, 0);
                    }
                    block();
                } else {
                    [UIView animateWithDuration:.2 animations:^{
                        block();
                        const CGFloat insetTop = 45.f;
                        self.scrollView.contentInset = UIEdgeInsetsMake(insetTop, 0, 0, 0);
                        [self.scrollView setContentOffset:CGPointMake(0, -insetTop)];
                    } completion:nil];
                }
                break;
            }
            default:
                break;
        }
    }];
    [self.crossIV sizeToFit];
    self.leftCrossConstraint.constant = WIDTH_DEVICE / 2 - self.crossIV.width / 2;
    self.rightCrossConstraint.constant = WIDTH_DEVICE - (self.leftCrossConstraint.constant + self.crossIV.width);
    
    [[self.nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.delegatePlaceInfos getNextPlaceFor:self];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
}

- (void)setupConstraintScrollView {
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone55inch:
            if (self.mode == BIMPlaceModeStandard) {
                self.verticalSpaceCross.constant = 77.f;
            } else {
                self.verticalSpaceCross.constant = 123.f;
            }
            break;
        case iPhone47inch:
            if (self.mode == BIMPlaceModeStandard) {
                self.verticalSpaceCross.constant = 75.f;
            } else {
                self.verticalSpaceCross.constant = 119.f;
            }
            break;
            break;
        default:
            if (self.mode == BIMPlaceModeStandard) {
                self.verticalSpaceCross.constant = 68.f;
            } else {
                self.verticalSpaceCross.constant = 108.f;
            }
            break;
    }
    if (self.mode == BIMPlaceModeStandard) {
        self.bottomCrossConstraint.constant = 10.f;
    } else {
        CGFloat diff = self.scheduleIV.bottom - self.crossIV.bottom + 20;
        if (self.heightTagView.constant > 0) {
            diff += 10;
        }
        if (self.heightSchedulePlaceView.constant > 0) {
            diff += 10;
        }
        self.bottomCrossConstraint.constant = diff + self.heightSchedulePlaceView.constant + self.heightTagView.constant;
    };
}

- (void)setupConstraint {
    CGFloat offset = 0.f;
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone55inch:
            offset = 6.f;
            break;
        default:
            break;
    }
    self.centerYEuroConstraint.constant += offset;
    self.centerXCategoryConstraint.constant += offset;
    self.centerYScheduleConstraint.constant -= offset;
    self.centerXWalkingManConstraint.constant -= offset;
}

#pragma mark -
#pragma mark - Internal methods

- (void)displaySchedule {
    if (self.schedulePlaceView) {
        [self.schedulePlaceView removeFromSuperview];
    }
    self.schedulePlaceView = [[BIMSchedulePlaceView alloc] initWithFrame:CGRectMake(0, self.scheduleIV.bottom + 10, WIDTH_DEVICE, 0)];
    self.schedulePlaceView.place = self.place;
    [self.scrollView addSubview:self.schedulePlaceView];
    [self.schedulePlaceView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.scrollView];
    [self.schedulePlaceView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.scrollView];
    [self.schedulePlaceView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.scheduleIV withOffset:10];
    self.heightSchedulePlaceView = [self.schedulePlaceView autoSetDimension:ALDimensionHeight toSize:[self.schedulePlaceView totalHeight]];
}

- (void)displayTags {
    if (self.tagsPlaceView) {
        [self.tagsPlaceView removeFromSuperview];
    }
    self.tagsPlaceView = [[BIMTagsPlaceView alloc] initWithFrame:CGRectMake(0, self.scheduleIV.bottom + 10 + self.heightSchedulePlaceView.constant + 10, WIDTH_DEVICE, 0)];
    self.tagsPlaceView.place = self.place;
    [self.scrollView addSubview:self.tagsPlaceView];
    [self.tagsPlaceView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.scrollView];
    [self.tagsPlaceView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.scrollView];
    [self.tagsPlaceView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.schedulePlaceView withOffset:10];
    self.heightTagView = [self.tagsPlaceView autoSetDimension:ALDimensionHeight toSize:[self.tagsPlaceView totalHeight]];
}

- (CGFloat)getPlaceInformationsHeight {
    switch (self.mode) {
        case BIMPlaceModeStandard:
            switch ([SDiPhoneVersion deviceSize] ) {
                case iPhone55inch:
                    return 169.f;
                    break;
                case iPhone47inch:
                    return 152.f;
                    break;
                default:
                    return kPlaceInformationsHeight;
                    break;
            }
            break;
        case BIMPlaceModeComplexe:
            switch ([SDiPhoneVersion deviceSize] ) {
                case iPhone35inch:
                    return 265.f;
                    break;
                case iPhone55inch:
                    return 408.f;
                    break;
                case iPhone47inch:
                    return 359.f;
                    break;
                default:
                    return 300.f;
                    break;
            }
            break;
        default:
            return kPlaceInformationsHeight;
            break;
    }
}

#pragma mark -
#pragma mark - TapGesture

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
    if ([self.delegatePlaceInfos respondsToSelector:@selector(goBackToSyntheticView:)]) {
        [self.delegatePlaceInfos goBackToSyntheticView:self];
    }
}

@end
