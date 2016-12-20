//
//  BIMPlace.m
//  BIM
//
//  Created by Alexis Jacquelin on 22/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMPlace.h"
#import "BIMUser.h"
#import "BIMHours.h"
#import "BIMCategory.h"

@implementation BIMPlace

#pragma mark -
#pragma mark - Properties

- (CLLocationCoordinate2D)getCoordinate {
    return CLLocationCoordinate2DMake([self.latitude floatValue], [self.longitude floatValue]);
}

#pragma mark -
#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
                                                                                          @"name" : @"name",
                                                                                          @"latitude" : @"latitude",
                                                                                          @"longitude" : @"longitude",
                                                                                          @"address" : @"address",
                                                                                          @"priceTier" : @"price_tier",
                                                                                          @"URLString" : @"url",
                                                                                          @"bookURLString" : @"book_url",
                                                                                          @"phone" : @"phone",
                                                                                          @"category" : @"category",
                                                                                          @"subCategory" : @"sub_category",
                                                                                          @"tags" : @"tags",
                                                                                          @"images" : @"images",
                                                                                          @"friends" : @"friends",
                                                                                          @"approvers" : @"approvers",
                                                                                          @"hours" : @"hours.timeframes",
                                                                                          @"userReview" : @"current_user_review"
                                                                                          }];
}

+ (NSValueTransformer *)tagsJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock:^id(NSArray *tags) {
        NSMutableArray *newTags = [NSMutableArray new];
        for (id value in tags) {
            if ([value isKindOfClass:[NSString class]]) {
                [newTags addObject:value];
            }
        }
        return newTags;
    }];
}

+ (NSValueTransformer *)userReviewJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           @"bim" : @(BIMUserReviewBim),
                                                                           @"bash" : @(BIMUserReviewBash),
                                                                           [NSNull null] : @(BIMUserReviewEmpty)
                                                                           }];
}

+ (NSValueTransformer *)alreadyReviewedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock:^id(NSString *userReview) {
        if ([userReview isKindOfClass:[NSString class]]) {
            return @YES;
        } else {
            return @NO;
        }
    }];
}

+ (NSValueTransformer *)categoryJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:BIMCategory.class];
}

+ (NSValueTransformer *)subCategoryJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:BIMCategory.class];
}

+ (NSValueTransformer *)friendsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:BIMUser.class];
}

+ (NSValueTransformer *)hoursJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:BIMHours.class];
}

- (NSURL *)getThumbnailImageStringURL {
    NSString *imageString = [self.images firstObject];
    return [NSURL bim_getURLFromString:imageString];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", self.uniqueID, self.name];
}

- (NSArray *)getInfluencers {
    NSArray *friendsName = [self.friends valueForKeyPath:@"getDescriptionUser"];
    NSArray *influencers;
    if ([self.approvers isKindOfClass:[NSArray class]]) {
        influencers = [friendsName arrayByAddingObjectsFromArray:(NSArray *)self.approvers];
    }
    else if ([self.approvers isKindOfClass:[NSOrderedSet class]]) {
        influencers = [friendsName arrayByAddingObjectsFromArray:[self.approvers array]];
    }
    else {
        influencers = friendsName;
    }
    return influencers;
}

#pragma mark -
#pragma mark - Images

- (UIImage *)getThumbnailCategoryImage {
    return [self getImageForForTemplate:@"category-icon-%d" withNumber:self.subCategory.uniqueID forCategory:YES];
}

- (UIImage *)getCategoryImage {
    return [self getImageForForTemplate:@"category-%d" withNumber:self.subCategory.uniqueID forCategory:YES];
}

- (UIImage *)getCategoryImageOnMap {
    return [self getImageForForTemplate:@"category-white-icon-%d" withNumber:self.subCategory.uniqueID forCategory:YES];
}

- (UIImage *)getThumbnailEuroImage {
    return [self getImageForForTemplate:@"euro-%d" withNumber:self.priceTier forCategory:NO];
}

- (UIImage *)getImageForForTemplate:(NSString *)template withNumber:(NSNumber *)number forCategory:(BOOL)isCategory {
    if (![number isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    int templateId = [number intValue];
    
    if (isCategory) {
        //used to map multiple category_id to the same image
        switch (templateId) {
            case 3:
                templateId = 1;
                break;
            case 1:
            case 2:
                templateId = 2;
                break;
            case 5:
            case 7:
            case 8:
            case 10:
            case 11:
                templateId = 3;
                break;
            case 6:
                templateId = 4;
                break;
            case 19:
            case 20:
            case 21:
            case 22:
                templateId = 5;
                break;
            case 9:
            case 24:
            case 25:
            case 28:
                templateId = 6;
                break;
            case 17:
            case 18:
                templateId = 7;
                break;
            case 4:
                templateId = 8;
                break;
            case 23:
            case 26:
                templateId = 9;
                break;
            case 12:
            case 13:
            case 14:
            case 15:
            case 16:
                templateId = 10;
                break;
            case 27:
                templateId = 11;
                break;
            default:
                templateId = 7;
                break;
        }
    }
    return [UIImage imageNamed:[NSString stringWithFormat:template, templateId]];
}

- (NSString *)getDescriptionPlace {
    return self.name;
}

- (NSString *)getAddressPlace {
    return self.address;
}

- (void)isOpenWithCompletionBlock:(void (^)(BIMScheduleModeState mode, NSError *error))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            if (!self.hours || self.hours.count == 0) {
                if (completionBlock) {
                    completionBlock(BIMScheduleModeStateUnknown, nil);
                }
                return;
            }
            for (BIMHours *hours in self.hours) {
                if ([hours checkIfContainDate]) {
                    if (completionBlock) {
                        completionBlock(BIMScheduleModeStateOpen, nil);
                    }
                    return;
                }
            }
            if (completionBlock) {
                completionBlock(BIMScheduleModeStateClose, nil);
            }
            return;
        }
        @catch (NSException *exception) {
            SKYLog(@"ERROR PARSING %@", exception);
            if (completionBlock) {
                completionBlock(NO, [NSError getParsingError]);
            }
        }
    });
}

- (NSString *)getDescriptionPlaceSearched {
    return self.name;
}

- (NSOrderedSet *)getImages {
    if (self.images.count > 0) {
        return self.images;
    } else {
        //Create empty image to improve UX
        return [[NSOrderedSet alloc] initWithObject:@""];
    }
}

- (NSURL *)getURL {
    if ([self.URLString isKindOfClass:[NSString class]]) {
        return [NSURL URLWithString:self.URLString];
    }
    return nil;
}

- (NSURL *)getPhoneURL {
    if ([self.phone isKindOfClass:[NSString class]]) {
        NSString *tel = [self.phone stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *string = [@"tel://" stringByAppendingString:tel];
        return [NSURL URLWithString:string];
    }
    return nil;
}

- (NSURL *)getAddressURL {
    if ([self.address isKindOfClass:[NSString class]]) {
        NSString *address = [self.address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *string = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@", address];
        return [NSURL URLWithString:string];
    }
    return nil;
}

+ (UIImage *)getBigPlaceHolder {
    NSString *imageName = @"placeholder-place-big";
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone47inch:
        imageName = @"placeholder-place-big-iPhone6";
            break;
        default:
            break;
    }
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)getSmallPlaceHolder {
    NSString *imageName = @"placeholder-place-small";
    switch ([SDiPhoneVersion deviceSize]) {
        case iPhone47inch:
            imageName = @"placeholder-place-small-iPhone6";
            break;
        default:
            break;
    }
    return [UIImage imageNamed:imageName];
}

@end
