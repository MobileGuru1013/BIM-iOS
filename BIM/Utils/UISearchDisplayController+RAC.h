//
//  UISearchDisplayController+RAC.h
//  BIM
//
//  Created by Alexis Jacquelin on 28/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISearchDisplayController (RAC) <UISearchDisplayDelegate>

- (RACSignal *)rac_isActiveSignal;

@end
