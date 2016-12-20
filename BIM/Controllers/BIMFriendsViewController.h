//
//  BIMFriendsViewController.h
//  BIM
//
//  Created by Alexis Jacquelin on 21/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMViewController.h"
#import "BIMMainContainerViewController.h"

@interface BIMFriendsViewController : BIMViewController <BIMSliderViewControllerProtocol, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet BIMSearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noPlaceHolderLabel;

@end
