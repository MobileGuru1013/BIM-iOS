//
//  BIMMapView.h
//  BIM
//
//  Created by Alexis Jacquelin on 03/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <MapKit/MapKit.h>

@class BIMMapView;
@class BIMPlace;

@protocol BIMMapDelegate <NSObject>

@required
- (void)displayPlace:(BIMPlace *)place for:(BIMMapView *)mapView;

@end

@interface BIMMapView : MKMapView

@property (nonatomic, weak) id <BIMMapDelegate>placeDelegate;
@property (nonatomic, weak) BIMUser *user;

@end
