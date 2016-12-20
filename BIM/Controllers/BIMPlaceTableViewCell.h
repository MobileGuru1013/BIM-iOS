//
//  BIMPlaceTableViewCell.h
//  BIM
//
//  Created by Alexis Jacquelin on 30/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIMPlace.h"

@interface BIMPlaceTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *placeIV;
@property (nonatomic, weak) IBOutlet UIImageView *bottomOverlay;
@property (weak, nonatomic) IBOutlet UIImageView *categoryIV;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;

@property (nonatomic, weak) BIMPlace *placeObject;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *placeLabelTrailing;

@end
