//
//  BIMInfluencerButton.h
//  BIM
//
//  Created by Alexis Jacquelin on 23/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat const kInfluencerButtonHeight = 26.f;
static CGFloat const kInfluencerButtonMinWidth = 92.f;
static CGFloat const kInfluencerButtonMargin = 10.f;

@interface BIMInfluencerButton : UIButton

- (CGFloat)getCalculatedWidth;

@end
