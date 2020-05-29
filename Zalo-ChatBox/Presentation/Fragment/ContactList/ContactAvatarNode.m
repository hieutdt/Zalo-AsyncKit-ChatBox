//
//  ContactAvatarNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ContactAvatarNode.h"
#import "UIImage+Additions.h"
#import "AppConsts.h"


static const int kFontSize = 15;

@interface ContactAvatarNode ()

@property (nonatomic, strong) ASTextNode *shortNameLabel;
@property (nonatomic, strong) ASImageNode *imageNode;

@end

@implementation ContactAvatarNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _shortNameLabel = [[ASTextNode alloc] init];
        _imageNode = [[ASImageNode alloc] init];
        _imageNode.contentMode = UIViewContentModeScaleToFill;
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxConstrainedSize = constrainedSize.max;
    
    _imageNode.style.preferredSize = maxConstrainedSize;
//    _imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(1, [UIColor colorWithWhite:0.5 alpha:1]);
    _imageNode.imageModificationBlock = ^UIImage * _Nullable(UIImage * _Nonnull image) {
        CGSize avatarImageSize = CGSizeMake(25, 25);
        return [image makeCircularImageWithSize:avatarImageSize];
    };
    
    ASCenterLayoutSpec *centerTextSpec = [ASCenterLayoutSpec
                                          centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                          sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                          child:_shortNameLabel];
    
    return [ASOverlayLayoutSpec overlayLayoutSpecWithChild:_imageNode
                                                   overlay:centerTextSpec];
}

- (void)setAvatar:(UIImage *)image {
    if (image) {
        [_imageNode setImage:image];
        _shortNameLabel.hidden = YES;
    }
}

- (void)setGradientAvatarWithColorCode:(int)colorCode
                          andShortName:(NSString *)shortName {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:kFontSize],
                                      NSForegroundColorAttributeName : [UIColor whiteColor],
                                      NSParagraphStyleAttributeName : paragraphStyle
    };
    NSAttributedString *string = [[NSAttributedString alloc]
                                  initWithString:shortName
                                  attributes:attributedText];
    self.shortNameLabel.attributedText = string;
    self.shortNameLabel.hidden = NO;
    
    switch (colorCode) {
        case kGradientColorRed:
            self.imageNode.image = [UIImage imageNamed:@"gradientRed"];
            break;
        case kGradientColorBlue:
            self.imageNode.image = [UIImage imageNamed:@"gradientBlue"];
            break;
        case kGradientColorGreen:
            self.imageNode.image = [UIImage imageNamed:@"gradientGreen"];
            break;
        case kGradientColorOrange:
            self.imageNode.image = [UIImage imageNamed:@"gradientOrange"];
            break;
    }
}

@end
