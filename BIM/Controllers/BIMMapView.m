//
//  BIMMapView.m
//  BIM
//
//  Created by Alexis Jacquelin on 03/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMMapView.h"
#import "MKMapView+RAC.h"
#import "BIMPlace.h"
#import "BIMAnnotation.h"
#import "BIMAnnotationView.h"
#import "MKMapView+AddOn.h"
#import "BIMCalloutView.h"
#import "BIMAPIClient+Places.h"

#define METERS_TO_MILES 0.000621371192

static NSString * const kAnnotationPlaceIdentifier = @"annotationPlace";

@interface BIMMapView() <MKMapViewDelegate, UIGestureRecognizerDelegate, SMCalloutViewDelegate> {
}

@property (nonatomic, assign) BOOL autoFocusIsRunning;
@property (nonatomic, assign) BOOL firstTime;

@property (nonatomic, strong) BIMButtonWithLoader *refreshBtn;
@property (nonatomic, strong) BIMButtonWithLoader *focusBtn;

@property (nonatomic, strong) BIMCalloutView *calloutView;

@end

@implementation BIMMapView

#pragma mark -
#pragma mark - Lazy Loading

- (BIMCalloutView *)calloutView {
    if (_calloutView == nil) {
        _calloutView = [BIMCalloutView platformCalloutView];
        _calloutView.delegate = self;
    }
    return _calloutView;
}

#pragma mark -
#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customize];
    }
    return self;
}

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    self.firstTime = YES;
    
    //Add refresh & auto focus btn
    self.refreshBtn = [BIMButtonWithLoader buttonWithType:UIButtonTypeCustom];
    [self.refreshBtn setBackgroundImage:[UIImage imageNamed:@"background-map-btn"] forState:UIControlStateNormal];
    [self.refreshBtn sizeToFit];
    [self.refreshBtn setImage:[UIImage imageNamed:@"refresh-btn"] forState:UIControlStateNormal];
    [self.refreshBtn setImageLoader:@"refresh-btn"];
    [self.refreshBtn setNeedToRestoreAfterRotation:YES];
    [self.refreshBtn setImageEdgeInsets:UIEdgeInsetsMake(1.2, .5, 0, 0)];
    [self addSubview:self.refreshBtn];
    [self.refreshBtn autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self withOffset:-5];
    [self.refreshBtn autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self withOffset:-5];

    self.focusBtn = [BIMButtonWithLoader buttonWithType:UIButtonTypeCustom];
    [self.focusBtn setBackgroundImage:[UIImage imageNamed:@"background-map-btn"] forState:UIControlStateNormal];
    [self.focusBtn sizeToFit];
    [self.focusBtn setImage:[UIImage imageNamed:@"location-off"] forState:UIControlStateNormal];
    [self.focusBtn setImage:[UIImage imageNamed:@"location-on"] forState:UIControlStateSelected];
    [self.focusBtn setImageLoader:@"system-loader"];
    [self.focusBtn setHideImageDuringLoading:YES];
    [self addSubview:self.focusBtn];
    [self.focusBtn autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.refreshBtn];
    [self.focusBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.refreshBtn withOffset:-5];
    
    [self autoFocusOnUser];
    
    @weakify(self);
    [[[[self rac_userLocationSignal] filter:^BOOL(id value) {
        return self.focusBtn.selected;
    }] flattenMap:^RACStream *(MKUserLocation *userLocation) {
        return [self userLocationSignal:userLocation.location];
    }] subscribeNext:^(MKUserLocation *userLocation) {
        @strongify(self);
        [self.focusBtn stopLoader];
        self.focusBtn.selected = YES;
    } error:^(NSError *error) {
        [self.focusBtn stopLoader];
        self.focusBtn.selected = NO;
        [error displayAlert];
    }];

    [[[[self rac_userDidChangeRegionSignal] filter:^BOOL(id value) {
        @strongify(self);
        return !self.firstTime;
    }] throttle:.3] subscribeNext:^(id x) {
        @strongify(self);
        [self annotationsSignal];
    }];
    
    [[self.refreshBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self annotationsSignal];
    }];
    [[self.focusBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *focus_btn_) {
        @strongify(self);
        if (focus_btn_.selected) {
            focus_btn_.selected = NO;
        } else {
            [self autoFocusOnUser];
        }
    }];
}

- (void)autoFocusOnUser {
    [self.focusBtn startLoader];
    @weakify(self);
    [[[self requestAuthorizationSignal] flattenMap:^RACStream *(CLLocation *location) {
        @strongify(self);
        return [self userLocationSignal:location];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [self.focusBtn stopLoader];
        self.focusBtn.selected = YES;
    } error:^(NSError *error) {
        [self.focusBtn stopLoader];
        self.focusBtn.selected = NO;
        [error displayAlert];
    }];
}

- (RACSignal *)userLocationSignal:(CLLocation *)userLocation {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (userLocation && CLLocationCoordinate2DIsValid(userLocation.coordinate)) {
            BOOL animated = NO;
            
            MKCoordinateRegion myRegion;
            if (self.firstTime) {
                double delta = 360.0 / pow(2.0, 22);
                myRegion = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(delta, delta));
            } else {
                animated = YES;
                myRegion = MKCoordinateRegionMake(userLocation.coordinate, self.region.span);
            }
            [self setCenterCoordinate:userLocation.coordinate animated:animated];
            [self setRegion:myRegion animated:animated];
            
            if (self.firstTime) {
                [self annotationsSignal];
                self.firstTime = NO;
            }

            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } else {
            NSError *errorBIM = [NSError getLocationErrorGeneric];
            [subscriber sendError:errorBIM];
        }
        return nil;
    }];
}

