//
//  BIMResponse.m
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMResponse.h"

@interface BIMResponse() {
}

@property (nonatomic, copy, readonly) NSHTTPURLResponse *HTTPURLResponse;

@end

@implementation BIMResponse

#pragma mark -
#pragma mark - Lifecycle

- (id)initWithHTTPURLResponse:(NSHTTPURLResponse *)response parsedResult:(id)parsedResult {
    return [super initWithDictionary:@{
                                       @keypath(self.parsedResult): parsedResult ?: NSNull.null,
                                        @keypath(self.HTTPURLResponse): [response copy] ?: NSNull.null,
                                        } error:NULL];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark NSObject

- (NSUInteger)hash {
    return self.HTTPURLResponse.hash;
}

@end
