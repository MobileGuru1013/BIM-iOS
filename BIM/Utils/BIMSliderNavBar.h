//
//  BIMSlidingNavBar.h
//  BIM
//
//  Created by Alexis Jacquelin on 21/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIMNavigationBar.h"

@class BIMMainContainerViewController;

@protocol BIMSliderItemProtocol <NSObject>

- (void)updateItemWithRatio:(CGFloat)ratio;

@end

@interface BIMSliderNavBar : BIMNavigationBar

@property (nonatomic, strong) NSArray *arrayOfItems;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) CGPoint contentOffset;

@property (nonatomic, weak) BIMMainContainerViewController *mainContainer;

- (void)hideCurrentItemsWithAnimationWithDuration:(CGFloat)duration;
- (void)showCurrentItemsWithAnimationWithDuration:(CGFloat)duration;

@end
