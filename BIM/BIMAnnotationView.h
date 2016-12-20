//
//  BIMAnnotationView.h
//  BIM
//
//  Created by Alexis Jacquelin on 04/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "BIMPlace.h"

@interface BIMAnnotationView : MKAnnotationView

@property (nonatomic, weak) BIMPlace *place;

@end
