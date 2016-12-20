//
//  BIMPlaceInformation.h
//  BIM
//
//  Created by Alexis Jacquelin on 23/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIMPlace.h"

typedef NS_ENUM(NSUInteger, BIMPlaceInformationsMode) {
    BIMPlaceModeStandard,
    BIMPlaceModeComplexe
};

@class BIMPlaceInformations;

@protocol BIMPlaceInformationDelegate <NSObject>

@required
- (void)getNextPlaceFor:(BIMPlaceInformations *)placeInfos;

@optional
- (void)goBackToSyntheticView:(BIMPlaceInformations *)placeInfos;

@end

static CGFloat const kPlaceInformationsHeight = 145.f;

@interface BIMPlaceInformations : UIView

@property (nonatomic, weak) BIMPlace *place;
@property (nonatomic, assign) BIMPlaceInformationsMode mode;

@property (nonatomic, assign) BOOL withoutAnimation;
@property (nonatomic, strong) CLLocation *location;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (weak, nonatomic) id <BIMPlaceInformationDelegate> delegatePlaceInfos;

- (CGFloat)getPlaceInformationsHeight;

@end
