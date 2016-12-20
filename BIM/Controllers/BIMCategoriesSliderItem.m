//
//  PTCategoriesSliderItem.m
//  BIM
//
//  Created by Alexis Jacquelin on 21/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMCategoriesSliderItem.h"
#import "BIMCategoriesItem.h"

@interface BIMCategoriesSliderItem() {
}

@property (nonatomic, strong) BIMCategoriesItem *item;

@end

@implementation BIMCategoriesSliderItem

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    [super customize];
 
    self.item = [[BIMCategoriesItem alloc] initWithFrame:self.bounds];
    self.item.center = CGPointMake(roundf(self.width / 2), roundf(self.height / 2));
    [self addSubview:self.item];
}

#pragma mark -
#pragma mark - BIMSliderItemProtocol

- (void)updateItemWithRatio:(CGFloat)ratio {    
    [self.item updateItemWithRatio:ratio];
}

@end