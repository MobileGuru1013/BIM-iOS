//
//  BIMCalloutView.h
//  BIM
//
//  Created by Alexis Jacquelin on 04/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "SMCalloutView.h"

@class BIMPlace;

@interface BIMCalloutView : SMCalloutView

@property (nonatomic, weak) BIMPlace *place;

+ (BIMCalloutView *)platformCalloutView;

@end
