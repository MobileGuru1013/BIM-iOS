//
//  UIFont+AddOn.h
//  BIM
//
//  Created by Alexis Jacquelin on 23/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (AddOn)

+ (UIFont *)bim_avenirMediumWithSizeAndWithoutChangeSize:(CGFloat)size;
+ (UIFont *)bim_avenirNextRegularWithSizeAndWithoutChangeSize:(CGFloat)size;
+ (UIFont *)bim_avenirNextMediumWithSizeAndWithoutChangeSize:(CGFloat)size;
+ (UIFont *)bim_avenirNextCondensedRegularWithSizeAndWithoutChangeSize:(CGFloat)size;
+ (UIFont *)bim_avenirNextUltraLightWithSizeAndWithoutChangeSize:(CGFloat)size;

+ (UIFont *)bim_avenirMediumWithSize:(CGFloat)size;
+ (UIFont *)bim_avenirNextRegularWithSize:(CGFloat)size;
+ (UIFont *)bim_avenirNextMediumWithSize:(CGFloat)size;
+ (UIFont *)bim_avenirNextCondensedRegularWithSize:(CGFloat)size;
+ (UIFont *)bim_avenirNextUltraLightWithSize:(CGFloat)size;

@end
