//
//  PhotoMessageCellNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PhotoMessageCellNode.h"
#import "ContactAvatarNode.h"
#import "ImageCache.h"
#import "UIImage+Additions.h"

static const int kVericalPadding = 1;
static const int kHorizontalPadding = 10;

@interface PhotoMessageCellNode () <ASNetworkImageNodeDelegate>

@property (nonatomic, strong) Message *message;
@property (nonatomic, assign) MessageCellStyle messageStyle;

@property (nonatomic, strong) ASNetworkImageNode *imageNode;
@property (nonatomic, strong) ASControlNode *controlNode;
@property (nonatomic, strong) ContactAvatarNode *avatarNode;
@property (nonatomic, assign) BOOL loadImageFinish;

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) CGFloat imageRatio;

@end

@implementation PhotoMessageCellNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _imageNode = [[ASNetworkImageNode alloc] init];
        _imageNode.contentMode = UIViewContentModeScaleToFill;
        _imageNode.delegate = self;
        
        _controlNode = [[ASControlNode alloc] init];
    
        _avatarNode = [[ContactAvatarNode alloc] init];
        _avatarNode.hidden = YES;
        
        _imageRatio = 1;
        _loadImageFinish = NO;
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxConstrainedSize = constrainedSize.max;
    
    CGFloat ratio = _imageRatio;
    if (ratio >= 1) {
        CGFloat width = maxConstrainedSize.width * 0.7;
        _imageNode.style.preferredSize = CGSizeMake(width, width / ratio);
        _controlNode.style.preferredSize = CGSizeMake(width, width / ratio);
    } else {
        CGFloat height = 400;
        _imageNode.style.preferredSize = CGSizeMake(height *ratio, height);
        _controlNode.style.preferredSize = CGSizeMake(height *ratio, height);
    }
    
    _avatarNode.style.preferredSize = CGSizeMake(25, 25);
    
    ASOverlayLayoutSpec *overlayControlSpec = [ASOverlayLayoutSpec
                                               overlayLayoutSpecWithChild:_imageNode
                                               overlay:_controlNode];
    
    if (_messageStyle == MessageCellStyleImageSend) {
        return [ASInsetLayoutSpec
                insetLayoutSpecWithInsets:UIEdgeInsetsMake(kVericalPadding, INFINITY, kVericalPadding, kHorizontalPadding)
                child:overlayControlSpec];
        
    } else if (_messageStyle == MessageCellStyleImageReceive) {
        ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec
                                        stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                        spacing:10
                                        justifyContent:ASStackLayoutJustifyContentStart
                                        alignItems:ASStackLayoutAlignItemsEnd
                                        children:@[_avatarNode, overlayControlSpec]];
        
        return [ASInsetLayoutSpec
                insetLayoutSpecWithInsets:UIEdgeInsetsMake(kVericalPadding, kHorizontalPadding, kVericalPadding, INFINITY)
                child:stackSpec];
    }
    
    return nil;
}

- (void)didLoad {
    [super didLoad];
}

#pragma mark - CellNode

- (void)updateCellNodeWithObject:(id)object {
    if ([object isKindOfClass:[SinglePhotoMessage class]]) {
        SinglePhotoMessage *photo = (SinglePhotoMessage *)object;
        [self setMessage:photo];
        [self setImageUrl:photo.imageURL.absoluteString];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        Message *message = (Message *)photo;
        if (message.showAvatar) {
            UIImage *avatarImage = [[ImageCache instance] imageForKey:message.fromContact.identifier];
            if (avatarImage) {
                [self showAvatarImage:avatarImage];
            } else {
                [self showAvatarImageWithGradientColor:message.fromContact.gradientColorCode
                                             shortName:message.fromContact.name];
            }
        }
    }
}

#pragma mark - Setter

- (void)setMessage:(Message *)message {
    _message = message;
    if ([_message.fromContact.phoneNumber isEqualToString:kCurrentUser]) {
        _messageStyle = MessageCellStyleImageSend;
    } else {
        _messageStyle = MessageCellStyleImageReceive;
    }
}

- (void)setImageUrl:(NSString *)url {
    _imageUrl = url;
    
    UIImage *image = [[ImageCache instance] imageForKey:_imageUrl];
    if (image) {
        [_imageNode setImage:image];
        _imageRatio = image.size.width / image.size.height;
    } else {
        _imageNode.URL = [NSURL URLWithString:_imageUrl];
    }
}

- (void)showAvatarImage:(UIImage *)image {
    if (!image || _messageStyle != MessageCellStyleImageReceive)
        return;
    
    [_avatarNode setAvatar:image];
    _avatarNode.hidden = NO;
}

- (void)showAvatarImageWithGradientColor:(int)gradientColorCode
                               shortName:(NSString *)shortName {
    if (!shortName || _messageStyle != MessageCellStyleImageReceive)
        return;
    
    [_avatarNode setGradientAvatarWithColorCode:gradientColorCode
                                   andShortName:shortName];
    _avatarNode.hidden = NO;
}

#pragma mark - Getter

- (Message *)getMessage {
    return _message;
}

#pragma mark - ASNetworkImageNodeDelegate

- (void)imageNode:(ASNetworkImageNode *)imageNode didLoadImage:(UIImage *)image {
    if (self.imageRatio == 1) {
        [[ImageCache instance] setImage:image forKey:_imageUrl];
        
        self.loadImageFinish = YES;
        self.imageRatio = image.size.width / image.size.height;
        
        [self setNeedsLayout];
    }
}

@end
