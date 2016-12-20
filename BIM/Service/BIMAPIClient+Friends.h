
//
//  BIMAPIClient+Friends.h
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAPIClient.h"

@interface BIMAPIClient (Friends)

- (RACSignal *)fetchFriends;

@end
