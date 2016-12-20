//
//  UIFont+AddOn.m
//  BIM
//
//  Created by Alexis Jacquelin on 23/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "UIFont+AddOn.h"

@implementation UIFont (AddOn)

+ (UIFont *)bim_avenirMediumWithSizeAndWithoutChangeSize:(CGFloat)size{
    return [UIFont fontWithName:@"Avenir-Medium" size:size];
}

+ (UIFont *)bim_avenirNextRegularWithSizeAndWithoutChangeSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:size];
}

+ (UIFont *)bim_avenirNextMediumWithSizeAndWithoutChangeSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
}

+ (UIFont *)bim_avenirNextCondensedRegularWithSizeAndWithoutChangeSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:size];
}

+ (UIFont *)bim_avenirNextUltraLightWithSizeAndWithoutChangeSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-UltraLight" size:size];
}

+ (UIFont *)bim_avenirMediumWithSize:(CGFloat)size {
    size = [self getSizeFor:size];
    return [UIFont fontWithName:@"Avenir-Medium" size:size];
}

+ (UIFont *)bim_avenirNextRegularWithSize:(CGFloat)size {
    size = [self getSizeFor:size];
    return [UIFont fontWithName:@"AvenirNext-Regular" size:size];
}

+ (UIFont *)bim_avenirNextMediumWithSize:(CGFloat)size {
    size = [self getSizeFor:size];
    return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
}

+ (UIFont *)bim_avenirNextCondensedRegularWithSize:(CGFloat)size {
    size = [self getSizeFor:size];
    return [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:size];
}

+ (UIFont *)bim_avenirNextUltraLightWithSize:(CGFloat)size {
    size = [self getSizeFor:size];
    return [UIFont fontWithName:@"AvenirNext-UltraLight" size:size];
}

+ (CGFloat)getSizeFor:(CGFloat)size {
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone55inch:
            return size * 1.3;
            break;
        case iPhone47inch:
            return size * 1.2;
            break;
        default:
            break;
    }
    return size;
}

@end
