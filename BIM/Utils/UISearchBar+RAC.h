//
//  UISearchBar+RAC.h
//  BIM
//
//  Created by Alexis Jacquelin on 28/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISearchBar (RAC) <UISearchBarDelegate>

- (RACSignal *)rac_textSignal;
- (RACSignal *)rac_searchingSignal;

@end
