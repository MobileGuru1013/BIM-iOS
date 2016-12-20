//
//  BIMButtonWithLoader.h
//  BIM
//
//  Created by Alexis Jacquelin on 24/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIMButtonWithLoader : UIButton

@property (nonatomic, strong) NSString *imageLoader;
@property (nonatomic, assign) BOOL hideImageDuringLoading;
@property (nonatomic, assign) BOOL needToRestoreAfterRotation;

- (BOOL)isLoading;
- (void)startLoader;
- (void)stopLoader;

@end
