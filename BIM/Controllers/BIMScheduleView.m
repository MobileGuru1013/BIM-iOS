//
//  BIMScheduleView.m
//  BIM
//
//  Created by Alexis Jacquelin on 22/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMScheduleView.h"

static CGFloat const kScheduleImageHeight = 14.f;
static CGFloat const kScheduleLabelHeight = 14.f;

@interface BIMScheduleView() {
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation BIMScheduleView

#pragma mark -
#pragma mark - View Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _mode = BIMScheduleModeColorGreen;

        _imageView = [UIImageView new];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_imageView];

        _label = [UILabel new];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
        @weakify(self);
        [RACObserve(self, isOpen) subscribeNext:^(NSNumber *opened) {
            @strongify(self);
            self.label.font = [self fontSchedule];
            self.imageView.image = [self imageSchedule];
            self.label.text = [self labelTextSchedule];
            self.label.textColor = [self labelTextColorSchedule];
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, self.width, kScheduleImageHeight);
    
    self.label.frame = CGRectMake(0, self.height - kScheduleLabelHeight, self.width, kScheduleLabelHeight);
}

+ (CGFloat)scheduleWidthWithMode:(BIMScheduleModeColor)mode {
    CGFloat width = 0;
    CGFloat inc = 0;
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone55inch:
            if ([SKYTrad(@"langue") isEqualToString:@"fr-FR"]) {
                width = 38.f;
            } else {
                width = 35.f;
            }
            inc = 5;
            break;
        case iPhone47inch:
            if ([SKYTrad(@"langue") isEqualToString:@"fr-FR"]) {
                width = 39.f;
            } else {
                width = 35.f;
            }
            inc = 1;
            break;
        default:
            if ([SKYTrad(@"langue") isEqualToString:@"fr-FR"]) {
                width = 33.f;
            } else {
                width = 30.f;
            }
            break;
    }
    if (mode == BIMScheduleModeColorWhite) {
        width += inc;
    }
    return width;
}

+ (CGFloat)scheduleHeight {
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone55inch:
            return 30.f;
            break;
        case iPhone47inch:
            return 28.f;
            break;
        default:
            return 28.f;
            break;
    }
}

- (UIFont *)fontSchedule {
    switch (self.mode) {
        case BIMScheduleModeColorWhite:
            return [UIFont bim_avenirNextMediumWithSize:11];
        case BIMScheduleModeColorGreen:
        default:
            return [UIFont bim_avenirNextRegularWithSize:10];
            break;
    }
}

- (UIImage *)imageSchedule {
    if (self.isOpen) {
        return [self imageOpen];
    } else {
        return [self imageClose];
    }
}

- (NSString *)labelTextSchedule {
    if (self.isOpen) {
        return [self textOpen];
    } else {
        return [self textClose];
    }
}

- (UIColor *)labelTextColorSchedule {
    if (self.isOpen) {
        return [self textColorOpen];
    } else {
        return [self textColorClose];
    }
}

- (UIColor *)textColorOpen {
    switch (self.mode) {
        case BIMScheduleModeColorWhite:
            return [UIColor whiteColor];
        case BIMScheduleModeColorGreen:
        default:
            return [UIColor bim_greenColor];
            break;
    }
}

- (UIColor *)textColorClose {
    switch (self.mode) {
        case BIMScheduleModeColorWhite:
            return [UIColor clearColor];
        case BIMScheduleModeColorGreen:
        default:
            return [UIColor bim_grayColor];
            break;
    }
}

- (NSString *)textOpen {
    return SKYTrad(@"place.open");
}

- (NSString *)textClose {
    switch (self.mode) {
        case BIMScheduleModeColorWhite:
            return nil;
        case BIMScheduleModeColorGreen
            :
        default:
            return SKYTrad(@"place.close");
            break;
    }
}

- (UIImage *)imageOpen {
    switch (self.mode) {
        case BIMScheduleModeColorWhite:
            return [UIImage imageNamed:@"schedule-open"];
        case BIMScheduleModeColorGreen:
        default:
            return [UIImage imageNamed:@"schedule-open-green"];
            break;
    }
}

- (UIImage *)imageClose {
    switch (self.mode) {
        case BIMScheduleModeColorWhite:
            return nil;
        case BIMScheduleModeColorGreen:
        default:
            return [UIImage imageNamed:@"schedule-close"];
            break;
    }
}

@end