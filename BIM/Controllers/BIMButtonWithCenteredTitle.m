//
//  BiMButtonWithCenteredTitle.m
//  BIM
//
//  Created by Alexis Jacquelin on 05/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMButtonWithCenteredTitle.h"

@implementation BIMButtonWithCenteredTitle

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.centerX = round(self.width / 2);
    self.titleLabel.top = round(self.height * .64);

    self.imageView.centerX = round(self.width / 2);
    self.imageView.top = round(self.height * .19);
}

@end
