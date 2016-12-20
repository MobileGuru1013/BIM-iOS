//
//  BIMLabelWalking.m
//  Bim
//
//  Created by Alexis Jacquelin on 27/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMLabelWalkingDead.h"
#import "BIMActivityView.h"

#define MAX_DURATION 5940

@interface BIMLabelWalkingDead() {
}

@property (nonatomic, assign) BOOL wsRunning;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) BIMActivityView *customActivityLoader;

@end

@implementation BIMLabelWalkingDead

#pragma mark -
#pragma mark - Lazy Loading

- (BIMActivityView *)customActivityLoader {
    if (_customActivityLoader == nil) {
        _customActivityLoader = [[BIMActivityView alloc] initWithImage:[UIImage imageNamed:@"white-loader"]];
        [self addSubview:self.customActivityLoader];
    }
    return _customActivityLoader;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager == nil) {
        NSURL *url = [NSURL URLWithString:BASE_URL_GOOGLE_API];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 10;
        
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _sessionManager;
}

- (void)setPlace:(BIMPlace *)place {
    if (place != _place) {
        _place = place;

        [self.task cancel];
        
        if (_place) {
            if (self.location) {
                [self callWS];
            } else {
                self.wsRunning = YES;
                [[self locationSignal] subscribeNext:^(CLLocation *location) {
                    self.location = location;
                    [self callWS];
                } error:^(NSError *error) {
                    self.wsRunning = NO;
                }];
            }
        }
    }
}

#pragma mark -
#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.customActivityLoader.center = CGPointMake(round(self.width / 2), round(self.height / 2));
    
    [RACObserve(self, wsRunning) subscribeNext:^(NSNumber *wsRunning_) {
        if ([wsRunning_ boolValue]) {
            self.text = nil;
            [self.customActivityLoader startAnimatingView];
        } else {
            [self.customActivityLoader stopAnimatingView];
        }
    }];
}

- (void)callWS {
    if (!self.place.address) {
        SKYLog(@"Place %@ doesn't have an address", self.place);
        return;
    }
    NSString *origin = [NSString stringWithFormat:@"%f,%f", self.location.coordinate.latitude, self.location.coordinate.longitude];
    NSDictionary *params = @{
                             @"origins" : origin,
                             @"destinations" : self.place.address,
                             @"mode" : @"walking",
                             @"language" : SKYTrad(@"langue"),
                             @"key" : GOOGLE_API_KEY
                             };
    
    self.wsRunning = YES;
    self.task = [self.sessionManager GET:@"/maps/api/distancematrix/json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        self.wsRunning = NO;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    @try {
                        NSNumber *duration = responseObject[@"rows"][0][@"elements"][0][@"duration"][@"value"];
                        if ([duration doubleValue] < MAX_DURATION && [duration doubleValue] > 0) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                self.text = [NSString stringWithFormat:@"%.0f'", round([duration integerValue] / 60)];
                            });
                        }
                    }
                    @catch (NSException *exception) {
                        SKYLog(@"ERROR RESPONSE PARSING");
                    }
                } else {
                    SKYLog(@"ERROR RESPONSE EMPTY");
                }
            });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self.wsRunning = NO;
    }];
}

- (RACSignal *)locationSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[MMPReactiveCoreLocation instance]
           singleLocationSignalWithAccuracy:kCLLocationAccuracyHundredMeters timeout:15.0]
          deliverOn:[RACScheduler mainThreadScheduler]]
         subscribeNext:^(CLLocation *location) {
             [subscriber sendNext:location];
             [subscriber sendCompleted];
         }
         error:^(NSError *error) {
             NSError *errorBIM = [error getFormartedErrorForRACSignalLocationError];
             [subscriber sendError:errorBIM];
         }];
        return nil;
    }];
}

@end
