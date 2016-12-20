//
//  BIMFriendTableViewCell.h
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIMUser.h"

@interface BIMFriendTableViewCell : UITableViewCell

@property (nonatomic, weak) BIMUser *friendObject;

@property (nonatomic, weak) IBOutlet UIImageView *userIV;
@property (nonatomic, weak) IBOutlet UIImageView *arrowIV;
@property (nonatomic, weak) IBOutlet UILabel *userDescriptionLabel;

@end
