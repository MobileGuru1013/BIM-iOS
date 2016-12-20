//
//  MKMapView+AddOn.h
//  BIM
//
//  Created by Alexis Jacquelin on 04/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <MapKit/MapKit.h>

//Inspired by the sample of  https://github.com/nfarina/calloutview

@interface MKMapView (AddOn)

// this tells the compiler that MKMapView actually implements this method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

@end
