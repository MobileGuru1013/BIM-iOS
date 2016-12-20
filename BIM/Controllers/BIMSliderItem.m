//
//  BIMSliderItem.m
//  BIM
//
//  Created by Alexis Jacquelin on 27/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMSliderItem.h"

@implementation BIMSliderItem

#pragma mark -
#pragma mark - View Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self customize];
    }
    return self;
}

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    [self setFrame:CGRectMake(0, 0, 45, 45)];
}

#pragma mark -
#pragma mark - BIMSliderItemProtocol

- (void)updateItemWithRatio:(CGFloat)ratio {
}

@end
