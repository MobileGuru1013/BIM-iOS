//
//  BIMTintedImageView.h
//  BIM
//
//  Created by Alexis Jacquelin on 30/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIMTintedImageView : UIView

@property (nonatomic, strong) NSString *urlString;

- (id)initWithImage:(UIImage *)image color:(UIColor *)color size:(CGSize)size;

@end
