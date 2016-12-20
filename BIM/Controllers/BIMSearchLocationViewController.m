//
//  BIMSearchLocationViewController.m
//  BIM
//
//  Created by Alexis Jacquelin on 27/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMSearchLocationViewController.h"
#import "BIMGooglePlaceTableViewCell.h"
#import "UISearchBar+RAC.h"
#import "UISearchDisplayController+RAC.h"
#import "BIMCategoriesViewController.h"
#import "BIMGooglePlace.h"

static NSUInteger const kCellHeightNormal = 53;
static NSUInteger const kCellHeightBig = 103;

static NSString * const kCellIdentifierGooglePlace = @"BIMGooglePlaceTableViewCell";

@interface BIMSearchLocationViewController () {
    CGFloat sizeCell;
}

@property (nonatomic, strong) NSArray *placeSearchedDataSource;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, assign) BOOL searching;
@property (nonatomic, assign) BOOL wsRunning;
@property (nonatomic, strong) BIMButtonWithLoader *animatedBtn;

@end

@implementation BIMSearchLocationViewController

#pragma mark -
#pragma mark - Lazy Loading

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager == nil) {
        NSURL *url = [NSURL URLWithString:BASE_URL_GOOGLE_API];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 20;

        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _sessionManager;
}

#pragma mark -
#pragma mark - View Cycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.searchBar resignFirstResponder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (IOS8) {
        self.view.top = 64;
        self.view.height = self.navigationController.view.height - self.view.top;
        self.navigationController.navigationBar.top = 20;
    }
}

#pragma mark -
#pragma mark - Look & Feel

- (void)customize {
    [super customize];
    
    sizeCell = kCellHeightNormal;
    self.title = SKYTrad(@"search.location.title");
    self.searchBar.placeholder = SKYTrad(@"search.location.searchbar.placeholder");

    if (self.googlePlace) {
        self.searchBar.text = self.googlePlace.name;
    }
    [self addCloseBtnOnNavigationItem:self.navigationItem];
    [self addAnimatedItem];

    [self.tableView registerNib:[UINib nibWithNibName:kCellIdentifierGooglePlace bundle:nil] forCellReuseIdentifier:kCellIdentifierGooglePlace];
    
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kCellIdentifierGooglePlace bundle:nil] forCellReuseIdentifier:kCellIdentifierGooglePlace];

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [UIView new];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor clearColor];
    self.searchDisplayController.searchResultsTableView.backgroundView = [UIView new];
    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.searchDisplayController.searchResultsTableView setShowsVerticalScrollIndicator:NO];

    @weakify(self);
    [[[self.searchBar rac_textSignal] throttle:.3] subscribeNext:^(NSString *text) {
       @strongify(self);
        [self searchTextTyped:text];
    }];
    
    RAC(self, searching) = [[self.searchDisplayController rac_isActiveSignal] doNext:^(NSNumber *searching_) {
        if ([searching_ boolValue]) {
            @strongify(self);
            self.placeSearchedDataSource = nil;
        }
    }];
    
    [RACObserve(self, placeSearchedDataSource) subscribeNext:^(id x) {
        @strongify(self);
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        [self setPlaceHolderOnSearchController:nil];
    }];
    
    [RACObserve(self, wsRunning) subscribeNext:^(NSNumber *running_) {
        if ([running_ boolValue]) {
            [self.animatedBtn startLoader];
        } else {
            [self.animatedBtn stopLoader];
        }
    }];
}

- (void)setPlaceHolderOnSearchController:(NSString *)placeholder {
    UITableView *tableView = self.searchDisplayController.searchResultsTableView;
    UILabel *placeHolderLabel = nil;
    for( UIView *subview in tableView.subviews ) {
        if( [subview class] == [UILabel class] ) {
            placeHolderLabel = (UILabel *)subview;
            break;
        }
    }
    placeHolderLabel.text = placeholder;
}

