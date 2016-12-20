//
//  BIMResponse.h
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "MTLModel.h"

// Represents a parsed response from the BIM API, along with any useful
// headers.
@interface BIMResponse : MTLModel

// The parsed MTLModel object corresponding to the API response.
@property (nonatomic, copy, readonly) id parsedResult;

// Initializes the receiver with the headers from the given response, and the
// given parsed model object(s).
- (instancetype)initWithHTTPURLResponse:(NSHTTPURLResponse *)response parsedResult:(id)parsedResult;

@end
