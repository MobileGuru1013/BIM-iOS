//
//  UIDevice+Hardware.h
//  TestTable
//
//  Created by Inder Kumar Rathore on 19/01/13.
//  Copyright (c) 2013 Rathore. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
#define DEVICE_HARDWARE_BETTER_THAN(i) [[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:i]

#define DEVICE_HAS_RETINA_DISPLAY (fabs([UIScreen mainScreen].scale - 2.0) <= fabs([UIScreen mainScreen].scale - 2.0)*DBL_EPSILON)

#define IS_SCREEN_HEIGHT_EQUAL(SCREEN_HEIGHT_VALUE) (MAX([UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width)==SCREEN_HEIGHT_VALUE)
#define IS_IPHONE_5         ( IS_IPHONE && IS_SCREEN_HEIGHT_EQUAL(568.0) )
#define IS_SIMULATOR        ( [UIDevice currentDevice].hardware==SIMULATOR )
#define IS_IPHONE_6         ( IS_IPHONE && ([UIDevice currentDevice].hardware==IPHONE_6 || IS_SCREEN_HEIGHT_EQUAL(667.0)) )
#define IS_IPHONE_6_PLUS    ( IS_IPHONE && ([UIDevice currentDevice].hardware==IPHONE_6_PLUS || IS_SCREEN_HEIGHT_EQUAL(736.0)) )

typedef enum
{
  NOT_AVAILABLE,
  
  IPHONE_2G,
  IPHONE_3G,
  IPHONE_3GS,
  IPHONE_4,
  IPHONE_4_CDMA,
  IPHONE_4S,
  IPHONE_5,
  IPHONE_5_CDMA_GSM,
  IPHONE_5C,
  IPHONE_5C_CDMA_GSM,
  IPHONE_5S,
  IPHONE_5S_CDMA_GSM,

  IPHONE_6_PLUS,
  IPHONE_6,

  IPOD_TOUCH_1G,
  IPOD_TOUCH_2G,
  IPOD_TOUCH_3G,
  IPOD_TOUCH_4G,
  IPOD_TOUCH_5G,

  IPAD,
  IPAD_2,
  IPAD_2_WIFI,
  IPAD_2_CDMA,
  IPAD_3,
  IPAD_3G,
  IPAD_3_WIFI,
  IPAD_3_WIFI_CDMA,
  IPAD_4,
  IPAD_4_WIFI,
  IPAD_4_GSM_CDMA,

  IPAD_MINI,
  IPAD_MINI_WIFI,
  IPAD_MINI_WIFI_CDMA,
  IPAD_MINI_RETINA_WIFI,
  IPAD_MINI_RETINA_WIFI_CDMA,
  IPAD_MINI_3_WIFI,
  IPAD_MINI_3_WIFI_CELLULAR,
  IPAD_MINI_RETINA_WIFI_CELLULAR_CN,

  IPAD_AIR_WIFI,
  IPAD_AIR_WIFI_GSM,
  IPAD_AIR_WIFI_CDMA,
  IPAD_AIR_2_WIFI,
  IPAD_AIR_2_WIFI_CELLULAR,

  SIMULATOR
} Hardware;


@interface UIDevice (Hardware)
/** This method retruns the hardware type */
+ (NSString*)hardwareString;

/** This method returns the Hardware enum depending upon harware string */
+ (Hardware)hardware;

/** This method returns the readable description of hardware string */
+ (NSString*)hardwareDescription;

/** This method returs the readble description without identifier (GSM, CDMA, GLOBAL) */
+ (NSString *)hardwareSimpleDescription;

/** This method returns YES if the current device is better than the hardware passed */
+ (BOOL)isCurrentDeviceHardwareBetterThan:(Hardware)hardware;

/** This method returns the resolution for still image that can be received
 from back camera of the current device. Resolution returned for image oriented landscape right. **/
+ (CGSize)backCameraStillImageResolutionInPixels;

@end
