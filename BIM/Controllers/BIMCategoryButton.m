//
//  BIMCategoryButton.m
//  BIM
//
//  Created by Alexis Jacquelin on 27/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMCategoryButton.h"

@implementation BIMCategoryButton

#pragma mark -
#pragma mark - View Cycle

- (void)awakeFromNib {
    [super awakeFromNib];

    [self setAdjustsImageWhenHighlighted:NO];
    
    [self.titleLabel setFont:[UIFont bim_avenirNextUltraLightWithSize:23]];
    [self setSKYTitleColor:[UIColor whiteColor]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
    
    [self setBackgroundImage:[UIImage imageNamed:@"category-bg-off"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"category-bg-off"] forState:UIControlStateDisabled];
    [self setBackgroundImage:[UIImage imageNamed:@"category-bg-on"] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageNamed:@"category-bg-on"] forState:UIControlStateSelected];
    
    [self customizeForSelection:self.isSelected];
}

- (void)setCustomTitle:(NSString *)title {
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:title];
    [attrStr addAttribute:NSKernAttributeName value:@(4.0) range:NSMakeRange(0, attrStr.length)];
    self.titleLabel.attributedText = attrStr;
    
    [self setSKYTitle:title];
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
        self.titleLabel.alpha = 1;
    } else {
        self.titleLabel.alpha = .5;
    }
}
@end
