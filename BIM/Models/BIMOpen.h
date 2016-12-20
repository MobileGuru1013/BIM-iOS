//
//  BIMOpen.h
//  Bim
//
//  Created by Alexis Jacquelin on 15/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "MTLModel.h"

@interface BIMOpen : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *start;
@property (nonatomic, copy, readonly) NSString *end;

- (NSString *)getTitle;
- (BOOL)containsHours:(NSInteger)hour andMinutes:(NSInteger)minute;

@end
