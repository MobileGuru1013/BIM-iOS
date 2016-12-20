//
//  BIMAnnotation.m
//  BIM
//
//  Created by Alexis Jacquelin on 04/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAnnotation.h"

@implementation BIMAnnotation

#pragma mark -
#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate {
    return [self.place getCoordinate];
}

- (NSString *)title {
    return self.place.name;
}

- (NSString *)description {
    return @"test decription";
}

@end
