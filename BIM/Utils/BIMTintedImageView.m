//
//  BIMTintedImageView.m
//  BIM
//
//  Created by Alexis Jacquelin on 30/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMTintedImageView.h"

@interface BIMTintedImageView() {
}

@property (strong, nonatomic) UIImage * image;
@property (strong, nonatomic) UIColor * tintColor;

@end

@implementation BIMTintedImageView

- (id)initWithImage:(UIImage *)image color:(UIColor *)color size:(CGSize)size {
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    if(self) {
        self.image = image;
        
        self.opaque = NO;

        _tintColor = color;
    }    
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //resolve CG/iOS coordinate mismatch
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    
    //set the clipping area to the image
    CGContextClipToMask(context, rect, _image.CGImage);
    
    //set the fill color
    CGContextSetFillColor(context, CGColorGetComponents(_tintColor.CGColor));
    CGContextFillRect(context, rect);
    
    //blend mode overlay
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    
    //draw the image
    CGContextDrawImage(context, rect, _image.CGImage);
}

@end
