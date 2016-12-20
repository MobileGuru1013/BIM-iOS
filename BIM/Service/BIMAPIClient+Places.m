//
//  BIMAPIClient+Places.m
//  Bim
//
//  Created by Alexis Jacquelin on 24/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAPIClient+Places.h"
#import "BIMPlace.h"

#define NB_PLACES_RETURNED 25

@implementation BIMAPIClient (Places)

- (RACSignal *)bim:(BIMPlace *)place {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people increment:@"Bim count" by:@1];

    [mixpanel track:@"Bim" properties:@{
                             @"id": place.uniqueID
                             }];

    BIMRequest *request = [MTLJSONAdapter modelOfClass:BIMRequest.class fromJSONDictionary:@{
                                                                                             @"method" : @"PUT",
                                                                                             @"path" : [NSString stringWithFormat:@"places/%@/bims", place.uniqueID]
                                                                                             } error:nil];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.tokenSignal subscribeNext:^(BIMUser *user) {
            [self.requestSerializer setValue:[user getTokenFormatted] forHTTPHeaderField:@"Authorization"];
            [[[self enqueueRequest:request resultClass:BIMPlace.class] bim_parsedResults] subscribe:subscriber];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)bash:(BIMPlace *)place {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people increment:@"Bash count" by:@1];

    [mixpanel track:@"Bash" properties:@{
                                        @"id": place.uniqueID
                                        }];

    BIMRequest *request = [MTLJSONAdapter modelOfClass:BIMRequest.class fromJSONDictionary:@{
                                                                                             @"method" : @"PUT",
                                                                                             @"path" : [NSString stringWithFormat:@"places/%@/bashes", place.uniqueID]
                                                                                             } error:nil];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.tokenSignal subscribeNext:^(BIMUser *user) {
            [self.requestSerializer setValue:[user getTokenFormatted] forHTTPHeaderField:@"Authorization"];
            [[[self enqueueRequest:request resultClass:BIMPlace.class] bim_parsedResults] subscribe:subscriber];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)fetchBimsForUser:(BIMUser *)user {
    BIMRequest *request = [MTLJSONAdapter modelOfClass:BIMRequest.class fromJSONDictionary:@{
                                                                                             @"method" : @"GET",
                                                                                             @"path" : [NSString stringWithFormat:@"friends/%@/places", user.uniqueID],
                                                                                             @"params" : @{
                                                                                                     @"order" : @"created_at",
                                                                                                     @"page" : @1,
                                                                                                     @"per" : @(NB_PLACES_RETURNED)
                                                                                                         },
                                                                                             @"fetchAllPages" : @YES
                                                                                             } error:nil];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.tokenSignal subscribeNext:^(BIMUser *user) {
            [self.requestSerializer setValue:[user getTokenFormatted] forHTTPHeaderField:@"Authorization"];
            [[[self enqueueRequest:request resultClass:BIMPlace.class] bim_parsedResults] subscribe:subscriber];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)fetchPlacesForUser:(BIMUser *)user atLocation:(CLLocationCoordinate2D)location andRadius:(CGFloat)radius {
    BIMRequest *request = [MTLJSONAdapter modelOfClass:BIMRequest.class fromJSONDictionary:@{
                                                                                             @"method" : @"GET",
                                                                                             @"params" : @{
                                                                                                     @"latitude" : @(location.latitude),
                                                                                                     @"longitude" : @(location.longitude),
                                                                                                     @"radius" : @(radius),
                                                                                                     @"page" : @1,
                                                                                                     @"per" : @(NB_PLACES_RETURNED)
                                                                                                     },
                                                                                             @"fetchAllPages" : @YES,
                                                                                             @"path" : [NSString stringWithFormat:@"friends/%@/places", user.uniqueID]
                                                                                             } error:nil];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.tokenSignal subscribeNext:^(BIMUser *user) {
            [self.requestSerializer setValue:[user getTokenFormatted] forHTTPHeaderField:@"Authorization"];
            [[[self enqueueRequest:request resultClass:BIMPlace.class] bim_parsedResults] subscribe:subscriber];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)fetchPlacesWithParams:(NSDictionary *)params {
    BIMRequest *request = [MTLJSONAdapter modelOfClass:BIMRequest.class fromJSONDictionary:@{
                                                                                             @"method" : @"GET",
                                                                                             @"params" : params,
                                                                                             @"path" : @"places"
                                                                                             } error:nil];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.tokenSignal subscribeNext:^(BIMUser *user) {
            [self.requestSerializer setValue:[user getTokenFormatted] forHTTPHeaderField:@"Authorization"];
            [[[self enqueueRequest:request resultClass:BIMPlace.class] bim_parsedResults] subscribe:subscriber];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

@end
