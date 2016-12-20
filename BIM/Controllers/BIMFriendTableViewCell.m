//
//  BIMFriendTableViewCell.m
//  BIM
//
//  Created by Alexis Jacquelin on 29/10/14.
//  Copyright (c) 2014 OMTS. All rights reserved.
//

#import "BIMFriendTableViewCell.h"

@implementation BIMFriendTableViewCell

#pragma mark -
#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.userIV.layer.cornerRadius = round(self.userIV.width / 2);
    self.userIV.layer.masksToBounds = YES;

    [[RACObserve(self, friendObject) filter:^BOOL(BIMUser *user_) {
        return user_ ? YES : NO;
    }] subscribeNext:^(BIMUser *user_) {
        CGFloat sizeFont = 18;
        self.userDescriptionLabel.text = [user_ getDescriptionUser];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.userDescriptionLabel.text];
        [attributedString addAttributes:@{
                                          NSForegroundColorAttributeName : [UIColor whiteColor],
                                          NSFontAttributeName : [UIFont bim_avenirNextUltraLightWithSize:sizeFont]
                                          } range:NSMakeRange(0, self.userDescriptionLabel.text.length)];

        if (user_.firstName.length > 0) {
            NSRange rangeFirstName = [self.userDescriptionLabel.text rangeOfString:user_.firstName];
            if (rangeFirstName.location == 0) {
                [attributedString addAttribute:NSFontAttributeName value:[UIFont bim_avenirNextRegularWithSize:sizeFont] range:rangeFirstName];
            }
        }
        [self.userDescriptionLabel setAttributedText:attributedString];
        
        NSURL *avatarURL = [user_ avatarURLWithSize:self.userIV.size];
        if (avatarURL) {
            @weakify(self);
            [self.userIV sd_setImageWithURL:avatarURL placeholderImage:[BIMUser getSmallPlaceHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                @strongify(self);
                if (cacheType == SDImageCacheTypeNone && image) {
                    [UIView transitionWithView:self.userIV
                                      duration:0.3
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:nil completion:nil];
                }
            }];
        } else {
            [self.userIV setImage:[BIMUser getSmallPlaceHolder]];
        }
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.userIV sd_cancelCurrentImageLoad];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    [self customizeForSelection:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [self customizeForSelection:selected];
}

- (void)customizeForSelection:(BOOL)selected {
    if (selected) {
        [self setBackgroundColor:[UIColor bim_darkBlueColor]];
        self.arrowIV.image = [UIImage imageNamed:@"right-arrow-selected"];
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
        self.arrowIV.image = [UIImage imageNamed:@"right-arrow"];
    }
}

@end
