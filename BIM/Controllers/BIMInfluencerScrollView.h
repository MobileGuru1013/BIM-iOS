//
//  BIMInfluencerScrollView.h
//  BIM
//
//  Created by Alexis Jacquelin on 23/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIMPlace.h"

static CGFloat const kInfluencerScrollViewHeight = 44.f;
static CGFloat const kButtonSpace = 8.f;

@interface BIMInfluencerScrollView : UIView

@property (nonatomic, weak) BIMPlace *place;

- (instancetype)initWithPlace:(BIMPlace *)place;

@end
