//
//  BIMCategoryItem.m
//  BIM
//
//  Created by Alexis Jacquelin on 31/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMCategoriesItem.h"

static CGFloat const minx = 9.5f;

@interface BIMCategoriesItem() {
    CGSize _dynamicSize;
    
    CGFloat _topCenterY;
    CGFloat _middleCenterY;
    CGFloat _bottomCenterY;
    
    CGFloat _alphaCircle;
    CGFloat _radiusCircle;
    CGPoint _originCircle;
}

@end

@implementation BIMCategoriesItem

#pragma mark -
#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)updateItemWithRatio:(CGFloat)ratio {
    ratio = MIN(MAX(ratio, 0), 1);
    [self calculateSizeForRatio:ratio];
    [self calculateCenterYForRatio:ratio];
    [self calculateSizeCircleForRatio:ratio];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.f);
    
    NSArray *array = @[@(_topCenterY), @(_middleCenterY), @(_bottomCenterY)];
    for (NSNumber *centerY in array) {
        CGFloat centery = [centerY floatValue];
        
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextMoveToPoint(context, minx, centery - _dynamicSize.height);
        CGContextAddLineToPoint(context, minx + _dynamicSize.width, centery - _dynamicSize.height);
        CGContextAddLineToPoint(context, minx + _dynamicSize.width, centery + _dynamicSize.height);
        CGContextAddLineToPoint(context, minx, centery + _dynamicSize.height);
        CGContextAddLineToPoint(context, minx, centery + _dynamicSize.height);
        CGContextAddLineToPoint(context, minx, centery - _dynamicSize.height);
        CGContextStrokePath(context);
    }
    
    CGRect borderRect = CGRectMake(_originCircle.x, _originCircle.y, _radiusCircle, _radiusCircle);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, _alphaCircle);
    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);
}

- (void)calculateSizeForRatio:(CGFloat)ratio {
    const CGFloat maxHeightSquare = 2.f;
    
    const CGFloat minWithSquare = 16.f;
    const CGFloat maxWidhtSquare = 26.f;
    
    CGFloat newWidth = minWithSquare + (maxWidhtSquare - minWithSquare) * ratio;
    CGFloat newHeight = MIN(maxHeightSquare * ratio, maxHeightSquare);
    _dynamicSize = CGSizeMake(newWidth, newHeight);
}

- (void)calculateCenterYForRatio:(CGFloat)ratio {
    const CGFloat minYTop = 15.5f;
    const CGFloat maxYTop = 17.f;

    const CGFloat yMiddle = 22.5f;

    const CGFloat minYBottom = 27.5f;
    const CGFloat maxYBottom = 30.f;

    _topCenterY = minYTop + (maxYTop - minYTop) * (1 - ratio);
    _middleCenterY = yMiddle;
    _bottomCenterY = minYBottom + (maxYBottom - minYBottom) * ratio;
}

- (void)calculateSizeCircleForRatio:(CGFloat)ratio {
    ratio = MIN(ratio * 2, 1);
    _alphaCircle = (1 - ratio);
    _originCircle = CGPointMake(minx - 8, _topCenterY - _dynamicSize.height - 10);
    _radiusCircle = MAX(_dynamicSize.width + 15, _dynamicSize.height + 15);
}

@end
