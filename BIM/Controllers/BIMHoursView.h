//
//  BIMHoursView.h
//  Bim
//
//  Created by Alexis Jacquelin on 15/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIMHours.h"
#import "BIMOpen.h"

@interface BIMHoursView : UIView

- (BIMHoursView *)initWithHours:(BIMHours *)hours andOpen:(BIMOpen *)open;
- (CGFloat)totalHeight;

@end
