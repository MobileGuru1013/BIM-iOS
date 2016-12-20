//
//  BIMTagsPlace.m
//  BIM
//
//  Created by Alexis Jacquelin on 05/11/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMTagsPlaceView.h"

@interface BIMTagsPlaceView() {
}

@property (nonatomic, assign) CGFloat totalHeight;

@end

@implementation BIMTagsPlaceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        @weakify(self);
        [[RACObserve(self, place) filter:^BOOL(id value) {
            return value ? YES : NO;
        }]  subscribeNext:^(BIMPlace *place_) {
            @strongify(self);
            
            if (place_.tags &&
                place_.tags.count > 0) {
                //Line
                UIImageView *lineIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line-h"]];
                lineIV.contentMode = UIViewContentModeScaleToFill;
                [self addSubview:lineIV];
                
                [lineIV autoAlignAxisToSuperviewAxis:ALAxisVertical];
                [lineIV autoSetDimensionsToSize:CGSizeMake(self.width - 30, 2)];
                [lineIV autoPinEdgeToSuperviewEdge:ALEdgeTop];
                
                //Tags
                UILabel *labelTags = [UILabel new];
                labelTags.numberOfLines = 0;
                labelTags.textAlignment = NSTextAlignmentCenter;
                labelTags.alpha = .6f;
                
                CGFloat height_line = 12;
                CGFloat offset = 0;
                switch ([SDiPhoneVersion deviceSize]) {
                    case iPhone55inch:
                        offset = 50;
                        height_line = 18;
                        break;
                    case iPhone47inch:
                        offset = 30;
                        height_line = 16;
                        break;
                        
                    default:
                        break;
                }
                
                
                CGFloat height = height_line;
                for (NSString *tag in place_.tags) {
                    if (labelTags.text.length > 0) {
                        NSString *string = [NSString stringWithFormat:@"%@  •  %@", labelTags.text, tag];
                        if ([self getWidthForText:string withHeight:height] > self.width - offset) {
                            //new line
                            labelTags.text = [NSString stringWithFormat:@"%@\n%@", labelTags.text, tag];
                            height += height_line;
                        } else {
                            labelTags.text = string;
                        }
                    } else {
                        labelTags.text = tag;
                    }
                }
                [self addSubview:labelTags];
                
                //Calculate size
                NSMutableParagraphStyle *paragraphStyleCenter = [NSMutableParagraphStyle new];
                paragraphStyleCenter.lineBreakMode = NSLineBreakByWordWrapping;
                paragraphStyleCenter.alignment = NSTextAlignmentCenter;
                paragraphStyleCenter.minimumLineHeight = 17.0f;

                NSDictionary *attributesDictionary = @{
                                                       NSFontAttributeName : [UIFont bim_avenirNextMediumWithSize:9.5f],
                                                       NSForegroundColorAttributeName : [UIColor whiteColor],
                                                       NSParagraphStyleAttributeName : paragraphStyleCenter
                                                       };
                
                labelTags.attributedText = [[NSAttributedString alloc] initWithString:labelTags.text attributes:attributesDictionary];
                CGRect frame = [labelTags.text boundingRectWithSize:CGSizeMake(self.width, CGFLOAT_MAX)
                                                           options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                        attributes:attributesDictionary
                                                           context:nil];
                [labelTags autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lineIV withOffset:15];
                [labelTags autoSetDimensionsToSize:CGSizeMake(ceil(frame.size.width), ceil(frame.size.height))];
                [labelTags autoAlignAxisToSuperviewAxis:ALAxisVertical];
                self.totalHeight = frame.size.height + 17;
            }
        }];
    }
    return self;
}

//TODO: optimisation -- the height can be calculated on a background thread when parsing the response
//      or/and I can use AsyncDisplayKit ?? :) Yeahhhh!
- (CGFloat)getWidthForText:(NSString *)text withHeight:(CGFloat)height {
    NSDictionary *attributesDictionary = @{
                                           NSFontAttributeName : [UIFont bim_avenirNextMediumWithSize:9.5f]
                                           };
    CGRect frame = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:attributesDictionary
                                      context:nil];
    
    return frame.size.width;
}

@end
