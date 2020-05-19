//
//  ContactTableCellNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ContactTableCellNode.h"

#import "StringHelper.h"
#import "UIImage+Additions.h"

#import "AppConsts.h"

#define kFontSize 18

static CGFloat avatarImageHeight;

@interface ContactTableCellNode ()

@property (nonatomic, strong) ASTextNode *nameLabel;
@property (nonatomic, strong) ASTextNode *shortNameLabel;
@property (nonatomic, strong) ASImageNode *avatarImage;
@property (nonatomic, strong) ASControlNode *controlNode;

@end

@implementation ContactTableCellNode

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        avatarImageHeight = [UIScreen mainScreen].bounds.size.width / 7.f;
        
        self.automaticallyManagesSubnodes = YES;
        
        _nameLabel = [[ASTextNode alloc] init];
        _nameLabel.maximumNumberOfLines = 1;
        
        _shortNameLabel = [[ASTextNode alloc] init];
        
        _avatarImage = [[ASImageNode alloc] init];
        _avatarImage.contentMode = UIViewContentModeScaleToFill;
        _avatarImage.style.height = ASDimensionMake(avatarImageHeight);
        _avatarImage.style.width = ASDimensionMake(avatarImageHeight);
        _avatarImage.imageModificationBlock = ^UIImage * _Nullable(UIImage * _Nonnull image) {
            CGSize avatarImageSize = CGSizeMake(avatarImageHeight, avatarImageHeight);
            return [image makeCircularImageWithSize:avatarImageSize];
        };
        
        _controlNode = [[ASControlNode alloc] init];
        [_controlNode addTarget:self
                         action:@selector(touchDown)
               forControlEvents:ASControlNodeEventTouchDown];
        [_controlNode addTarget:self
                         action:@selector(touchUpInside)
               forControlEvents:ASControlNodeEventTouchUpInside];
        [_controlNode addTarget:self
                         action:@selector(touchCancel)
               forControlEvents:ASControlNodeEventTouchUpOutside];
        [_controlNode addTarget:self
                         action:@selector(touchCancel)
               forControlEvents:ASControlNodeEventTouchCancel];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxConstrainedSize = constrainedSize.max;
    
    _controlNode.style.preferredSize = maxConstrainedSize;
    
    ASCenterLayoutSpec *centerNameSpec = [ASCenterLayoutSpec
                                          centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringY
                                          sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                          child:_nameLabel];
    centerNameSpec.style.preferredSize = CGSizeMake(maxConstrainedSize.width, avatarImageHeight);
    
    _avatarImage.style.preferredSize = CGSizeMake(avatarImageHeight, avatarImageHeight);
    ASCenterLayoutSpec *centerShortNameSpec = [ASCenterLayoutSpec
                                               centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                               sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                               child:_shortNameLabel];
    centerShortNameSpec.style.preferredSize = CGSizeMake(avatarImageHeight, avatarImageHeight);
    
    ASOverlayLayoutSpec *overlayShortNameSpec = [ASOverlayLayoutSpec
                                                 overlayLayoutSpecWithChild:_avatarImage
                                                 overlay:centerShortNameSpec];
    
    ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec
                                    stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                    spacing:20
                                    justifyContent:ASStackLayoutJustifyContentStart
                                    alignItems:ASStackLayoutAlignItemsCenter
                                    children:@[overlayShortNameSpec, centerNameSpec]];
    
    ASCenterLayoutSpec *centerSpec = [ASCenterLayoutSpec
                                      centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringY
                                      sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                      child:stackSpec];
    
    return [ASOverlayLayoutSpec
            overlayLayoutSpecWithChild:[ASInsetLayoutSpec
                                        insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 20, 0, 0)
                                        child:centerSpec]
            overlay:_controlNode];
}

#pragma mark - Setters

- (void)setName:(NSString *)name {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:kFontSize],
                                      NSParagraphStyleAttributeName : paragraphStyle
    };
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:name
                                                                 attributes:attributedText];
    self.nameLabel.attributedText = string;
}

- (void)setAvatar:(UIImage *)avatarImage {
    if (avatarImage) {
        self.avatarImage.image = avatarImage;
        self.shortNameLabel.hidden = YES;
    }
}

- (void)setGradientColorBackground:(NSInteger)colorCode {
    NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:20],
                                      NSForegroundColorAttributeName : [UIColor whiteColor] };
    NSAttributedString *string = [[NSAttributedString alloc]
                                  initWithString:[StringHelper getShortName:self.nameLabel.attributedText.string]
                                  attributes:attributedText];
    self.shortNameLabel.attributedText = string;
    self.shortNameLabel.hidden = NO;
    
    switch (colorCode) {
        case kGradientColorRed:
            self.avatarImage.image = [UIImage imageNamed:@"gradientRed"];
            break;
        case kGradientColorBlue:
            self.avatarImage.image = [UIImage imageNamed:@"gradientBlue"];
            break;
        case kGradientColorGreen:
            self.avatarImage.image = [UIImage imageNamed:@"gradientGreen"];
            break;
        case kGradientColorOrange:
            self.avatarImage.image = [UIImage imageNamed:@"gradientOrange"];
            break;
    }
}


#pragma mark - TouchEventHandle

- (void)touchDown {
    [self setBackgroundColor:[UIColor colorWithRed:235/255.f
                                             green:245/255.f
                                              blue:251/255.f
                                             alpha:1]];
}

- (void)touchUpInside {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCellNode:)]) {
        [self.delegate didSelectCellNode:self];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self setBackgroundColor:[UIColor whiteColor]];
    }];
}

- (void)touchCancel {
    [UIView animateWithDuration:0.25 animations:^{
        [self setBackgroundColor:[UIColor whiteColor]];
    }];
}


@end
