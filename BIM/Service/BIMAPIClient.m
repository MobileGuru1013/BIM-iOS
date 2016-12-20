//
//  BIMAPIClient.m
//  BIM
//
//  Created by Alexis Jacquelin on 22/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMAPIClient.h"
#import "BIMObject.h"
#import "BIMResponse.h"
#import "NSError+AddOn.h"

NSString * const BIMServerDotComAPIEndpoint = @"https://bimapp.herokuapp.com";
NSString * const BIMServerDotComAPIEndpointStaging = @"https://bimstaging.herokuapp.com";
NSString * const BIMServerEnterpriseAPIEndpointPathComponent = @"api/v1";

NSString * const BIMClientErrorDomain = @"BIMClientErrorDomain";
NSString * const BIMClientErrorRequestURLKey = @"BIMClientErrorRequestURLKey";
NSString * const BIMClientErrorHTTPStatusCodeKey = @"BIMClientErrorHTTPStatusCodeKey";
NSString * const BIMClientErrorDescriptionKey = @"BIMClientErrorDescriptionKey";
NSString * const BIMClientErrorMessagesKey = @"BIMClientErrorMessagesKey";

static const NSInteger BIMClientNotModifiedStatusCode = 304;

NSString * const BIMClientEnvironmentKey = @"STAGING";
NSString * const BIMClientResponseLoggingEnvironmentKey = @"LOG_API_RESPONSES";

static NSString *kSSBIMServiceCredential = @"BIMServiceAuth";
static NSString *kSSBIMFacebookToken = @"BIMFacebookToken";

@interface BIMAPIClient() {
}

@property (nonatomic, strong, readwrite) BIMUser *user;
@property (nonatomic, strong, readwrite) RACMulticastConnection *tokenConnection;

@end

@implementation BIMAPIClient

#pragma mark -
#pragma mark - Lifecycle

+ (instancetype)sharedClient {
    static BIMAPIClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];

        NSURL *urlServer = [NSURL URLWithString:BIMServerDotComAPIEndpoint];
        if (NSProcessInfo.processInfo.environment[BIMClientResponseLoggingEnvironmentKey] != nil) {
            urlServer = [NSURL URLWithString:BIMServerDotComAPIEndpointStaging];
        }
        
        NSURL *APIEndpoint = [urlServer URLByAppendingPathComponent:BIMServerEnterpriseAPIEndpointPathComponent isDirectory:YES];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 20;
        
        sharedClient = [[BIMAPIClient alloc] initWithBaseURL:APIEndpoint sessionConfiguration:config];
        sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        sharedClient.securityPolicy.allowInvalidCertificates = YES;
        
        [sharedClient initializeTokenConnection];
    });
    return sharedClient;
}

- (void)initializeTokenConnection {
    // Defer the invocation of -reallyGetToken until it's actually needed.
    // The -defer: is only necessary if -reallyGetToken might kick off
    // a request immediately.
    RACSignal *deferredToken = [RACSignal defer:^{
        return [self reallyGetToken];
    }];
    // Create a connection which only kicks off -reallyGetToken when
    // -connect is invoked, shares the result with all subscribers, and
    // pushes all results to a replay subject (so new subscribers get the
    // retrieved value too).
    self.tokenConnection = [deferredToken multicast:[RACReplaySubject subject]];
}

#pragma mark -
#pragma mark - Credentials

- (BOOL)isAuthenticated {
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = kSSBIMServiceCredential;
    query.account = kSSBIMFacebookToken;
    
    NSError *error = nil;
    [query fetch:&error];
    if (error) {
        return NO;
    } else {
        if (query.password) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (NSString *)getFacebookToken {
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = kSSBIMServiceCredential;
    query.account = kSSBIMFacebookToken;
    
    NSError *error = nil;
    [query fetch:&error];
    if (error) {
        SKYLog(@"ERROR GETTOKEN %@", error.userInfo);
        return nil;
    } else {
        return query.password;
    }
}

- (void)setFacebookToken:(NSString *)token {
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = kSSBIMServiceCredential;
    query.account = kSSBIMFacebookToken;

    NSError *error = nil;
    if (token) {
        query.password = token;
        [query save:&error];
        if (error) {
            SKYLog(@"ERROR SAVING %@", error.userInfo);
        }
    } else {
        [query deleteItem:&error];
        if (error) {
            SKYLog(@"ERROR LOGOUT %@", error.userInfo);
        }
    }
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
}

- (void)logout {
    [self setFacebookToken:nil];
    [self setUser:nil];
    
    [[SKYFacebookManager sharedSKYFacebookManager] logout];
    
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];

    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [USER_DEFAULT removePersistentDomainForName:appDomain];
    [USER_DEFAULT synchronize];
    
    [self.operationQueue cancelAllOperations];

    RACSignal *deferredToken = [RACSignal defer:^{
        return [self reallyGetToken];
    }];
    self.tokenConnection = [deferredToken multicast:[RACReplaySubject subject]];
}

- (RACSignal *)tokenSignal {
    // Performs the actual fetch if it hasn't started yet.
    [self.tokenConnection connect];
    
    return self.tokenConnection.signal;
}

- (RACSignal *)reallyGetToken {
    //If the user have already a token given vy the loginVC, we don't need to refresh the token
    if (self.user) {
        return [RACSignal return:self.user];
    } else {
        //Else
        //To get a valid token, we need:
        //-check if the fb token is still valid
        //if yes, check if the current token is still valid by calling /me
        //then we set the token return by the WS /me
        //else, we return an error
        return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if ([[SKYFacebookManager sharedSKYFacebookManager] isLoaded] == NO) {
                NSError *errorFacebook = [NSError getAuthentificationFacebookFailed];
                [subscriber sendError:errorFacebook];
            }
            [[SKYFacebookManager sharedSKYFacebookManager] tokenIsValid:^(NSDictionary<FBGraphUser> *infos, NSString *token) {
                [subscriber sendNext:RACTuplePack(infos[@"id"], token)];
            } andFailure:^(NSError *error) {
                [subscriber sendError:error];
                //Reset tokenConnection because there was an error
                RACSignal *deferredToken = [RACSignal defer:^{
                    return [self reallyGetToken];
                }];
                self.tokenConnection = [deferredToken multicast:[RACReplaySubject subject]];
            }];
            return nil;
        }] flattenMap:^RACStream *(RACTuple *tuple) {
            //Reset facebook token
            NSString *facebook_uid = tuple.first;
            BIMUser *user = [BIMUser userWithRawUID:facebook_uid];
            return [self signInAsUser:user token:[self getFacebookToken]];
        }];
    }
}

