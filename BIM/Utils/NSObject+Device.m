//
//  NSObject+Device.m
//  Bim
//
//  Created by Alexis Jacquelin on 24/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "NSObject+Device.h"
#import "UIDevice+Hardware.h"

@implementation NSObject (Device)

+ (BOOL)bim_isRetina {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0) {
        return YES;
    }
    return NO;
}

+ (NSString *)bim_deviceDescription {
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSString *model = [UIDevice hardwareDescription];
    
    return [NSString stringWithFormat:@"%@ - %.1f", model, version];
}

@end
