//
//  BIMMainContainerViewController.h
//  BIM
//
//  Created by Alexis Jacquelin on 21/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMViewController.h"
#import "BIMSliderNavBar.h"

@protocol BIMSliderViewControllerProtocol <NSObject>

@optional
- (void)activeAfterScrolling;
- (void)resetVCAfterScrolling;

@end

@interface BIMMainContainerViewController : BIMViewController

@property (nonatomic, strong) NSArray *arrayOfViewControllers;

- (void)setCurrentPage:(NSInteger)page withAnimation:(BOOL)animated;
- (BIMViewController *)currentViewController;

- (void)vcIsPushingWithDuration:(CGFloat)duration withCompletionBlock:(void (^)(void))completionBlock;
- (void)vcIsPoppedWithDuration:(CGFloat)duration withCompletionBlock:(void (^)(void))completionBlock;

@end
