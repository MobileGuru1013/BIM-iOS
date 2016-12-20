//
//  UIImage+AddOn.h
//  BIM
//
//  Created by Alexis Jacquelin on 30/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^block_resize)(UIImage *imageResized);

@interface UIImage (AddOn)

- (void)bim_resizeImageWithSize:(CGSize)size withCompletionBlock:(block_resize)block;
- (UIImage *)bim_blur;
- (UIImage *)bim_croppedImage:(CGRect)bounds;

@end
