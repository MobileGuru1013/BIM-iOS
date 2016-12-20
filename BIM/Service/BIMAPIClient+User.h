//
//  BIMAPIClient+User.h
//  Bim
//
//  Created by Alexis Jacquelin on 24/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAPIClient.h"

@interface BIMAPIClient (User)

- (RACSignal *)logoutUser;

@end
