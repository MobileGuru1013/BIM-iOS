//
//  UISearchBar+RAC.m
//  BIM
//
//  Created by Alexis Jacquelin on 28/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "UISearchBar+RAC.h"

@implementation UISearchBar (RAC)

- (RACSignal *)rac_textSignal {
    RACSignal *textSignal = objc_getAssociatedObject(self, _cmd);
    if (textSignal != nil) return textSignal;

    textSignal = [[[self rac_signalForSelector:@selector(searchBar:textDidChange:) fromProtocol:@protocol(UISearchBarDelegate)] map:^id(RACTuple *tuple) {
        return tuple.second;
    }] replay];
    objc_setAssociatedObject(self, _cmd, textSignal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.delegate = self;
    return textSignal;
}

- (RACSignal *)rac_searchingSignal {
    RACSignal *searchingSignal = objc_getAssociatedObject(self, _cmd);
    if (searchingSignal != nil) return searchingSignal;
    
    /* Create two signals and merge them */
    RACSignal *didBeginEditing = [[self rac_signalForSelector:@selector(searchBarTextDidBeginEditing:)
                                                 fromProtocol:@protocol(UISearchBarDelegate)] mapReplace:@YES];
    RACSignal *didEndEditing = [[self rac_signalForSelector:@selector(searchBarTextDidEndEditing:)
                                               fromProtocol:@protocol(UISearchBarDelegate)] mapReplace:@NO];
    searchingSignal = [RACSignal merge:@[didBeginEditing, didEndEditing]];
    
    objc_setAssociatedObject(self, _cmd, searchingSignal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.delegate = self;
    return searchingSignal;
}

@end
