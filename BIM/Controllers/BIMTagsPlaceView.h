//
//  BIMTagsPlace.h
//  BIM
//
//  Created by Alexis Jacquelin on 05/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIMPlace.h"

@interface BIMTagsPlaceView : UIView

@property (nonatomic, weak) BIMPlace *place;

- (CGFloat)totalHeight;

@end
