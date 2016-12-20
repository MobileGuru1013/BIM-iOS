//
//  BIMOpen.m
//  Bim
//
//  Created by Alexis Jacquelin on 15/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMOpen.h"

@implementation BIMOpen

#pragma mark -
#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"start": @"start",
             @"end": @"end",
             };
}

- (NSString *)getTitle {
    if ([self.start isEqualToString:@"0000"] &&
        [self.end isEqualToString:@"2359"]) {
        //full day
        return SKYTrad(@"open.full.day");
    }
    
    NSMutableString *start = [self.start mutableCopy];
    if (start.length >= 2) {
        [start insertString:@":" atIndex:2];
    }
    NSMutableString *end = [self.end mutableCopy];
    if (end.length >= 2) {
        [end insertString:@":" atIndex:2];
    }
    return [NSString stringWithFormat:@"%@ - %@", start, end];
}

- (BOOL)containsHours:(NSInteger)hour andMinutes:(NSInteger)minute {
    @try {
        NSInteger startHour = [[self.start substringToIndex:2] integerValue];
        NSInteger endHour = [[self.end substringToIndex:2] integerValue];
        NSInteger startMinute = [[self.start substringFromIndex:2] integerValue];
        NSInteger endMinute = [[self.end substringFromIndex:2] integerValue];
        
        if (endHour == 0 && endMinute == 0) {
            endHour = 23;
            endMinute = 59;
        }
        if (startHour <= endHour && (startHour != endHour || startMinute <= endMinute)) {
            if (hour >= startHour && hour <= endHour) {
                if (hour != startHour || minute >= startMinute) { //same start hour, we check the minutes
                    if (hour != endHour || minute <= endMinute) { //same end hour, we check the minutes
                        return YES;
                    }
                }
            }
        } else if (hour >= startHour || hour <= endHour) {
            if (hour != startHour || minute >= startMinute) { //same start hour, we check the minutes
                if (hour != endHour || minute <= endMinute) { //same end hour, we check the minutes
                    return YES;
                }
            }
        }
        return NO;
    } @catch (NSException *exception) {
        SKYLog(@"ERROR ON PARSING %@", exception);
        return NO;
    }
}

@end
