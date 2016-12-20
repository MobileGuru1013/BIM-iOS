//
//  BIMInfluencerButton.m
//  BIM
//
//  Created by Alexis Jacquelin on 23/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMInfluencerButton.h"

@implementation BIMInfluencerButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"tag-bg"] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont bim_avenirNextRegularWithSize:12];
        [self setSKYTitleColor:[UIColor bim_lightBlueColor]];
        
        [self setTitleEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];        
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

- (CGFloat)getCalculatedWidth {
    NSDictionary *attributesDictionary = @{
                                           NSFontAttributeName : self.titleLabel.font
                                           };
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.titleLabel.text attributes:attributesDictionary];
    CGRect rect = [attributeString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, kInfluencerButtonHeight) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    return MAX(kInfluencerButtonMinWidth, rect.size.width + kInfluencerButtonMargin);
}

@end
