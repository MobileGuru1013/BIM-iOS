//
//  NSError+AddOn.h
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BIMSearchLocationError) {
    BIMSearchLocationNotFound,
    BIMSearchLocationEmpty
};

@interface NSError (AddOn)

- (void)displayAlert;
- (BOOL)isAnAuthenticatedError;

- (NSError *)getFormartedErrorForRACSignalLocationError;
- (NSError *)getFormartedErrorForFacebookError;

+ (NSError *)getAuthenticationRequiredError;
+ (NSError *)getLocationErrorGeneric;
+ (NSError *)getLocationErrorEmpty;
+ (NSError *)getLocationNotFound;
+ (NSError *)getAuthentificationFacebookFailed;
+ (NSError *)getParsingError;

@end
