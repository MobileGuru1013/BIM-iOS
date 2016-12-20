//
//  UIImage+AddOn.m
//  BIM
//
//  Created by Alexis Jacquelin on 30/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "UIImage+AddOn.h"

@implementation UIImage (AddOn)

- (void)bim_resizeImageWithSize:(CGSize)size withCompletionBlock:(block_resize)block {
    if (block == nil) {
        return;
    }
    BOSImageResizeOperation* opCrop = [[BOSImageResizeOperation alloc] initWithImage:self];
    [opCrop cropToAspectRatioWidth:size.width height:size.height];
    
    dispatch_async(dispatch_queue_create("com.pictrad.Pictrad.Resize", NULL), ^{
        [opCrop start];
        BOSImageResizeOperation* opResize = [[BOSImageResizeOperation alloc] initWithImage:opCrop.result];
        [opResize resizeToFitWithinSize:CGSizeMake(size.width, size.height)];
        [opResize start];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(opResize.result);
        });
    });
}

- (UIImage *)bim_blur {
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:kCIInputRadiusKey];

    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    return returnImage;
}

- (UIImage *)bim_croppedImage:(CGRect)bounds {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

@end
