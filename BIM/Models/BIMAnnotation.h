//
//  BIMAnnotation.h
//  BIM
//
//  Created by Alexis Jacquelin on 04/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMPlace.h"

@interface BIMAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) BIMPlace *place;

@end
