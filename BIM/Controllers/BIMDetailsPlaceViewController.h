//
//  BIMDetailsPlaceViewController.h
//  BIM
//
//  Created by Alexis Jacquelin on 23/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMViewController.h"
#import "BIMPlace.h"

@class BIMInfluencerScrollView;
@class BIMPlaceInformations;
@protocol BIMHomeDelegate;
@protocol BIMPlaceInformationDelegate;

@interface BIMDetailsPlaceViewController : BIMViewController

@property (nonatomic, weak) BIMInfluencerScrollView *influencerScrollView;
@property (nonatomic, weak) BIMPlaceInformations *informationPlace;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollViewIV;

@property (nonatomic, weak) BIMPlace *place;
@property (nonatomic, assign) BOOL fromPlacesVC;

@property (nonatomic, weak) id <BIMHomeDelegate> delegateHome;
@property (nonatomic, weak) id <BIMPlaceInformationDelegate> delegatePlaceInfos;

- (void)vcIsPushedWithDuration:(CGFloat)duration withCompletionBlock:(void (^)(void))completionBlock onContainerView:(UIView *)containerView;
- (void)vcIsPoppingWithDuration:(CGFloat)duration withCompletionBlock:(void (^)(void))completionBlock;

- (void)setCurrentImageString:(NSString *)imageString;
- (NSString *)getCurrentImageString;

+ (CGFloat)offsetInfosPlace;

@end
