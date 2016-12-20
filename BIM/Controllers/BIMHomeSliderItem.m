//
//  PTHomeSliderItem.m
//  BIM
//
//  Created by Alexis Jacquelin on 21/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMHomeSliderItem.h"
#import "BIMHomeItem.h"

@interface BIMHomeSliderItem() {
}

@property (nonatomic, strong) BIMHomeItem *item;

@end

@implementation BIMHomeSliderItem

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    [super customize];
    
    self.item = [[BIMHomeItem alloc] initWithFrame:CGRectMake(0, 0, 80, 70)];
    self.item.center = CGPointMake(roundf(self.width / 2), roundf(self.height / 2));
    [self addSubview:self.item];
}

#pragma mark -
#pragma mark - BIMSliderItemProtocol

- (void)updateItemWithRatio:(CGFloat)ratio {
    [super updateItemWithRatio:ratio];
    
    [self.item updateItemWithRatio:ratio];

    //Change the center
    CGFloat centerX;
    if (self.centerX < WIDTH_DEVICE / 2) {
        //left placement
        const CGFloat minX = 27.f;
        const CGFloat maxX = self.width / 2;
        centerX =  minX + (maxX - minX) * ratio;
    } else {
        //right placement
        const CGFloat minX = 37.f;
        const CGFloat maxX = self.width / 2;
        centerX =  minX + (maxX - minX) * ratio;
    }
    self.item.center = CGPointMake(centerX, self.item.centerY);
}

@end
