//
//  BIMHomeViewController.h
//  Bim
//
//  Created by Alexis Jacquelin on 02/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMViewController.h"
#import "BIMMainContainerViewController.h"

@class BIMChoosePlaceView;
@class BIMInfluencerScrollView;
@class BIMPlaceInformations;
@class BIMPlace;

extern NSString * const BIMAlreadyBimed;
extern NSString * const BIMAlreadyBashed;
extern NSString * const BIMAlreadyDidNext;

@protocol BIMHomeDelegate <NSObject>

@required
- (void)prepareToBimCurrentPlaceForVC:(BIMViewController *)vc;
- (void)prepareToBashCurrentPlaceForVC:(BIMViewController *)vc;
- (void)prepareToNextCurrentPlaceForVC:(BIMViewController *)vc;

@end

@protocol BIMCategoryDelegate <NSObject>

@optional
- (void)filterEurosChanged:(NSArray *)euros;
- (void)filterCategoriesChanged:(NSArray *)categories;
- (void)geolocChanged:(CLLocation *)location;
- (void)resetPlaces;

@end

@interface BIMHomeViewController : BIMViewController <BIMSliderViewControllerProtocol, BIMCategoryDelegate>

@property (nonatomic, strong) BIMChoosePlaceView *frontCardView;
@property (nonatomic, strong) BIMChoosePlaceView *backCardView;
@property (nonatomic, strong) UIButton *okBtn;
@property (nonatomic, strong) UIButton *nokBtn;
@property (nonatomic, strong) BIMInfluencerScrollView *influencerScrollView;
@property (nonatomic, strong) BIMPlaceInformations *informationPlace;
@property (nonatomic, strong) UILabel *noPlaceHolderLabel;

- (void)vcIsPushingWithDuration:(CGFloat)duration withCompletionBlock:(void (^)(void))completionBlock;
- (void)vcIsPoppedWithDuration:(CGFloat)duration withCompletionBlock:(void (^)(void))completionBlock onContainerView:(UIView *)containerView;

- (void)setCurrentImageString:(NSString *)imageString;
- (NSString *)getCurrentImageString;

@end
