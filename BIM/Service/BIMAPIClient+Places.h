//
//  BIMAPIClient+Places.h
//  Bim
//
//  Created by Alexis Jacquelin on 24/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAPIClient.h"

@class BIMPlace;

@interface BIMAPIClient (Places)

- (RACSignal *)bim:(BIMPlace *)place;
- (RACSignal *)bash:(BIMPlace *)place;
- (RACSignal *)fetchBimsForUser:(BIMUser *)user;
- (RACSignal *)fetchPlacesForUser:(BIMUser *)user atLocation:(CLLocationCoordinate2D)location andRadius:(CGFloat)radius;

- (RACSignal *)fetchPlacesWithParams:(NSDictionary *)params;

@end
