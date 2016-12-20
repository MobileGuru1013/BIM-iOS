//
//  BIMFriendsItem.m
//  BIM
//
//  Created by Alexis Jacquelin on 31/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMFriendsItem.h"

@interface BIMFriendsItem() {
    CGFloat _dynamicSize;

    CGFloat _middleCenterY;
    CGFloat _middleCenterX;
    
    CGFloat _alphaCircle;
    CGFloat _radiusCircle;
    CGPoint _originCircle;
}

@property (nonatomic, strong) UIImageView *friendsIV;

@end

@implementation BIMFriendsItem

#pragma mark -
#pragma mark - Lazy Loading

-(UIImageView *)friendsIV {
    if (_friendsIV == nil) {
        _friendsIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contacts-btn-big"]];
    }
    return _friendsIV;
}

#pragma mark -
#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.friendsIV];
    }
    return self;
}

- (void)updateItemWithRatio:(CGFloat)ratio {
    ratio = MIN(MAX(ratio, 0), 1);
    
    [self calculateSizeForRatio:ratio];
    [self calculateCenterYForRatio:ratio];
    [self calculateSizeCircleForRatio:ratio];
    
    self.friendsIV.transform = CGAffineTransformScale(CGAffineTransformIdentity, _dynamicSize, _dynamicSize);
    self.friendsIV.center = CGPointMake(_middleCenterX, _middleCenterY);
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.f);
    CGRect borderRect = CGRectMake(_originCircle.x, _originCircle.y, _radiusCircle, _radiusCircle);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, _alphaCircle);
    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);
}

- (void)calculateSizeForRatio:(CGFloat)ratio {
    const CGFloat minSize = .5f;
    const CGFloat maxSize = 1.f;
    
    _dynamicSize = minSize + (maxSize - minSize) * ratio;
}

- (void)calculateCenterYForRatio:(CGFloat)ratio {
    const CGFloat minXCenter = 22.f;
    const CGFloat maxXCenter = 25.5f;
    
    const CGFloat minYCenter = 21.f;
    const CGFloat maxYCenter = 23.f;
    
    _middleCenterX = minXCenter + (maxXCenter - minXCenter) * (1 - ratio);
    _middleCenterY = minYCenter + (maxYCenter - minYCenter) * ratio;
}

- (void)calculateSizeCircleForRatio:(CGFloat)ratio {
    ratio = MIN(ratio * 5, 1);
    CGFloat width = self.friendsIV.image.size.width * _dynamicSize;
    CGFloat height = self.friendsIV.image.size.height * _dynamicSize;

    _alphaCircle = (1 - ratio);
    _originCircle = CGPointMake(_middleCenterX - (width / 2) - 3, _middleCenterY - (height / 2) - 7);
    _radiusCircle = MAX(width + 6.5, height + 6.5);
}

@end
