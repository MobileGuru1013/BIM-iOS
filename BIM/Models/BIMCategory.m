//
//  BIMCategory.m
//  Bim
//
//  Created by Alexis Jacquelin on 25/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMCategory.h"

@implementation BIMCategory

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
                                                                                          @"name" : @"name"
                                                                                          }];
}

@end
