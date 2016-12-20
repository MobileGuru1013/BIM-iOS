//
//  BIMHours.m
//  Bim
//
//  Created by Alexis Jacquelin on 15/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMHours.h"

@implementation BIMHours

#pragma mark -
#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"days": @"days",
             @"opens": @"open",
             };
}

+ (NSValueTransformer *)daysJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock:^NSNumber *(NSArray *arrayOfDays) {
        BIMDays day = BIMDaysNone;
        
        for (NSNumber *dayNb in arrayOfDays) {
            if (day == BIMDaysNone) {
                day = [self getDayForNb:dayNb];
            } else {
                day = day | [self getDayForNb:dayNb];
            }
        }
        return @(day);
    }];
}

+ (NSValueTransformer *)opensJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:BIMOpen.class];
}

+ (BIMDays)getDayForNb:(NSNumber *)dayNb {
    switch ([dayNb intValue]) {
        case 1:
            return BIMDaysMonday;
            break;
        case 2:
            return BIMDaysTuesday;
            break;
        case 3:
            return BIMDaysWednesday;
            break;
        case 4:
            return BIMDaysThursday;
            break;
        case 5:
            return BIMDaysFriday;
            break;
        case 6:
            return BIMDaysSaturday;
            break;
        case 7:
            return BIMDaysSunday;
            break;
        default:
            SKYLog(@"ERROR DAY UNKNOWN %@", dayNb);
            return BIMDaysNone;
            break;
    }
}

- (NSString *)getTitle {
    NSArray *days = [self getAllDays];
    if (days.count == 0) {
        SKYLog(@"ERROR DAYS EMPTY");
        return @"";
    }
    if (days.count == 1) {
        return [self getFormattedDayFor:[days firstObject]];
    } else if ([self canBeFormatted:days]) {
        NSString *beginDay = [self getFormattedDayFor:[days firstObject]];
        NSString *lastDay = [self getFormattedDayFor:[days lastObject]];
        return SKYTrad(@"week.formatted.to", beginDay, lastDay);
    } else {
        NSMutableString *string = [NSMutableString new];
        for (NSNumber *dayNb in days) {
            if (string.length > 0) {
                [string appendString:@", "];
            }
            [string appendString:[self getFormattedDayFor:dayNb]];
        }
        return string;
    }
}

- (NSArray *)getAllDays {
    BIMDays days = self.days;
    BIMDays comparatorDay = BIMDaysNone;
    NSMutableArray *arrayOfDay = [NSMutableArray new];
    while (days != BIMDaysNone &&
           comparatorDay != BIMDaysSunday) {
        if (comparatorDay == BIMDaysNone) {
            comparatorDay = BIMDaysMonday;
        } else {
            comparatorDay = comparatorDay << 1;
        }
        if (days & comparatorDay) {
            [arrayOfDay addObject:@(comparatorDay)];
        }
    }
    return arrayOfDay;
}

- (BOOL)canBeFormatted:(NSArray *)days {
    for (int i = 0; i < days.count - 1; i++) {
        BIMDays day = [days[i] intValue];
        BIMDays nextDay = [days[i + 1] intValue];
        
        if ((day << 1) & nextDay) {
            continue;
        } else {
            return NO;
        }
    }
    return YES;
}

- (NSString *)getFormattedDayFor:(NSNumber *)dayNb {
    switch ([dayNb intValue]) {
        case BIMDaysMonday:
            return SKYTrad(@"monday");
            break;
        case BIMDaysTuesday:
            return SKYTrad(@"tuesday");
            break;
        case BIMDaysWednesday:
            return SKYTrad(@"wednesday");
            break;
        case BIMDaysThursday:
            return SKYTrad(@"thursday");
            break;
        case BIMDaysFriday:
            return SKYTrad(@"friday");
            break;
        case BIMDaysSaturday:
            return SKYTrad(@"saturday");
            break;
        case BIMDaysSunday:
            return SKYTrad(@"sunday");
            break;
        default:
            SKYLog(@"ERROR DAY UNKNOWN %@", dayNb);
            return @"";
            break;
    }
}

- (BOOL)checkIfContainDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];

    BIMDays day = BIMDaysNone;
    switch (date.weekday) {
        case 1:
            day = BIMDaysSunday;
            break;
        case 2:
            day = BIMDaysMonday;
            break;
        case 3:
            day = BIMDaysTuesday;
            break;
        case 4:
            day = BIMDaysWednesday;
            break;
        case 5:
            day = BIMDaysThursday;
            break;
        case 6:
            day = BIMDaysFriday;
            break;
        case 7:
            day = BIMDaysSaturday;
            break;
        default:
            break;
    }
    if (day == BIMDaysNone) {
        return NO;
    }
    for (BIMOpen *open in self.opens) {
        int start = [open.start intValue];
        int end = [open.end intValue];
        if (end == 0) {
            end = 2359;
        }
        BIMDays nextDay = BIMDaysNone;
        if (start > end) {
            if (day != BIMDaysSunday) {
                nextDay = day << 1;
            } else {
                nextDay = BIMDaysMonday;
            }
        }
        BOOL check = NO;
        if (!check && [self containsDay:day]) {
            check = [open containsHours:hour andMinutes:minute];
        }
        if (!check && nextDay != BIMDaysNone &&
            [self containsDay:nextDay]) {
            check = [open containsHours:hour andMinutes:minute];
        }
        if (check) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)containsDay:(BIMDays)day {
    if (day & self.days) {
        return YES;
    } else {
        return NO;
    }
}

@end
