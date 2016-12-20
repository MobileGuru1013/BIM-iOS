//
//  BIMGooglePlace.h
//  BIM
//
//  Created by Alexis Jacquelin on 28/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMObject.h"

@interface BIMGooglePlace : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSNumber *uniqueID;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *formattedAddress;
@property (nonatomic, copy, readonly) NSNumber *latitude;
@property (nonatomic, copy, readonly) NSNumber *longitude;

- (CLLocation *)getLocation;
- (CLLocationCoordinate2D)getCoordinate;
- (NSString *)getDescriptionPlace;

@end
