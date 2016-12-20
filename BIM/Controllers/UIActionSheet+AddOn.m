//
//  UIActionSheet+AddOn.m
//  Bim
//
//  Created by Alexis Jacquelin on 27/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "UIActionSheet+AddOn.h"

@implementation UIActionSheet (AddOn)

+ (UIActionSheet *)getShareActionSheet {
    UIActionSheet *actionSheet = nil;
    //Cannot edit the other button title after created the actionSheet :(
    if ([MFMessageComposeViewController canSendText] &&
        [MFMailComposeViewController canSendMail]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:SKYTrad(@"actionsheet.share.title") delegate:nil cancelButtonTitle:SKYTrad(@"cancel") destructiveButtonTitle:nil otherButtonTitles:SKYTrad(@"place.share.on.message"), SKYTrad(@"place.share.on.mail"), SKYTrad(@"place.share.on.facebook"), nil];
    } else if ([MFMailComposeViewController canSendMail]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:SKYTrad(@"actionsheet.share.title") delegate:nil cancelButtonTitle:SKYTrad(@"cancel") destructiveButtonTitle:nil otherButtonTitles:SKYTrad(@"place.share.on.mail"), SKYTrad(@"place.share.on.facebook"), nil];
    } else if ([MFMessageComposeViewController canSendText]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:SKYTrad(@"actionsheet.share.title") delegate:nil cancelButtonTitle:SKYTrad(@"cancel") destructiveButtonTitle:nil otherButtonTitles:SKYTrad(@"place.share.on.message"), SKYTrad(@"place.share.on.facebook"), nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:SKYTrad(@"actionsheet.share.title") delegate:nil cancelButtonTitle:SKYTrad(@"cancel") destructiveButtonTitle:nil
            otherButtonTitles:SKYTrad(@"place.share.on.facebook"), nil];
    }
    return actionSheet;
}

@end
