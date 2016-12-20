//
//  BIMObject.h
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "MTLModel.h"

@interface BIMObject : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSNumber *uniqueID;

+ (NSDateFormatter *)dateFormatter;

@end
