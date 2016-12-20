//
//  BIMGooglePlaceTableViewCell.m
//  BIM
//
//  Created by Alexis Jacquelin on 28/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMGooglePlaceTableViewCell.h"

@implementation BIMGooglePlaceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.descriptionGooglePlaceLabel.textColor = [UIColor whiteColor];
    self.descriptionGooglePlaceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    
    [RACObserve(self, googlePlace) subscribeNext:^(BIMGooglePlace *googlePlace_) {
        self.descriptionGooglePlaceLabel.text = [googlePlace_ getDescriptionPlace];
    }];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    [self customizeForSelection:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    [self customizeForSelection:selected];
}

- (void)customizeForSelection:(BOOL)selected {
    if (selected) {
        [self setBackgroundColor:[UIColor bim_darkBlueColor]];
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
    }
}

@end
