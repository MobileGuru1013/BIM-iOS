//
//  NSObject+Device.h
//  Bim
//
//  Created by Alexis Jacquelin on 24/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Device)

+ (BOOL)bim_isRetina;
+ (NSString *)bim_deviceDescription;

@end
