//
//  PTFriendsSliderItem.m
//  BIM
//
//  Created by Alexis Jacquelin on 21/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMFriendsSliderItem.h"
#import "BIMSliderNavBar.h"
#import "BIMFriendsItem.h"

@interface BIMFriendsSliderItem() {
}

@property (nonatomic, strong) BIMFriendsItem *item;

@end

@implementation BIMFriendsSliderItem

- (void)customize {
    [super customize];

    self.item = [[BIMFriendsItem alloc] initWithFrame:self.bounds];
    self.item.center = CGPointMake(roundf(self.width / 2), roundf(self.height / 2));
    [self addSubview:self.item];
}

#pragma mark -
#pragma mark - BIMSliderItemProtocol

- (void)updateItemWithRatio:(CGFloat)ratio {
    [self.item updateItemWithRatio:ratio];
}

@end
