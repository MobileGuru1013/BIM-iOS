//
//  BIMHoursView.m
//  Bim
//
//  Created by Alexis Jacquelin on 15/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMHoursView.h"

@implementation BIMHoursView

- (BIMHoursView *)initWithHours:(BIMHours *)hours andOpen:(BIMOpen *)open {
    self = [super initWithFrame:CGRectMake(0, 0, WIDTH_DEVICE - 30, [self totalHeight])];
    if (self) {
        //Title
        UILabel *labelTitle = [UILabel new];
        labelTitle.text = [hours getTitle];
        labelTitle.numberOfLines = 1;
        labelTitle.textAlignment = NSTextAlignmentCenter;
        [labelTitle setBackgroundColor:[UIColor clearColor]];
        labelTitle.textColor = [UIColor whiteColor];
        labelTitle.font = [UIFont bim_avenirNextUltraLightWithSize:13.5f];
        [self addSubview:labelTitle];
        
        [labelTitle autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [labelTitle autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        [labelTitle autoSetDimension:ALDimensionHeight toSize:15];
        [labelTitle autoPinEdgeToSuperviewEdge:ALEdgeTop];
        
        //Description
        UILabel *labelDescription = [UILabel new];
        labelDescription.text = [open getTitle];
        labelDescription.numberOfLines = 1;
        labelDescription.textAlignment = NSTextAlignmentCenter;
        [labelDescription setBackgroundColor:[UIColor clearColor]];
        labelDescription.textColor = [UIColor whiteColor];
        labelDescription.font = [UIFont bim_avenirNextMediumWithSize:13.5f];
        [self addSubview:labelDescription];
        
        [labelDescription autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [labelDescription autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        [labelDescription autoSetDimension:ALDimensionHeight toSize:15];
        
        CGFloat offset = 0;
        switch ([SDiPhoneVersion deviceSize]) {
            case iPhone47inch:
                offset = 1;
                break;
            case iPhone55inch:
                offset = 3;
                break;
            default:
                break;
        }
        [labelDescription autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:labelTitle withOffset:offset];
    }
    return self;
}

- (CGFloat)totalHeight {
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone47inch:
            return 37;
            break;
        case iPhone55inch:
            return 39;
            break;
        default:
            return 35;
            break;
    }
}

@end