- (RACSignal *)enqueueRequest:(BIMRequest *)request resultClass:(Class)resultClass {
    return [[[self enqueueRequest:request]
             reduceEach:^(NSHTTPURLResponse *response, id responseObject) {
                 return [[self
                           parsedResponseOfClass:resultClass fromJSON:responseObject]
                          map:^(id parsedResult) {
                              BIMResponse *parsedResponse = [[BIMResponse alloc] initWithHTTPURLResponse:response parsedResult:parsedResult];
                              NSAssert(parsedResponse != nil, @"Could not create BIMResponse with response %@ and parsedResult %@", response, parsedResult);
                              
                              return parsedResponse;
                         }];
             }]
            concat];
}

#pragma mark -
#pragma mark - Request Enqueuing

- (RACSignal *)enqueueRequest:(BIMRequest *)request {
    RACSignal *signal = [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        NSURLSessionTask *task = [self taskForMethod:request.method urlString:request.URLString parameters:request.params success:^(NSURLSessionDataTask *task, id responseObject) {
            NSInteger statusCode = ((NSHTTPURLResponse *)task.response).statusCode;
             if (NSProcessInfo.processInfo.environment[BIMClientResponseLoggingEnvironmentKey] != nil) {
                 SKYLog(@"%@ %@ => %li:\n%@", request.method, request.URLString, (long)statusCode, responseObject);
             }
             if (statusCode == BIMClientNotModifiedStatusCode) {
                 // No change in the data.
                 [subscriber sendCompleted];
                 return;
             }
            //Next page behaviour
            RACSignal *nextPageSignal = [RACSignal empty];
            if (request.fetchAllPages &&
                [responseObject isKindOfClass:[NSArray class]] &&
                [responseObject count] == [request nbObjectsRequest]) {
                BIMRequest *nextRequest = [request nextRequest];
                nextPageSignal = [self enqueueRequest:nextRequest];
            }
            [[[RACSignal return:RACTuplePack(task.response, responseObject)] concat:nextPageSignal] subscribe:subscriber];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:[self.class errorFromTask:task]];
        }];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
    return [[signal replayLazily] setNameWithFormat:@"-enqueueRequest: %@", request];
}

#pragma mark -
#pragma mark - Parsing

- (RACSignal *)parsedResponseOfClass:(Class)resultClass fromJSON:(id)responseObject {
    NSParameterAssert(resultClass == nil || [resultClass isSubclassOfClass:MTLModel.class]);
    
    return [RACSignal createSignal:^ id (id<RACSubscriber> subscriber) {
        void (^parseJSONDictionary)(NSDictionary *) = ^(NSDictionary *JSONDictionary) {
            if (resultClass == nil) {
                [subscriber sendNext:JSONDictionary];
                return;
            }
            
            NSError *error = nil;
            BIMObject *parsedObject = [MTLJSONAdapter modelOfClass:resultClass fromJSONDictionary:JSONDictionary error:&error];
            if (parsedObject == nil) {
                // Don't treat "no class found" errors as real parsing failures.
                // In theory, this makes parsing code forward-compatible with
                // API additions.
                if (![error.domain isEqual:MTLJSONAdapterErrorDomain] || error.code != MTLJSONAdapterErrorNoClassFound) {
                    [subscriber sendError:error];
                }
                return;
            }
            NSAssert([parsedObject isKindOfClass:BIMObject.class], @"Parsed model object is not an BIMObject: %@", parsedObject);
            
            [subscriber sendNext:parsedObject];
        };
        
        if ([responseObject isKindOfClass:NSArray.class]) {
            for (NSDictionary *JSONDictionary in responseObject) {
                if (![JSONDictionary isKindOfClass:NSDictionary.class]) {
                    [subscriber sendError:[NSError getParsingError]];
                    return nil;
                }
                parseJSONDictionary(JSONDictionary);
            }
            [subscriber sendCompleted];
        } else if ([responseObject isKindOfClass:NSDictionary.class]) {
            parseJSONDictionary(responseObject);
            [subscriber sendCompleted];
        } else if (responseObject != nil) {
            [subscriber sendError:[NSError getParsingError]];
        }
        return nil;
    }];
}

