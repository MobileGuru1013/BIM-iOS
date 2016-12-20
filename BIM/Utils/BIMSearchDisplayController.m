//
//  BIMSearchDisplayController.m
//  BIM
//
//  Created by Alexis Jacquelin on 28/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMSearchDisplayController.h"

@implementation BIMSearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    [super setActive:visible animated:animated];
    
    [self.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
}

@end
