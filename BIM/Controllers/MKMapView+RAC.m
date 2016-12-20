//
//  MKMapView+RAC.m
//  BIM
//
//  Created by Alexis Jacquelin on 03/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "MKMapView+RAC.h"

@implementation MKMapView (RAC)

- (RACSignal *)rac_userLocationSignal {
    RACSignal *locationSignal = objc_getAssociatedObject(self, _cmd);
    if (locationSignal != nil) return locationSignal;
    self.delegate = nil;
    locationSignal = [[[self rac_signalForSelector:@selector(mapView:didUpdateUserLocation:) fromProtocol:@protocol(MKMapViewDelegate)] map:^id(RACTuple *tuple) {
        return tuple.second;
    }] replay];
    objc_setAssociatedObject(self, _cmd, locationSignal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.delegate = self;
    return locationSignal;
}

- (RACSignal *)rac_userDidChangeRegionSignal {
    RACSignal *locationRegionSignal = objc_getAssociatedObject(self, _cmd);
    if (locationRegionSignal != nil) return locationRegionSignal;
    self.delegate = nil;
    locationRegionSignal = [[[self rac_signalForSelector:@selector(mapView:regionDidChangeAnimated:) fromProtocol:@protocol(MKMapViewDelegate)] map:^id(RACTuple *tuple) {
        return tuple.second;
    }] replay];
    objc_setAssociatedObject(self, _cmd, locationRegionSignal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.delegate = self;
    return locationRegionSignal;
}

@end
