//
//  RACSignal+BIMClientAdditions.m
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "RACSignal+BIMClientAdditions.h"
#import "BIMResponse.h"

@implementation RACSignal (BIMClientAdditions)

- (RACSignal *)bim_parsedResults {
    return [self map:^(BIMResponse *response) {
        NSAssert([response isKindOfClass:BIMResponse.class], @"Expected %@ to be an BIMResponse.", response);
        return response.parsedResult;
    }];
}

@end
