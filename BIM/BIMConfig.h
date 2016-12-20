//
//  BIMConfig.h
//  BIM
//
//  Created by Alexis Jacquelin on 21/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#ifndef BIM_BIMConfig_h
#define BIM_BIMConfig_h

#define WIDTH_DEVICE [UIScreen mainScreen].applicationFrame.size.width
#define HEIGHT_DEVICE [UIScreen mainScreen].applicationFrame.size.height
#define HEIGHT_STATUS_BAR 20
#define HAS_IN_CALL_STATUS_BAR ([UIApplication sharedApplication].statusBarFrame.size.height != HEIGHT_STATUS_BAR)

#if defined(SKY_PERMISSIONS_FACEBOOK_READ)
#undef SKY_PERMISSIONS_FACEBOOK_READ
#endif
#define SKY_PERMISSIONS_FACEBOOK_READ @[@"email", @"user_friends"]

#define MIXPANEL_TOKEN @"0211ec1bac5a74e9a51775c75ff01593"

#define GOOGLE_API_KEY @"AIzaSyDblr5k3iKhXheZUswl9lUTYPdU0QEvHI8"
#define BASE_URL_GOOGLE_API @"https://maps.googleapis.com"

#define GURU_RECIPIENTS @[@"founders@bimapp.io"]
#define FEEDBACK_RECIPIENTS @[@"founders@bimapp.io"]

//Notif
#define NOTIF_REACHABLE @"NOTIF_REACHABLE"

#define CGU_URL @"http://557f676446.url-de-test.ws/cgu.php"
#define LEGALES_URL @"http://557f676446.url-de-test.ws/mentions-legales.php"

#endif
