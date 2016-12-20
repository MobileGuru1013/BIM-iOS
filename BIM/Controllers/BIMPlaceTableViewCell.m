//
//  BIMPlaceTableViewCell.m
//  BIM
//
//  Created by Alexis Jacquelin on 30/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMPlaceTableViewCell.h"
#import "BIMScheduleView.h"

@interface BIMPlaceTableViewCell() {
}

@property (nonatomic, strong) BIMScheduleView *scheduleView;
@property (nonatomic, strong) NSLayoutConstraint *constraintWidthIV;

@end

@implementation BIMPlaceTableViewCell

#pragma mark -
#pragma mark - Lazy Loading

- (BIMScheduleView *)scheduleView {
    if (_scheduleView == nil) {
        _scheduleView = [[BIMScheduleView alloc] init];
        _scheduleView.mode = BIMScheduleModeColorWhite;
        [self.contentView addSubview:_scheduleView];
        [_scheduleView autoSetDimensionsToSize:CGSizeMake([BIMScheduleView scheduleWidthWithMode:BIMScheduleModeColorWhite], [BIMScheduleView scheduleHeight])];
        [_scheduleView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:-6];
        [_scheduleView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView withOffset:-7];
    }
    return _scheduleView;
}

#pragma mark -
#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
        
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.bottomOverlay.hidden = YES;
    self.placeLabel.textColor = [UIColor whiteColor];
    self.placeLabel.font = [UIFont bim_avenirNextRegularWithSize:24];

    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone47inch:
            self.placeLabelTrailing.constant = 43;
            break;
        case iPhone55inch:
            self.placeLabelTrailing.constant = 43;
            break;

        default:
            break;
    }
    
    @weakify(self);
    [[RACObserve(self, placeObject) filter:^BOOL(BIMPlace *place_) {
        return place_ ? YES : NO;
    }] subscribeNext:^(BIMPlace *place_) {
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
                        default:
                            self.scheduleView.hidden = YES;
                            break;
                    }
                }
            });
        }];
        @strongify(self);
        self.placeLabel.text = [place_ getDescriptionPlace];
        if (place_.subCategory) {
            if (self.constraintWidthIV) {
                [self.categoryIV removeConstraint:self.constraintWidthIV];
                self.constraintWidthIV = nil;
            }
            self.categoryIV.hidden = NO;
            self.categoryIV.image = [place_ getCategoryImage];
        } else {
            if (self.constraintWidthIV == nil) {
                self.constraintWidthIV = [self.categoryIV autoSetDimension:ALDimensionWidth toSize:0];
            }
            self.categoryIV.hidden = YES;
        }
        
        NSURL *url = [place_ getThumbnailImageStringURL];
        if (url) {
            @weakify(self);
            [self.placeIV sd_setImageWithURL:url placeholderImage:[BIMPlace getSmallPlaceHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                @strongify(self);
                self.bottomOverlay.hidden = NO;
                if (cacheType == SDImageCacheTypeNone && image) {
                    self.bottomOverlay.alpha = 0;
                    [UIView transitionWithView:self.placeIV
                                      duration:0.3
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        self.bottomOverlay.alpha = 1;
                                    } completion:nil];
                } else if (image) {
                    self.bottomOverlay.alpha = 1;
                }
            }];
        } else {
            [self.placeIV setImage:[BIMPlace getSmallPlaceHolder]];
        }
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.bottomOverlay.hidden = YES;
    [self.placeIV sd_cancelCurrentImageLoad];
}

@end
