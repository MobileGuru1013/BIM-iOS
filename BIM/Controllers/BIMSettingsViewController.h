//
//  BIMSettingsViewController.h
//  BIM
//
//  Created by Alexis Jacquelin on 31/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMViewController.h"

@interface BIMSettingsViewController : BIMViewController

@property (weak, nonatomic) IBOutlet UIImageView *logoIV;
@property (weak, nonatomic) IBOutlet UIButton *feedbackBtn;
@property (weak, nonatomic) IBOutlet UIButton *guruBtn;
@property (weak, nonatomic) IBOutlet UIButton *disconnectBtn;
@property (weak, nonatomic) IBOutlet UIButton *policyBtn;
@property (weak, nonatomic) IBOutlet UIButton *cguBtn;
@property (weak, nonatomic) IBOutlet UIView *blueCircle;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthCircleConstraint;

@end
