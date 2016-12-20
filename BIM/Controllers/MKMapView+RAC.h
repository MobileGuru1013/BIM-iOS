//
//  MKMapView+RAC.h
//  BIM
//
//  Created by Alexis Jacquelin on 03/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (RAC) <MKMapViewDelegate>

- (RACSignal *)rac_userLocationSignal;
- (RACSignal *)rac_userDidChangeRegionSignal;

@end
