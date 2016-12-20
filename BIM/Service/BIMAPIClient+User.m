//
//  BIMAPIClient+User.m
//  Bim
//
//  Created by Alexis Jacquelin on 24/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAPIClient+User.h"

@implementation BIMAPIClient (User)

- (RACSignal *)logoutUser {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Logout"];
    BIMRequest *request = [MTLJSONAdapter modelOfClass:BIMRequest.class fromJSONDictionary:@{
                                                                                             @"method" : @"DELETE",
                                                                                             @"path" : @"sessions"
                                                                                             } error:nil];
    return [[self enqueueRequest:request resultClass:BIMUser.class] bim_parsedResults];
}

@end
