//
//  BIMNavigationBar.m
//  BIM
//
//  Created by Alexis Jacquelin on 27/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMNavigationBar.h"

@implementation BIMNavigationBar

#pragma mark -
#pragma mark - View Cycle

+(void)initialize {
    [super initialize];
    [[BIMNavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //Set image background transparent
    UIImage *navbar = [UIImage imageNamed:@"translucent-bg"];
    [[BIMNavigationBar appearance] setBackgroundImage:navbar forBarMetrics:UIBarMetricsDefault];
    
    [[BIMNavigationBar appearance] setTitleTextAttributes:@{
                                                            NSForegroundColorAttributeName : [UIColor whiteColor],
                                                            NSFontAttributeName : [UIFont bim_avenirNextRegularWithSizeAndWithoutChangeSize:16.5]
                                                            }];
}

@end
