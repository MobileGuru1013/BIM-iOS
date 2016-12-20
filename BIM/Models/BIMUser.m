//
//  BIMUser.m
//  BIM
//
//  Created by Alexis Jacquelin on 22/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMUser.h"
#import "BIMPlace.h"

NSString * const BIMFacebookAvatar = @"https://graph.facebook.com/%@/picture?width=%.0f&height=%.0f";

@implementation BIMUser

#pragma mark -
#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
                                                                                          @"authToken" : @"auth_token",
                                                                                          @"createdAt" : @"created_at",
                                                                                          @"email" : @"email",
                                                                                          @"facebookEmail" : @"facebook_email",
                                                                                          @"facebookToken" : @"facebook_token",
                                                                                          @"facebookUID" : @"facebook_uid",
                                                                                          @"firstName" : @"first_name",
                                                                                          @"lastName" : @"last_name",
                                                                                          @"updatedAt" : @"updated_at"
//                                                                                          @"favoritePlaces" : @"favorite_places"
             }];
}

- (NSString *)getTokenFormatted {
    return [NSString stringWithFormat:@"Token token=\"%@\"", self.authToken];
}

- (BOOL)isCurrentUser {
    return [[BIMAPIClient sharedClient].user.uniqueID isEqualToNumber:self.uniqueID];
}

- (NSURL *)avatarURLWithSize:(CGSize)size {
    if ([NSObject bim_isRetina]) {
        size = CGSizeMake(size.width * 2, size.height * 2);
    }
    NSString *urlString = [NSString stringWithFormat:BIMFacebookAvatar, self.facebookUID, size.width, size.height];
    return [NSURL URLWithString:urlString];
}

+ (NSValueTransformer *)favoritePlacesJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:BIMPlace.class];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)authTokenJSONTransformer {
    // We want to prevent the token from being serialized out, so the reverse
    // transform will simply yield nil instead of the token itself.
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *token) {
        return token;
    } reverseBlock:^ id (NSString *token) {
        return nil;
    }];
}

+ (NSValueTransformer *)facebookTokenJSONTransformer {
    // We want to prevent the token from being serialized out, so the reverse
    // transform will simply yield nil instead of the token itself.
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *token) {
        return token;
    } reverseBlock:^ id (NSString *token) {
        return nil;
    }];
}

- (NSString *)getDescriptionUser {
    if (self.firstName && self.firstName.length > 0 &&
        self.lastName && self.lastName.length > 0) {
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    } else if (self.firstName && self.firstName.length > 0) {
        return self.firstName;
    } else if (self.lastName && self.lastName.length > 0) {
        return self.lastName;
    } else {
        return SKYTrad(@"friends.a.friend");
    }
}

+ (UIImage *)getSmallPlaceHolder {
    return [UIImage imageNamed:@"placeholder-user-small"];
}

+ (instancetype)userWithRawUID:(NSString *)facebook_uid {
    NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
    if (facebook_uid != nil) userDict[@keypath(BIMUser.new, facebookUID)] = facebook_uid;
    
    return [self modelWithDictionary:userDict error:NULL];
}

@end
