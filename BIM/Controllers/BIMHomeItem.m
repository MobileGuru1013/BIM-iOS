//
//  BIMHomeItem.m
//  BIM
//
//  Created by Alexis Jacquelin on 04/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMHomeItem.h"

@interface BIMHomeItem() {
    CGPoint _ptA;
    CGPoint _ptB;
    CGPoint _ptC;
    
    CGFloat _offsetY;
    
    CGFloat _alphaCircle;
    CGFloat _radiusCircle;
    CGPoint _originCircle;
}

/*
 
A -------- B
  \      /
   \    /
    \  /
     \/
      C
 */

@property (nonatomic, strong) UIImageView *friendsIV;

@end

@implementation BIMHomeItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)updateItemWithRatio:(CGFloat)ratio {
    ratio = MIN(MAX(ratio, 0), 1);
    [self calculatePointsForRatio:ratio];
    [self calculateOffsetY];
    [self calculateSizeCircleForRatio:ratio];

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.f);

    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextMoveToPoint(context, _ptA.x, _ptA.y);
    CGContextAddLineToPoint(context, _ptB.x, _ptB.y);
    CGContextAddLineToPoint(context, _ptC.x, _ptC.y);
    CGContextAddLineToPoint(context, _ptA.x, _ptA.y);
    
    CGContextMoveToPoint(context, _ptA.x, _ptA.y + _offsetY);
    CGContextAddLineToPoint(context, _ptB.x, _ptB.y + _offsetY);
    CGContextAddLineToPoint(context, _ptC.x, _ptC.y + _offsetY);
    CGContextAddLineToPoint(context, _ptA.x, _ptA.y + _offsetY);
    CGContextStrokePath(context);
    
    CGRect borderRect = CGRectMake(_originCircle.x, _originCircle.y, _radiusCircle, _radiusCircle);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, _alphaCircle);
    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);
}

- (void)calculatePointsForRatio:(CGFloat)ratio {
    _ptA = [self getPointAForRatio:ratio];
    _ptB = [self getPointBForRatio:ratio];
    _ptC = [self getPointCForRatio:ratio];
}

- (void)calculateOffsetY {
    CGFloat y = (_ptA.y + _ptB.y + _ptC.y) / 3;
    _offsetY =  (y - _ptA.y ) * 1.45;
}

- (void)calculateSizeCircleForRatio:(CGFloat)ratio {
    ratio = MIN(ratio * 6, 1);
    _alphaCircle = (1 - ratio);
    _originCircle = CGPointMake(_ptA.x - 5, _ptA.y - 9);
    _radiusCircle = _ptB.x - _ptA.x + 10;
}

- (CGPoint)getPointAForRatio:(CGFloat)ratio {
    const CGFloat minXA = 8.5f;
    const CGFloat maxXA = 19.5f;
    const CGFloat minYA = 19.5f;
    const CGFloat maxYA = 29.f;

    CGFloat x = [self getValueForMin:minXA max:maxXA andRatio:(1 - ratio)];
    CGFloat y = [self getValueForMin:minYA max:maxYA andRatio:(1 - ratio)];
    return CGPointMake(x, y);
}

- (CGPoint)getPointBForRatio:(CGFloat)ratio {
    const CGFloat minXB = 39.5f;
    const CGFloat maxXB = 71.f;
    
    CGFloat x = [self getValueForMin:minXB max:maxXB andRatio:ratio];
    CGFloat y = _ptA.y;
    return CGPointMake(x, y);
}

- (CGPoint)getPointCForRatio:(CGFloat)ratio {
    const CGFloat minYC = 38.5f;
    const CGFloat maxYC = 51.f;
    
    CGFloat x = ((_ptA.x + _ptB.x) / 2);
    CGFloat y = [self getValueForMin:minYC max:maxYC andRatio:ratio];
    return CGPointMake(x, y);
}

- (CGFloat)getValueForMin:(CGFloat)min max:(CGFloat)max andRatio:(CGFloat)ratio{
    return min + (max - min) * ratio;
}

@end