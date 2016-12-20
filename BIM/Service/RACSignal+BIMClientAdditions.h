//
//  RACSignal+BIMClientAdditions.h
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "RACSignal.h"

// Convenience category to retreive parsedResults from BIMResponses.
@interface RACSignal (BIMClientAdditions)

// This method assumes that the receiver is a signal of BIMResponses.
//
// Returns a signal that maps the receiver to become a signal of
// BIMResponse.parsedResult.
- (RACSignal *)bim_parsedResults;

@end
