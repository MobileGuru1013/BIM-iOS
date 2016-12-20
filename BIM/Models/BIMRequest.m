//
//  BIMRequest.m
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMRequest.h"

@implementation BIMRequest

#pragma mark -
#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"method" : @"method",
             @"URLString" : @"path",
             @"params" : @"params",
             @"fetchAllPages" : @"fetchAllPages"
             };
}

- (NSInteger)nbObjectsRequest {
    return [self.params[@"per"] integerValue];
}

- (BIMRequest *)nextRequest {
    NSMutableDictionary *JSONDictionary = [[MTLJSONAdapter JSONDictionaryFromModel:self] mutableCopy];
    NSInteger page = [JSONDictionary[@"params"][@"page"] integerValue];
    page++;
    JSONDictionary[@"params"] = [JSONDictionary[@"params"] mutableCopy];
    JSONDictionary[@"params"][@"page"] = @(page);
    
    BIMRequest *nextRequest = [MTLJSONAdapter modelOfClass:self.class fromJSONDictionary:JSONDictionary error:nil];
    return nextRequest;
}

@end
