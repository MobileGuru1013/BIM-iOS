//
//  BIMCategoriesViewController.h
//  BIM
//
//  Created by Alexis Jacquelin on 21/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMViewController.h"
#import "BIMMainContainerViewController.h"
#import "BIMCategoryButton.h"
#import "BIMEuroButton.h"

@protocol BIMCategoryDelegate;

static NSString * const kModeLocation = @"kModeLocation";
static NSString * const kCategoryChoice = @"kCategoryChoice";
static NSString * const kEuroChoice = @"kEuroChoice";

static NSString * const kRefreshLocation = @"kRefreshLocation";

@interface BIMCategoriesViewController : BIMViewController <BIMSliderViewControllerProtocol>

@property (strong, nonatomic) IBOutletCollection(BIMCategoryButton) NSArray *categoryBtns;
@property (strong, nonatomic) IBOutletCollection(BIMEuroButton) NSArray *euroBtns;
@property (weak, nonatomic) IBOutlet BIMBottomButtonWithLoader *aroundMeButton;
@property (weak, nonatomic) IBOutlet BIMBottomButton *somewhereElseButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoIV;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightCategoryBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthEuroBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topCategoryBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerXEuroBtn;

@property (nonatomic, weak) id <BIMCategoryDelegate>categoryDelegate;

- (void)refreshLocation;

@end
