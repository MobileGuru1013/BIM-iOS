//
//  BIMSchedulePlace.m
//  BIM
//
//  Created by Alexis Jacquelin on 05/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMSchedulePlaceView.h"
#import "BIMHours.h"
#import "BIMHoursView.h"

@interface BIMSchedulePlaceView() {
}

@property (nonatomic, assign) CGFloat totalHeight;

@end

@implementation BIMSchedulePlaceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        @weakify(self);
        [[RACObserve(self, place) filter:^BOOL(id value) {
            return value ? YES : NO;
        }]  subscribeNext:^(BIMPlace *place_) {
            @strongify(self);
            
            CGFloat offsetY = 0;
            for (BIMHours *hours in place_.hours) {
                for (BIMOpen *open in hours.opens) {
                    BIMHoursView *hoursView = [[BIMHoursView alloc] initWithHours:hours andOpen:open];
                    [self addSubview:hoursView];
                    [hoursView autoSetDimension:ALDimensionHeight toSize:[hoursView totalHeight]];
                    [hoursView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
                    [hoursView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
                    [hoursView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self withOffset:offsetY];
                    
                    offsetY += [hoursView totalHeight];
                }
            }
            self.totalHeight = offsetY;
        }];
    }
    return self;
}

@end