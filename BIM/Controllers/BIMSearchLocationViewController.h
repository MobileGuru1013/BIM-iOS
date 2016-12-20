//
//  BIMSearchLocationViewController.h
//  BIM
//
//  Created by Alexis Jacquelin on 27/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMViewController.h"

@class BIMGooglePlace;

@interface BIMSearchLocationViewController : BIMViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet BIMSearchBar *searchBar;
@property (nonatomic, strong) BIMGooglePlace *googlePlace;

@end
