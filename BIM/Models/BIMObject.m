//
//  BIMObject.m
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMObject.h"

@interface BIMObject () {
}

@end

@implementation BIMObject

#pragma mark -
#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"uniqueID": @"id"
             };
}

#pragma mark -
#pragma mark - NSObject

- (BOOL)isEqual:(BIMObject *)obj {
    if (self == obj) return YES;
    if (![obj isMemberOfClass:self.class]) return NO;
    return [obj.uniqueID isEqual:self.uniqueID];
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

@end
