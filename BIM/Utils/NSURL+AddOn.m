//
//  NSURL+AddOn.m
//  Bim
//
//  Created by Alexis Jacquelin on 27/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "NSURL+AddOn.h"

@implementation NSURL (AddOn)

+ (NSURL *)bim_getURLFromString:(NSString *)string {
    if ([string isKindOfClass:[NSString class]] &&
        string.length > 0) {
        string = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return [NSURL URLWithString:string];
    } else {
        return nil;
    }
}

@end
