//
//  BIMBottomButtonWithLoader.h
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMBottomButton.h"

@interface BIMBottomButtonWithLoader : BIMBottomButton

- (BOOL)isLoading;
- (void)startLoader;
- (void)stopLoader;

@end
