//
//  AppDelegate.m
//  BIM
//
//  Created by Alexis Jacquelin on 21/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "BIMLoginViewController.h"
#import "BIMAPIClient.h"
#import "BIMCategoriesViewController.h"

static NSString *KAlreadyLaunched = @"KAlreadyLaunched";

@interface BIMAppDelegate () {
}

@property (nonatomic, strong) UIWindow *reachabilityWindow;

@end

@implementation BIMAppDelegate


#pragma mark -
#pragma mark - LazyLoad

- (UIWindow *)reachabilityWindow {
    if (_reachabilityWindow == nil) {
        _reachabilityWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, -20, WIDTH_DEVICE, 20)];
        _reachabilityWindow.backgroundColor = [UIColor bim_blackColor];
        _reachabilityWindow.windowLevel = UIWindowLevelStatusBar;
        _reachabilityWindow.userInteractionEnabled = YES;
        _reachabilityWindow.hidden = YES;
        _reachabilityWindow.alpha = 0;
        
        UILabel *errorMsg = [[UILabel alloc] initWithFrame:_reachabilityWindow.bounds];
        errorMsg.textColor = [UIColor whiteColor];
        errorMsg.backgroundColor = [UIColor clearColor];
        [errorMsg setFont:[UIFont bim_avenirNextRegularWithSizeAndWithoutChangeSize:13]];
        errorMsg.text = SKYTrad(@"reachability.no.network");
        errorMsg.textAlignment = NSTextAlignmentCenter;
        [_reachabilityWindow addSubview:errorMsg];
    }
    return _reachabilityWindow;
}

#pragma mark -
#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (![USER_DEFAULT objectForKey:KAlreadyLaunched]) {
        [[BIMAPIClient sharedClient] logout];
        [USER_DEFAULT setObject:@YES forKey:KAlreadyLaunched];
        [USER_DEFAULT setObject:@YES forKey:kModeLocation];
        
        [USER_DEFAULT synchronize];
    }
    
    [Fabric with:@[CrashlyticsKit]];
    
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    if (NSProcessInfo.processInfo.environment[BIMClientResponseLoggingEnvironmentKey] != nil) {
        [[AFNetworkActivityLogger sharedLogger] startLogging];
    }
    
    if ([BIMAPIClient sharedClient].isAuthenticated == NO) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BIMLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"BIMLoginViewController"];
        self.window.rootViewController = loginVC;
    }
    [self registerForPushNotifications];

    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NOTIFICATION_CENTER postNotificationName:SKYReachabilityChangedNotification object:nil userInfo:@{@"status": @(status)}];
        });
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(showReachabilityView:) name:SKYReachabilityChangedNotification object:nil];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[url scheme] isEqualToString:@"fb875228985821657"]) {
        return [FBSession.activeSession handleOpenURL:url];
    } else {
        return NO;
    }
}

- (void)registerForPushNotifications {
    if (IOS8) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                                                             |UIUserNotificationTypeSound
                                                                                             |UIUserNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeSound)];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    [BIMAPIClient sharedClient].tokenPush = newToken;
    [BIMAPIClient sharedClient].deviceToken = deviceToken;
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    SKYLog(@"Error in registration. Error: %@", error);
}

#pragma mark -
#pragma mark - Reachability

- (void)showReachabilityView:(NSNotification *)notification {
    NSNumber *nb = notification.userInfo[@"status"];
    if (![nb isKindOfClass:[NSNumber class]]) {
        SKYLog(@"STATUS UNKNOWN");
        return;
    }
    switch ((AFNetworkReachabilityStatus)[nb integerValue]) {
        case AFNetworkReachabilityStatusNotReachable:
            [self showReachabilityErrorWindow];
            break;
        default:
            [self hideReachabilityErrorWindow];
            [NOTIFICATION_CENTER postNotificationName:NOTIF_REACHABLE object:nil];
            break;
    }
}
- (void)showReachabilityErrorWindow {
    self.reachabilityWindow.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.reachabilityWindow.alpha = 1;
        self.reachabilityWindow.top = 0;
    }];
}

- (void)hideReachabilityErrorWindow {
    [UIView animateWithDuration:0.3 animations:^{
        self.reachabilityWindow.alpha = 0;
        self.reachabilityWindow.top = -20;
    } completion:^(BOOL finished) {
        self.reachabilityWindow.hidden = YES;
    }];
}

@end
