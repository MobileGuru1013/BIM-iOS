//
//  BIMChoosePlaceView.h
//  BIM
//
//  Created by Alexis Jacquelin on 22/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "MDCSwipeToChooseView.h"
#import "BIMPlace.h"
#import "BIMScheduleView.h"

@interface BIMChoosePlaceView : MDCSwipeToChooseView

@property (nonatomic, strong, readonly) BIMPlace *place;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) BIMScheduleView *scheduleView;

- (instancetype)initWithFrame:(CGRect)frame andPlace:(BIMPlace *)place withOptions:(MDCSwipeToChooseViewOptions *)options;

- (void)cancelPanGesture;

@end
