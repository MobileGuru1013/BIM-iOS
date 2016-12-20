//
//  BIMFriendsViewController.m
//  BIM
//
//  Created by Alexis Jacquelin on 21/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMFriendsViewController.h"
#import "BIMFriendTableViewCell.h"
#import "UISearchBar+RAC.h"
#import "BIMPlacesViewController.h"
#import "BIMAPIClient+Friends.h"

/*
call the getFriends WS  +-> the datasource is empty ? +-> display loader
   +               +
   |               |
 success        failure
   |               |
   |               |
   |               +-----> -loader stopped
   |                       -datasource empty ? +->  display placeholder
   v
    -loader stopped
    -add the new friends in friends
    -if friends was empty before ? +-> display tableview


friends changed ? +-YES-> searching ? +--YES--> refresh friendsSearched
                             +
                             |
                             |
                             NO
                             |
                             |
                             v
                    reload tableview
 

friendsSearched changed ? +--YES--> reload tableview

 
a user typed a character on the searchbar ? +---YES---> refresh friendSearched


searchBar became active ? +---YES---> searching = YES
                +
                |
               NO
                |
                v
            searching = NO

 
the offset of the tableview changed ? +-YES--> searchbar resigned
 
 
*/

static NSString * const kCellIdentifierFriend = @"BIMFriendTableViewCell";
static NSString * const kSegueIdentifierPlaces = @"places";

static NSUInteger const kCellHeightNormal = 57;
static NSUInteger const kCellHeightBig = 107;

@interface BIMFriendsViewController () {
    NSInteger sizeCell;
    BIMUser *_user1;
    
    BOOL firstTime;
}

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSArray *friendsSearched;
@property (nonatomic, assign) BOOL searching;

@property (nonatomic, strong) RACDisposable *disposeFriends;

@end

@implementation BIMFriendsViewController

#pragma mark -
#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    [self displayData];
    [self friendsSignal];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self dismissKeyboard];
}

- (void)setUserIVOnTopNavBar {
    CGFloat width = WIDTH_DEVICE;
    CGFloat height = HEIGHT_STATUS_BAR + self.navigationController.navigationBar.height;
    CGSize size = CGSizeMake(width, height);
    
    BIMUser *user = [[BIMAPIClient sharedClient] user];
    NSURL *navBarURL = [user avatarURLWithSize:size];
    if (navBarURL) {
        [self displayUserImageWithURL:navBarURL withSize:size withSearchBar:nil];
    }
}

- (void)reachabilityChanged {
    if (self.friends.count == 0) {
        [self friendsSignal];
    }
}

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    [super customize];
    
    firstTime = YES;
    [self addLoaderOnView:self.view];
    self.searchBar.placeholder = SKYTrad(@"friends.searchbar.placeholder");

    [self.tableView registerNib:[UINib nibWithNibName:kCellIdentifierFriend bundle:nil] forCellReuseIdentifier:kCellIdentifierFriend];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [UIView new];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    self.noPlaceHolderLabel.hidden = YES;

    sizeCell = kCellHeightNormal;
    
    self.noPlaceHolderLabel.text = SKYTrad(@"friends.empty.placeholder");
    self.noPlaceHolderLabel.font = [UIFont bim_avenirNextRegularWithSize:15];
    self.noPlaceHolderLabel.textColor = [UIColor whiteColor];
    
    RAC(self, friendsSearched) = [self rac_liftSelector:@selector(search:) withSignals:self.searchBar.rac_textSignal, nil];
    
    RAC(self, searching) = [self.searchBar rac_searchingSignal];
    
    @weakify(self);
    [RACObserve(self, searching) subscribeNext:^(NSNumber *searching_) {
        @strongify(self);
        if ([searching_ boolValue] == NO) {
            self.searchBar.text = nil;
            [self displayData];
        }
    }];
    
    [RACObserve(self, friendsSearched) subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    [RACObserve(self, friends) subscribeNext:^(id x) {
        @strongify(self);
        if (self.searching) {
            self.friendsSearched = [self search:self.searchBar.text];
        } else {
            [self.tableView reloadData];
        }
    }];
}

- (void)displayData {
    if (self.friends.count == 0) {
        [self displayNoPlaceHolder];
    } else {
        [self displayTableView];
    }
}

