//
//  BIMPlace.h
//  BIM
//
//  Created by Alexis Jacquelin on 22/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMObject.h"
#import "BIMScheduleView.h"

@class BIMCategory;

typedef enum : NSUInteger {
    BIMPriceTierEmpty,
    BIMPriceTier1,
    BIMPriceTier2,
    BIMPriceTier3,
    BIMPriceTier4,
} BIMPriceTier;

typedef enum : NSUInteger {
    BIMUserReviewEmpty,
    BIMUserReviewBim,
    BIMUserReviewBash
} BIMUserReview;

@interface BIMPlace : BIMObject <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSNumber *latitude;
@property (nonatomic, copy, readonly) NSNumber *longitude;
@property (nonatomic, copy, readonly) NSString *address;
@property (nonatomic, copy, readonly) NSNumber *priceTier;
@property (nonatomic, copy, readonly) NSString *URLString;
@property (nonatomic, copy, readonly) NSString *bookURLString;
@property (nonatomic, copy, readonly) NSString *phone;

@property (nonatomic, assign) BIMUserReview userReview;

@property (nonatomic, strong, readonly) BIMCategory *category;
@property (nonatomic, strong, readonly) BIMCategory *subCategory;
@property (nonatomic, strong, readonly) NSOrderedSet *tags;
@property (nonatomic, strong, readonly) NSOrderedSet *images;
@property (nonatomic, strong, readonly) NSOrderedSet *friends;
@property (nonatomic, strong, readonly) NSOrderedSet *approvers;
@property (nonatomic, strong, readonly) NSOrderedSet *hours;

- (CLLocationCoordinate2D)getCoordinate;
- (NSArray *)getInfluencers;

- (UIImage *)getThumbnailCategoryImage;
- (UIImage *)getCategoryImage;
- (UIImage *)getCategoryImageOnMap;
- (UIImage *)getThumbnailEuroImage;
- (NSString *)getDescriptionPlace;
- (void)isOpenWithCompletionBlock:(void (^)(BIMScheduleModeState state, NSError *error))completionBlock;
- (NSString *)getAddressPlace;
- (NSURL *)getURL;
- (NSURL *)getPhoneURL;
- (NSURL *)getAddressURL;

+ (UIImage *)getBigPlaceHolder;
+ (UIImage *)getSmallPlaceHolder;
- (NSString *)getDescriptionPlaceSearched;

- (NSURL *)getThumbnailImageStringURL;

//Cannot be empty
- (NSOrderedSet *)getImages;

@end
