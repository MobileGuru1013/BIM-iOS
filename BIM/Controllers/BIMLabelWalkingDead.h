//
//  BIMLabelWalking.h
//  Bim
//
//  Created by Alexis Jacquelin on 27/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIMPlace.h"

@interface BIMLabelWalkingDead : UILabel

@property (nonatomic, weak) BIMPlace *place;
@property (nonatomic, strong) CLLocation *location;

@end