- (void)displayTableView {
    if (self.tableView.hidden == YES) {
        sizeCell = kCellHeightBig;
        self.noPlaceHolderLabel.hidden = YES;
        self.tableView.hidden = NO;
        self.tableView.alpha = 0;
        
        CGFloat oldTop = self.tableView.top;
        self.tableView.top += 60;
        
        [UIView animateWithDuration:.3 animations:^{
            self.tableView.top = oldTop;
            self.tableView.alpha = 1;
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->sizeCell = kCellHeightNormal;
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        });
    } else {
        [self.tableView reloadData];
    }
}

- (void)displayNoPlaceHolder {
    self.tableView.hidden = YES;
    self.noPlaceHolderLabel.hidden = NO;
    self.noPlaceHolderLabel.alpha = 0;
    
    CGFloat oldTop = self.noPlaceHolderLabel.top;
    self.noPlaceHolderLabel.top += 20;
    [UIView animateWithDuration:.3 animations:^{
        self.noPlaceHolderLabel.alpha = 1;
        self.noPlaceHolderLabel.top = oldTop;
    }];
}

- (NSArray *)search:(NSString *)searchText {
    if (searchText.length == 0) {
        return self.friends;
    } else {
        NSMutableArray *results = [NSMutableArray new];
        for (BIMUser *user in self.friends) {
            if ([[user getDescriptionUser].lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound) {
                [results addObject:user];
            }
        }
        return results.copy;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifierPlaces]) {
        NSParameterAssert([sender isKindOfClass:[BIMUser class]]);
        BIMPlacesViewController *placesVC = segue.destinationViewController;
        placesVC.user = (BIMUser *)sender;
    }
}

- (void)dismissKeyboard {
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BIMUser *user = nil;
    if (self.searching && self.searchBar.text.length > 0) {
        user = self.friendsSearched[indexPath.row];
    } else {
        user = self.friends[indexPath.row];
    }
    if (IOS8) {
        [self performSegueWithIdentifier:kSegueIdentifierPlaces sender:user];
    } else {
        BIMPlacesViewController *placesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BIMPlacesViewController"];
        placesVC.user = user;
        [self.navigationController pushViewController:placesVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return sizeCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searching) {
        return [self.friendsSearched count];
    } else {
        return [self.friends count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BIMFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierFriend forIndexPath:indexPath];
    
    if (self.searching) {
        [cell setFriendObject:self.friendsSearched[indexPath.row]];
    } else {
        [cell setFriendObject:self.friends[indexPath.row]];
    }

    return cell;
}

#pragma mark -
#pragma mark - BIMSliderViewControllerProtocol

- (void)activeAfterScrolling {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Viewed Friends Page"];
}

- (void)resetVCAfterScrolling {
    [self dismissKeyboard];
}

#pragma mark -
#pragma mark - WS

- (void)friendsSignal {
    if (self.friends.count == 0) {
        self.noPlaceHolderLabel.hidden = YES;
        self.tableView.hidden = YES;

        [self startLoader];
    }
    [self.view layoutIfNeeded];

    __block NSMutableArray *refreshedFriends = [NSMutableArray new];
    @weakify(self);
    [self.disposeFriends dispose];
    self.disposeFriends = [[[BIMAPIClient sharedClient] fetchFriends] subscribeNext:^(BIMUser *friend) {
        [refreshedFriends addObject:friend];
    } error:^(NSError *error) {
        @strongify(self);
        [self stopLoader];
        [self displayData];
    } completed:^{
        @strongify(self);
        //We also add the current user
        [self stopLoader];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel.people set:@"Friends count" to:@(refreshedFriends.count)];
        
        //Sort
        [refreshedFriends sortUsingComparator:^NSComparisonResult(BIMUser *user1, BIMUser *user2) {
            return [[user1 getDescriptionUser] compare:[user2 getDescriptionUser] options:NSCaseInsensitiveSearch];
        }];
        
        BIMUser *currentUser = [BIMAPIClient sharedClient].user;
        if (refreshedFriends.count > 0) {
            [refreshedFriends insertObject:currentUser atIndex:0];
        } else {
            [refreshedFriends addObject:currentUser];
        }
        self.friends = refreshedFriends;
        [self displayData];
        
        if (self->firstTime) {
            [self setUserIVOnTopNavBar];
            self->firstTime = NO;
        }
    }];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self dismissKeyboard];
}

@end