#pragma mark -
#pragma mark - Internal methods

- (NSURLSessionDataTask *)taskForMethod:(NSString *)method
                              urlString:(NSString *)URLString
                             parameters:(id)parameters
                                success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    if ([method isEqualToString:@"GET"]) {
        return [self GET:URLString parameters:parameters success:success failure:failure];
    } else if ([method isEqualToString:@"POST"]) {
        return [self POST:URLString parameters:parameters success:success failure:failure];
    } else if ([method isEqualToString:@"DELETE"]) {
        return [self DELETE:URLString parameters:parameters success:success failure:failure];
    } else if ([method isEqualToString:@"PUT"]) {
        return [self PUT:URLString parameters:parameters success:success failure:failure];
    } else {
        NSAssert(NO, @"%@ must be GET, POST, PUT or DELETE", method);
        return nil;
    }
}

#pragma mark -
#pragma mark - Authentification

- (RACSignal *)signInAsUser:(BIMUser *)user token:(NSString *)token {
    NSParameterAssert(user != nil);
    NSParameterAssert(token != nil);

    @weakify(self);
    RACSignal *(^authorizationSignalWithUser)(BIMUser *user) = ^(BIMUser *user) {
        return [RACSignal defer:^{
            @strongify(self);
            self.user = user;
            
            NSMutableDictionary *params = [@{
                                            @"facebook_uid" : user.facebookUID,
                                            @"facebook_token" : token
                                            } mutableCopy];
            if (self.tokenPush) {
                params[@"device_token"] = self.tokenPush;
            }
            BIMRequest *request = [MTLJSONAdapter modelOfClass:BIMRequest.class fromJSONDictionary:@{
                                                                                                     @"method" : @"POST",
                                                                                                     @"path" : @"sessions",
                                                                                                     @"params" : params
                                                                                                     } error:nil];
            
            return [[self enqueueRequest:request resultClass:BIMUser.class] bim_parsedResults];
        }];
    };
    return [RACSignal defer:^{
        return [[[[authorizationSignalWithUser(user)
                   catch:^(NSError *error) {
                       RACSignal *deferredToken = [RACSignal defer:^{
                           return [self reallyGetToken];
                       }];
                       self.tokenConnection = [deferredToken multicast:[RACReplaySubject subject]];

                       return [RACSignal error:error];
                   }] map:^id(BIMUser *user) {
                       Mixpanel *mixpanel = [Mixpanel sharedInstance];
                       NSString *userID = [NSString stringWithFormat:@"%@", user.uniqueID];
                       [mixpanel identify:userID];
                       if (self.deviceToken) {
                           [mixpanel.people addPushDeviceToken:self.deviceToken];
                       }
                       @strongify(self);
                       [self setFacebookToken:user.facebookToken];
                       [self setUser:user];
                       
                       //tokenSignal
                       return user;
                   }]
                 replayLazily]
                setNameWithFormat:@"+signInAsUser: %@ token:", user];
    }];
}

#pragma mark -
#pragma mark - Error handling

+ (NSError *)errorFromTask:(NSURLSessionTask *)task {
    NSParameterAssert(task != nil);

    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;

    NSInteger HTTPCode = response.statusCode;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSInteger errorCode = BIMClientErrorConnectionFailed;
    
    switch (HTTPCode) {
        case 401: {
            NSError *errorTemplate = [NSError getAuthenticationRequiredError];
            errorCode = errorTemplate.code;
            [userInfo addEntriesFromDictionary:errorTemplate.userInfo];
            break;
        }
        case 400:
            errorCode = BIMClientErrorBadRequest;
            break;
        case 403:
            errorCode = BIMClientErrorRequestForbidden;
            break;
        case 422:
            errorCode = BIMClientErrorServiceRequestFailed;
            break;
        default:
            errorCode = BIMClientErrorSecureConnectionFailed;
            break;
    }
    userInfo[BIMClientErrorHTTPStatusCodeKey] = @(HTTPCode);
    if (task.response.URL != nil) userInfo[BIMClientErrorRequestURLKey] = task.response.URL;
    if (task.error != nil) userInfo[NSUnderlyingErrorKey] = task.error;
    
    return [NSError errorWithDomain:BIMClientErrorDomain code:errorCode userInfo:userInfo];
}

@end
