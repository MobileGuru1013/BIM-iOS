//
//  BIMScheduleView.h
//  BIM
//
//  Created by Alexis Jacquelin on 22/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BIMScheduleModeColor) {
    BIMScheduleModeColorGreen,
    BIMScheduleModeColorWhite
};

typedef NS_ENUM(NSUInteger, BIMScheduleModeState) {
    BIMScheduleModeStateUnknown,
    BIMScheduleModeStateOpen,
    BIMScheduleModeStateClose
};

@interface BIMScheduleView : UIView

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) BIMScheduleModeColor mode;

+ (CGFloat)scheduleWidthWithMode:(BIMScheduleModeColor)mode;
+ (CGFloat)scheduleHeight;

@end
