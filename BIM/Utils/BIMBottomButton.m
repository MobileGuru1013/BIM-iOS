//
//  BIMBottomButton.m
//  BIM
//
//  Created by Alexis Jacquelin on 27/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMBottomButton.h"

@implementation BIMBottomButton

#pragma mark -
#pragma mark - View Cycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.5]];
    [self setSKYTitleColor:[UIColor whiteColor]];
    
    [self setBackgroundImage:[UIImage imageNamed:@"bottom-menu-off"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"bottom-menu-off"] forState:UIControlStateDisabled];
    [self setBackgroundImage:[UIImage imageNamed:@"bottom-menu-on"] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageNamed:@"bottom-menu-on"] forState:UIControlStateSelected];
    
    [self customizeForSelection:self.isSelected];
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
