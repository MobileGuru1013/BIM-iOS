//
//  BIMSearchBar.m
//  BIM
//
//  Created by Alexis Jacquelin on 28/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMSearchBar.h"

@implementation BIMSearchBar

#pragma mark -
#pragma mark - View Cycle

+ (void)initialize {
    [super initialize];
    
    [[BIMSearchBar appearance] setBackgroundImage:[UIImage imageNamed:@"dark-sky-blue-background"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[BIMSearchBar appearance] setTintColor:[UIColor whiteColor]];
    [[BIMSearchBar appearance] setImage:[UIImage imageNamed:@"magnifying-icon"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    [[UITextField appearanceWhenContainedIn:[BIMSearchBar class], nil] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"medium-blue-background"]]];
    [[UITextField appearanceWhenContainedIn:[BIMSearchBar class], nil] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.5]];
    [[UITextField appearanceWhenContainedIn:[BIMSearchBar class], nil] setTextColor:[UIColor whiteColor]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews{
    [super layoutSubviews];

    [self setShowsCancelButton:NO animated:NO];
}

@end
