//
//  BIMGooglePlaceTableViewCell.h
//  BIM
//
//  Created by Alexis Jacquelin on 28/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIMGooglePlace.h"

@interface BIMGooglePlaceTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *descriptionGooglePlaceLabel;

@property (nonatomic, weak) BIMGooglePlace *googlePlace;

@end