- (RACSignal *)requestAuthorizationSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[MMPReactiveCoreLocation instance]
           singleLocationSignalWithAccuracy:kCLLocationAccuracyBest timeout:15.0]
          deliverOn:[RACScheduler mainThreadScheduler]]
         subscribeNext:^(CLLocation *location) {
             [subscriber sendNext:location];
             [subscriber sendCompleted];
         }
         error:^(NSError *error) {
             NSError *errorBIM = [error getFormartedErrorForRACSignalLocationError];
             [subscriber sendError:errorBIM];
         }];
        return nil;
    }];
}

#pragma mark -
#pragma mark - WS

- (void)annotationsSignal {
    [self.refreshBtn startLoader];
    CGFloat radius = [self getRadius];
    @weakify(self);
    
    __block NSMutableArray *refreshedAnnotations = [NSMutableArray new];
    [[[BIMAPIClient sharedClient] fetchPlacesForUser:self.user atLocation:[self getCenterCoordinate] andRadius:radius] subscribeNext:^(BIMPlace *place) {
        BIMAnnotation *annotation = [BIMAnnotation new];
        annotation.place = place;
        [refreshedAnnotations addObject:annotation];
    } error:^(NSError *error) {
        @strongify(self);
        [self.refreshBtn stopLoader];
        [error displayAlert];
    } completed:^{
        @strongify(self);
        [self.refreshBtn stopLoader];
        if (self.annotations) {
            [self removeAnnotations:self.annotations];
        }
        [self addAnnotations:refreshedAnnotations];
        [self.calloutView dismissCalloutAnimated:NO];
    }];
}

#pragma mark -
#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } else {
        BIMAnnotation *placeAnnotation = (BIMAnnotation *)annotation;
        BIMAnnotationView *annotationView = (BIMAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotationPlaceIdentifier];
        if (annotationView == nil) {
            annotationView = [[BIMAnnotationView alloc] init];
        }
        annotationView.place = placeAnnotation.place;
        [annotationView setCanShowCallout:NO];
        
        return annotationView;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(BIMAnnotationView *)view {
    if ([view isKindOfClass:[BIMAnnotationView class]]) {
        self.calloutView.place = view.place;
        [self.calloutView presentCalloutFromRect:view.bounds inView:view constrainedToView:self animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[BIMAnnotationView class]]) {
        [self.calloutView dismissCalloutAnimated:YES];
    }
}

#pragma mark -
#pragma mark - SMCalloutViewDelegate

- (NSTimeInterval)calloutView:(SMCalloutView *)calloutView delayForRepositionWithSize:(CGSize)offset {
    // When the callout is being asked to present in a way where it or its target will be partially offscreen, it asks us
    // if we'd like to reposition our surface first so the callout is completely visible. Here we scroll the map into view,
    // but it takes some math because we have to deal in lon/lat instead of the given offset in pixels.
    CLLocationCoordinate2D coordinate = self.centerCoordinate;
    
    // where's the center coordinate in terms of our view?
    CGPoint center = [self convertCoordinate:coordinate toPointToView:self.superview];
    
    // move it by the requested offset
    center.x -= offset.width;
    center.y -= offset.height;
    
    // and translate it back into map coordinates
    coordinate = [self convertPoint:center toCoordinateFromView:self.self.superview];
    
    // move the map!
    [self setCenterCoordinate:coordinate animated:YES];
    
    // tell the callout to wait for a while while we scroll (we assume the scroll delay for MKMapView matches UIScrollView)
    return kSMCalloutViewRepositionDelayForUIScrollView;
}

- (void)calloutViewClicked:(BIMCalloutView *)calloutView {
    [self.placeDelegate displayPlace:calloutView.place for:self];
}

#pragma mark -
#pragma mark - UIGestureRecognizerDelegate

// override UIGestureRecognizer's delegate method so we can prevent MKMapView's recognizer from firing
// when we interact with UIControl subclasses inside our callout view.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    } else {
        return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
}

// Allow touches to be sent to our calloutview.
// See this for some discussion of why we need to override this: https://github.com/nfarina/calloutview/pull/9
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *calloutMaybe = [self.calloutView hitTest:[self.calloutView convertPoint:point fromView:self] withEvent:event];
    if (calloutMaybe) {
        return calloutMaybe;
    }
    return [super hitTest:point withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.focusBtn.selected = NO;
    [self.focusBtn stopLoader];
    self.refreshBtn.hidden = NO;
}

#pragma mark -
#pragma mark - Private methods

- (CLLocationCoordinate2D)getCenterCoordinate {
    CLLocationCoordinate2D centerCoor = [self centerCoordinate];
    return centerCoor;
}

- (CLLocationCoordinate2D)getTopCenterCoordinate {
    CLLocationCoordinate2D topCenterCoor = [self convertPoint:CGPointMake(self.frame.size.width / 2.0f, 0) toCoordinateFromView:self];
    return topCenterCoor;
}

- (CLLocationDistance)getRadius {
    CLLocationCoordinate2D centerCoor = [self getCenterCoordinate];
    // init center location from center coordinate
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:centerCoor.latitude longitude:centerCoor.longitude];
    
    CLLocationCoordinate2D topCenterCoor = [self getTopCenterCoordinate];
    CLLocation *topCenterLocation = [[CLLocation alloc] initWithLatitude:topCenterCoor.latitude longitude:topCenterCoor.longitude];
    
    CLLocationDistance radius = [centerLocation distanceFromLocation:topCenterLocation];
    
    //Convert to mile
    CGFloat miles = radius * METERS_TO_MILES;
    return miles;
}

@end