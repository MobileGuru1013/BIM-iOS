//
//  BIMActivityView.h
//  BIM
//
//  Created by Alexis Jacquelin on 24/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIMActivityView : UIImageView

- (void)startAnimatingView;
- (void)stopAnimatingView;
- (void)stopAnimatingViewAndRestoreTransformWithCompletionBlock:(void (^)(void))completionBlock;
    
@end
