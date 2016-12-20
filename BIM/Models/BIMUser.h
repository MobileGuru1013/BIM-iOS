//
//  BIMUser.h
//  BIM
//
//  Created by Alexis Jacquelin on 22/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMObject.h"

@interface BIMUser : BIMObject <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *firstName;
@property (nonatomic, copy, readonly) NSString *lastName;
@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, copy, readonly) NSString *facebookEmail;
@property (nonatomic, copy, readonly) NSString *facebookUID;
@property (nonatomic, strong, readonly) NSOrderedSet *favoritePlaces;
@property (nonatomic, copy, readonly) NSDate *updatedAt;
@property (nonatomic, copy, readonly) NSDate *createdAt;

// The authorization token. You should treat this as you would the user's
// password.
@property (nonatomic, readonly, copy) NSString *facebookToken;

// The facebook token. You should treat this as you would the user's
// password.
@property (nonatomic, readonly, copy) NSString *authToken;

- (NSString *)getDescriptionUser;
- (NSString *)getTokenFormatted;
- (BOOL)isCurrentUser;
- (NSURL *)avatarURLWithSize:(CGSize)size;
+ (UIImage *)getSmallPlaceHolder;

// Returns a user with the given username and BIMServer instance.
+ (instancetype)userWithRawUID:(NSString *)facebook_uid;

@end
