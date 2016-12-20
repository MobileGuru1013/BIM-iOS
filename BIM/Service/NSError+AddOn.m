//
//  NSError+AddOn.m
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "NSError+AddOn.h"

@implementation NSError (AddOn)

- (void)displayAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SKYTrad(@"error") message:nil delegate:nil cancelButtonTitle:SKYTrad(@"ok") otherButtonTitles:nil];
    switch (self.code) {
        case BIMFacebookErrorAuthenticationFailed:
            alertView.message = SKYTrad(@"error.login.account");
            break;
        case BIMFacebookErrorPasswordChanged:
            alertView.message = SKYTrad(@"error.login.password");
        case BIMFacebookErrorAccessForbidden:
            alertView.message = SKYTrad(@"error.login.permissions");
            break;
        case BIMUserLocationErrorAccessForbidden:
            alertView.message = SKYTrad(@"location.permission.denied");
            break;
        case BIMErrorNoConnection:
            alertView.message = SKYTrad(@"error.internet.connexion");
            break;
        case BIMUserLocationErrorTimeOut:
            //Do nothing to improve the UX
            return;
            break;
        case BIMUserLocationErrorGeneric:
        default:
            alertView.message = SKYTrad(@"error.generic.code", self.code);
            break;
    }
    [alertView show];
}

- (BOOL)isAnAuthenticatedError {
    switch (self.code) {
        case BIMFacebookErrorAuthenticationFailed:
        case BIMFacebookErrorPasswordChanged:
        case BIMFacebookErrorAccessForbidden:
        case BIMClientErrorAuthenticationFailed:
            return YES;
            break;
        default:
            break;
    }
    return NO;
}

- (NSError *)getFormartedErrorForRACSignalLocationError {
    if ([self.domain isEqualToString:@"RACSignalErrorDomain"] &&
        self.code == 1) {
        //timeout
        return [NSError errorWithDomain:@"Map" code:BIMUserLocationErrorTimeOut userInfo:nil];
    } else if (self.code == 1) {
        //user disable location in settings
        return [NSError errorWithDomain:@"Map" code:BIMUserLocationErrorAccessForbidden userInfo:nil];
    } else {
        return [NSError getLocationErrorGeneric];
    }
}

- (NSError *)getFormartedErrorForFacebookError {
    @try {
        if (self.userInfo[@"com.facebook.sdk:ParsedJSONResponseKey"][@"body"][@"error"][@"error_subcode"]) {
            return [NSError errorWithDomain:@"Login" code:BIMFacebookErrorPasswordChanged userInfo:nil];
        } else {
            return [NSError errorWithDomain:@"Login" code:BIMFacebookErrorAccessForbidden userInfo:nil];
        }
    }
    @catch (NSException *exception) {
        return [NSError errorWithDomain:@"Login" code:BIMFacebookErrorAccessForbidden userInfo:nil];
    }
}

+ (NSError *)getAuthenticationRequiredError {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: SKYTrad(@"error.sign.in")
                               };
    
    return [NSError errorWithDomain:BIMClientErrorDomain code:BIMClientErrorAuthenticationFailed userInfo:userInfo];
}

+ (NSError *)getLocationErrorGeneric {
    return [NSError errorWithDomain:@"Map" code:BIMUserLocationErrorGeneric userInfo:nil];
}

+ (NSError *)getLocationErrorEmpty {
    return [NSError errorWithDomain:@"Map" code:BIMUserLocationErrorEmptyMode userInfo:nil];
}

+ (NSError *)getLocationNotFound {
     return [NSError errorWithDomain:@"Search" code:BIMSearchLocationNotFound userInfo:nil];
}

+ (NSError *)getAuthentificationFacebookFailed {
    return [NSError errorWithDomain:@"Login" code:BIMFacebookErrorAuthenticationFailed userInfo:nil];
}

+ (NSError *)getParsingError {
    return [NSError errorWithDomain:BIMClientErrorDomain code:BIMClientErrorJSONParsingFailed userInfo:nil];
}

@end
