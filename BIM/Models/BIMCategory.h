//
//  BIMCategory.h
//  Bim
//
//  Created by Alexis Jacquelin on 25/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMObject.h"

@interface BIMCategory : BIMObject <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *name;

@end
