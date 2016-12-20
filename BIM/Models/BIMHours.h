//
//  BIMHours.h
//  Bim
//
//  Created by Alexis Jacquelin on 15/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMObject.h"
#import "BIMOpen.h"

typedef NS_ENUM(NSUInteger, BIMDays) {
    BIMDaysNone                 = 0,
    BIMDaysMonday               = 1 << 0,
    BIMDaysTuesday              = 1 << 1,
    BIMDaysWednesday            = 1 << 2,
    BIMDaysThursday             = 1 << 3,
    BIMDaysFriday               = 1 << 4,
    BIMDaysSaturday             = 1 << 5,
    BIMDaysSunday               = 1 << 6
};

@interface BIMHours : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign, readonly) BIMDays days;
@property (nonatomic, strong, readonly) NSOrderedSet *opens;

- (NSString *)getTitle;
- (BOOL)checkIfContainDate;
- (BOOL)containsDay:(BIMDays)day;

@end