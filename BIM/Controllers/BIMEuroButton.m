//
//  BIMEuroButton.m
//  BIM
//
//  Created by Alexis Jacquelin on 27/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMEuroButton.h"

@implementation BIMEuroButton

#pragma mark -
#pragma mark - View Cycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setAdjustsImageWhenHighlighted:NO];
    
    [self setSKYTitleColor:[UIColor whiteColor]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
    
    [self setBackgroundImage:[UIImage imageNamed:@"filter-euro-off"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"filter-euro-off"] forState:UIControlStateDisabled];
    [self setBackgroundImage:[UIImage imageNamed:@"filter-euro-on"] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageNamed:@"filter-euro-on"] forState:UIControlStateSelected];

    [self customizeForSelection:self.isSelected];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted && self.selected) {
        [self customizeForSelection:NO];
    } else {
        [self customizeForSelection:(highlighted || self.selected)];
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self customizeForSelection:selected];
}

- (void)customizeForSelection:(BOOL)selected {
    if (selected) {
        [self.titleLabel setFont:[UIFont bim_avenirNextRegularWithSize:22]];
        self.titleLabel.alpha = 1;
    } else {
        [self.titleLabel setFont:[UIFont bim_avenirNextUltraLightWithSize:22]];
        self.titleLabel.alpha = .5;
    }
}

@end
