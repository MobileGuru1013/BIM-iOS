//
//  UISearchDisplayController+RAC.m
//  BIM
//
//  Created by Alexis Jacquelin on 28/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "UISearchDisplayController+RAC.h"

@implementation UISearchDisplayController (RAC)

- (RACSignal *)rac_isActiveSignal {
    RACSignal *activeSignal = objc_getAssociatedObject(self, _cmd);
    if (activeSignal != nil) return activeSignal;
    
    /* Create two signals and merge them */
    RACSignal *didBeginEditing = [[self rac_signalForSelector:@selector(searchDisplayControllerDidBeginSearch:)
                                                 fromProtocol:@protocol(UISearchDisplayDelegate)] mapReplace:@YES];
    RACSignal *didEndEditing = [[self rac_signalForSelector:@selector(searchDisplayControllerDidEndSearch:)
                                               fromProtocol:@protocol(UISearchDisplayDelegate)] mapReplace:@NO];
    activeSignal = [RACSignal merge:@[didBeginEditing, didEndEditing]];

    objc_setAssociatedObject(self, _cmd, activeSignal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.delegate = self;
    return activeSignal;
}

@end
