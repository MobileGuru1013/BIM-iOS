//
//  BIMAPIClient.h
//  BIM
//
//  Created by Alexis Jacquelin on 22/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "SKYAPIClient.h"
#import "RACSignal+BIMClientAdditions.h"
#import "BIMRequest.h"
#import "BIMUser.h"

/*
****
 Inspired by the architecture of OctoKit (GitHub API client for Objective-C)
 https://github.com/octokit/octokit.objc
****
 */

// The domain for all errors originating in BIMClient.
extern NSString * const BIMClientErrorDomain;

typedef enum {
     ServiceActionTypeNotUsed
} ServiceActionType;

typedef NS_ENUM(NSUInteger, BIMErrorCode) {
    // A request was made to an endpoint that requires authentication, and the user
    // is not logged in.
    BIMClientErrorAuthenticationFailed,

    // The user attempted to authenticate with an OAuth token (like a Personal
    // Access Token), when the endpoint actually requires a password.
    BIMClientErrorTokenAuthenticationUnsupported,

    // The server is too old or new to understand our request.
    BIMClientErrorUnsupportedServer,
    
    // The server is refusing to process the request because of an
    // authentication-related issue (HTTP error 403).
    //
    // Often, this means that there have been too many failed attempts to
    // authenticate. Even a successful authentication will not work while this error
    // code is being returned. The only recourse is to stop trying and wait for
    // a bit.
    BIMClientErrorRequestForbidden,

    // The request was invalid (HTTP error 400).
    BIMClientErrorBadRequest,

    // The server refused to process the request (HTTP error 422).
    //
    // Among other reasons, this might be sent if one of the
    // -requestAuthorizationWithPassword: methods is given an invalid client ID or
    // secret.
    BIMClientErrorServiceRequestFailed,

    // There was a problem connecting to the server.
    BIMClientErrorConnectionFailed,

    // JSON parsing failed, or a model object could not be created from the parsed
    // JSON.
    BIMClientErrorJSONParsingFailed,

    // There was a problem establishing a secure connection, although the server is
    // reachable.
    BIMClientErrorSecureConnectionFailed,

    // A request was made to an facebook's endpoint that requires authentication, and the user
    // is not logged in.
    BIMFacebookErrorAuthenticationFailed,

    // A user changed his password so his account is unsync
    BIMFacebookErrorPasswordChanged,

    // Bim doesn't have the permission to use the facebook account
    BIMFacebookErrorAccessForbidden,
    
    // Bim doesn't have the permission to use the location of the user
    BIMUserLocationErrorAccessForbidden,

    // Getting location of the user result to a timeout
    BIMUserLocationErrorTimeOut,
    
    // Getting location of the user result to an unknown error
    BIMUserLocationErrorGeneric,
    
    // There is no location mode selected by the user on the categories VC
    BIMUserLocationErrorEmptyMode,

    // The mondial internet is down :(
    BIMErrorNoConnection
};

// A user info key associated with the NSURL of the request that failed.
extern NSString * const BIMClientErrorRequestURLKey;

// A user info key associated with an NSNumber, indicating the HTTP status code
// that was returned with the error.
extern NSString * const BIMClientErrorHTTPStatusCodeKey;

/// The descriptive message returned from the API, e.g., "Validation Failed".
extern NSString * const BIMClientErrorDescriptionKey;

/// An array of specific message strings returned from the API, e.g.,
/// "No commits between joshaber:master and joshaber:feature".
extern NSString * const BIMClientErrorMessagesKey;

// An environment variable that, when present, will enable logging of all
// responses.
extern NSString * const BIMClientResponseLoggingEnvironmentKey;

// Represents a single BIM session.
//
// Most of the methods on this class return a RACSignal representing a request
// made to the API. The returned signal will deliver its results on a background
// RACScheduler.
//
// To avoid hitting the network for a result that won't be used, **no request
// will be sent until the returned signal is subscribed to.** To cancel an
// in-flight request, simply dispose of all subscriptions.
@interface BIMAPIClient : AFHTTPSessionManager

@property (nonatomic, strong, readonly) RACMulticastConnection *tokenConnection;
@property (nonatomic, readonly, strong) RACSignal *tokenSignal;

// The active user for this session.
//
// This may be set regardless of whether the session is authenticated or
// unauthenticated, and will control which username is used for endpoints
// that require one. For example, this user's login will be used with
// -fetchUserEventsNotMatchingEtag:.
@property (nonatomic, strong, readonly) BIMUser *user;

//Token of the push, setted by the appDelegate
@property (nonatomic, strong) NSString *tokenPush;
@property (nonatomic, strong) NSData *deviceToken;

// Whether this client supports authenticated endpoints.
//
// Note that this property does not specify whether the client has successfully
// authenticated with the server — only whether it will attempt to.
//
// This will be NO when `token` is `nil`.
@property (nonatomic, getter = isAuthenticated, readonly) BOOL authenticated;

// Initializes the receiver to make requests to the BIM server.
+ (instancetype)sharedClient;

// Attempts to authenticate as the given user.
//
// Authentication is done using a native OAuth flow. This allows apps to avoid
// presenting a webpage, while minimizing the amount of time the client app
// needs the user's password.
//
// user            - The user to authenticate as. The `user` property of the
//                   returned client will be set to this object. This must not be nil.
// token           - The user's token. Cannot be nil.
//
// Returns a signal which will send an BIMClient then complete on success, or
// else error. If the server is too old to support this request, an error will
// be sent with code `BIMClientErrorUnsupportedServer`.
- (RACSignal *)signInAsUser:(BIMUser *)user token:(NSString *)token;

// Enqueues a request to be sent to the server.
//
// This will automatically fetch all pages of the given endpoint. Each object
// from each page will be sent independently on the returned signal, so
// subscribers don't have to know or care about this pagination behavior.
//
// request       - The previously constructed URL request for the endpoint.
// resultClass   - A subclass of BIMObject that the response data should be
//                 returned as, and will be accessible from the parsedResult
//                 property on each BIMResponse. If this is nil, NSDictionary
//                 will be used for each object in the JSON received.
//
// Returns a signal which will send an instance of `BIMResponse` for each parsed
// JSON object, then complete. If an error occurs at any point, the returned
// signal will send it immediately, then terminate.
- (RACSignal *)enqueueRequest:(BIMRequest *)request resultClass:(Class)resultClass;

//Logout the current user
- (void)logout;

@end