- (void)searchTextTyped:(NSString *)string {
    [[[self searchWith:string]
    deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id response) {
         if (self.placeSearchedDataSource.count == 0) {
             [self displayTableView];
         }
         self.placeSearchedDataSource = response;
     } error:^(NSError *error) {
        self.placeSearchedDataSource = nil;
        switch ((BIMSearchLocationError)error.code) {
            case BIMSearchLocationEmpty:
                [self setPlaceHolderOnSearchController:SKYTrad(@"search.location.placeholder.empty")];
                break;
            case BIMSearchLocationNotFound:
                [self setPlaceHolderOnSearchController:SKYTrad(@"search.location.placeholder.not.found")];
                break;
            default:
                break;
        }
    }];
}

- (void)addAnimatedItem {
    self.animatedBtn = [BIMButtonWithLoader buttonWithType:UIButtonTypeCustom];
    [self.animatedBtn setImageLoader:@"white-loader"];
    self.animatedBtn.userInteractionEnabled = NO;
    [self.animatedBtn sizeToFit];
    UIBarButtonItem *animatedItem = [[UIBarButtonItem alloc] initWithCustomView:self.animatedBtn];
    self.navigationItem.rightBarButtonItem = animatedItem;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return sizeCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BIMGooglePlace *googlePlace = self.placeSearchedDataSource[indexPath.row];
    NSData *googleEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:googlePlace];
    [USER_DEFAULT setObject:googleEncodedObject forKey:kModeLocation];
    [USER_DEFAULT synchronize];
    [NOTIFICATION_CENTER postNotificationName:kRefreshLocation object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searching == NO) {
        return 0;
    } else {
        return self.placeSearchedDataSource.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BIMGooglePlaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierGooglePlace forIndexPath:indexPath];
    cell.googlePlace = self.placeSearchedDataSource[indexPath.row];

    return cell;
}

#pragma mark -
#pragma mark - WS

- (RACSignal *)searchWith:(NSString *)address {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *errorEmpty = [NSError getLocationNotFound];
        if ([address length] == 0) {
            [subscriber sendError:errorEmpty];
            return nil;
        }
        NSDictionary *params = @{
                                 @"query" : address,
                                 @"key" : GOOGLE_API_KEY
                                 };
        self.wsRunning = YES;
        NSURLSessionDataTask *task = [self.sessionManager GET:@"/maps/api/place/textsearch/json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            self.wsRunning = NO;
            if ([responseObject isKindOfClass:[NSDictionary class]] &&
                [responseObject[@"results"] count] > 0) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                    @try {
                        NSMutableArray *places = [NSMutableArray new];
                        for (NSDictionary *hashOfPlace in responseObject[@"results"]) {
                            BIMGooglePlace *googlePlace = [MTLJSONAdapter modelOfClass:BIMGooglePlace.class fromJSONDictionary:hashOfPlace error:nil];
                            [places addObject:googlePlace];
                        }
                        [subscriber sendNext:places];
                        [subscriber sendCompleted];
                    }
                    @catch (NSException *exception) {
                        [subscriber sendError:errorEmpty];
                    }
                });
            } else {
                [subscriber sendError:errorEmpty];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            self.wsRunning = NO;
            [subscriber sendError:errorEmpty];
        }];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

- (void) displayTableView {
    sizeCell = kCellHeightBig;
    self.searchDisplayController.searchResultsTableView.alpha = 0;
    
    CGFloat oldTop = self.searchDisplayController.searchResultsTableView.top;
    self.searchDisplayController.searchResultsTableView.top += 60;
    
    [UIView animateWithDuration:.3 animations:^{
        self.searchDisplayController.searchResultsTableView.top = oldTop;
        self.searchDisplayController.searchResultsTableView.alpha = 1;
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->sizeCell = kCellHeightNormal;
        [self.searchDisplayController.searchResultsTableView beginUpdates];
        [self.searchDisplayController.searchResultsTableView endUpdates];
    });
}

@end
