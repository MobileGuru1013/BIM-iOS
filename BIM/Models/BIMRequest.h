//
//  BIMRequest.h
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "MTLModel.h"

@interface BIMRequest : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *method;
@property (nonatomic, copy, readonly) NSString *URLString;
@property (nonatomic, assign, readonly) BOOL fetchAllPages;
@property (nonatomic, copy, readonly) NSDictionary *params;

- (NSInteger)nbObjectsRequest;
- (BIMRequest *)nextRequest;

@end
