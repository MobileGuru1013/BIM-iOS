//
//  BIMPlacesViewController.h
//  BIM
//
//  Created by Alexis Jacquelin on 30/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMViewController.h"
#import "BIMUser.h"

@interface BIMPlacesViewController : BIMViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet BIMSearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *listView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noPlaceHolderLabel;

@property (nonatomic, strong) BIMUser *user;

@end
