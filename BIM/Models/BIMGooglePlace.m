//
//  BIMGooglePlace.m
//  BIM
//
//  Created by Alexis Jacquelin on 28/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMGooglePlace.h"

@implementation BIMGooglePlace

#pragma mark -
#pragma mark - Properties

- (CLLocation *)getLocation {
    return [[CLLocation alloc] initWithLatitude:[self.latitude floatValue] longitude:[self.longitude floatValue]];
}

- (CLLocationCoordinate2D)getCoordinate {
    return CLLocationCoordinate2DMake([self.latitude floatValue], [self.longitude floatValue]);
}

#pragma mark -
#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"uniqueID": @"id",
             @"name": @"name",
             @"formattedAddress": @"formatted_address",
             @"latitude": @"geometry",
             @"longitude": @"geometry"
             };
}

+ (NSValueTransformer *)latitudeJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock:^id(NSDictionary *geometry) {
        NSDictionary *location = geometry[@"location"];
        return location[@"lat"];
    }];
}

+ (NSValueTransformer *)longitudeJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock:^id(NSDictionary *geometry) {
        NSDictionary *location = geometry[@"location"];
        return location[@"lng"];
    }];
}

- (NSString *)getDescriptionPlace {
    return self.formattedAddress;
}

@end
