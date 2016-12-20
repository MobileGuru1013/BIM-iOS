//
//  BIMAPIClient+Friends.m
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAPIClient+Friends.h"
#import "BIMUser.h"
#import "BIMRequest.h"

@implementation BIMAPIClient (Friends)

- (RACSignal *)fetchFriends {
    BIMRequest *request = [MTLJSONAdapter modelOfClass:BIMRequest.class fromJSONDictionary:@{
                                                                                             @"method" : @"GET",
                                                                                             @"path" : @"friends"
                                                                                             } error:nil];

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.tokenSignal subscribeNext:^(BIMUser *user) {
            [self.requestSerializer setValue:[user getTokenFormatted] forHTTPHeaderField:@"Authorization"];
            [[[self enqueueRequest:request resultClass:BIMUser.class] bim_parsedResults] subscribe:subscriber];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

@end
