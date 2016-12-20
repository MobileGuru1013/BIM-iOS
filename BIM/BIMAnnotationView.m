//
//  BIMAnnotationView.m
//  BIM
//
//  Created by Alexis Jacquelin on 04/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAnnotationView.h"

@interface BIMAnnotationView() {
}

@property (nonatomic, strong) UIButton *categoryBtn;

@end

@implementation BIMAnnotationView

#pragma mark -
#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customize];
    }
    return self;
}

- (void)customize {
    self.categoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.categoryBtn setBackgroundImage:[UIImage imageNamed:@"category-icon-bg-off"] forState:UIControlStateNormal];
    [self.categoryBtn setBackgroundImage:[UIImage imageNamed:@"category-icon-bg-on"] forState:UIControlStateSelected];
    [self.categoryBtn sizeToFit];
    [self.categoryBtn setUserInteractionEnabled:NO];    
    self.bounds = self.categoryBtn.bounds;
    [self addSubview:self.categoryBtn];
    
    [[RACObserve(self, place) filter:^BOOL(BIMPlace *place_) {
        return place_ ? YES : NO;
    }] subscribeNext:^(BIMPlace *place_) {
        [self.categoryBtn setImage:[place_ getCategoryImageOnMap] forState:UIControlStateNormal];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.categoryBtn.selected = YES;
    } else {
        self.categoryBtn.selected = NO;
    }
}

@end
