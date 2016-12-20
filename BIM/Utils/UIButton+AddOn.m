//
//  UIButton+AddOn.m
//  BIM
//
//  Created by Alexis Jacquelin on 30/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "UIButton+AddOn.h"

@implementation UIButton (AddOn)

+ (UIButton *)bim_getBackBtn {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"back-btn"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0, 0, 40, 40);
    return backBtn;
}

+ (UIButton *)bim_getSettingsBtn {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"settings-btn"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0, 0, 40, 40);

    return backBtn;
}

+ (UIButton *)bim_getMapBtn {
    UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapBtn setImage:[UIImage imageNamed:@"places-map-btn"] forState:UIControlStateNormal];
    [mapBtn setImage:[UIImage imageNamed:@"places-list-btn"] forState:UIControlStateSelected];
    mapBtn.frame = CGRectMake(0, 0, 45, 45);
    
    return mapBtn;
}

@end
