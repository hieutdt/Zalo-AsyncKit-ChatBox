//
//  PhotoMessageCellNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PhotoMessageCellNode.h"
#import "ContactAvatarNode.h"


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

@end

@implementation PhotoMessageCellNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _imageNode = [[ASNetworkImageNode alloc] init];
        _imageNode.shouldCacheImage = YES;
        _imageNode.shouldRenderProgressImages = NO;
        _imageNode.contentMode = UIViewContentModeScaleToFill;
        _imageNode.cornerRadius = 10;
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
        _imageNode.style.preferredSize = CGSizeMake(maxConstrainedSize.width * 0.7, maxConstrainedSize.height);
        _controlNode.style.preferredSize = CGSizeMake(maxConstrainedSize.width * 0.7, maxConstrainedSize.height);
    } else {
        _imageNode.style.preferredSize = CGSizeMake(maxConstrainedSize.height *ratio, maxConstrainedSize.height);
        _controlNode.style.preferredSize = CGSizeMake(maxConstrainedSize.height *ratio, maxConstrainedSize.height);
    }
    
    _avatarNode.style.preferredSize = CGSizeMake(25, 25);
    
    ASOverlayLayoutSpec *overlayControlSpec = [ASOverlayLayoutSpec
                                               overlayLayoutSpecWithChild:_imageNode
                                               overlay:_controlNode];
    
    if (_messageStyle == MessageCellStyleImageSend) {
        return [ASInsetLayoutSpec
                insetLayoutSpecWithInsets:UIEdgeInsetsMake(kVericalPadding, INFINITY, kVericalPadding, kHorizontalPadding)
                child:_imageNode];
        
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

#pragma mark - Setter

- (void)setMessage:(Message *)message {
    _message = message;
    if ([_message.fromPhoneNumber isEqualToString:kCurrentUser]) {
        _messageStyle = MessageCellStyleImageSend;
    } else {
        _messageStyle = MessageCellStyleImageReceive;
    }
}

- (void)setImageUrl:(NSString *)url {
    _imageUrl = url;
    _imageNode.URL = [NSURL URLWithString:_imageUrl];
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

- (BOOL)isFinishLoadImage {
    return _loadImageFinish;
}

- (Message *)getMessage {
    return _message;
}

#pragma mark - ASNetworkImageNodeDelegate

- (void)imageNode:(ASNetworkImageNode *)imageNode didLoadImage:(UIImage *)image {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(photoMessageCellNode:didLoadImageWithSize:)]) {
        self.loadImageFinish = YES;
        self.imageRatio = image.size.width / image.size.height;
        [self.delegate photoMessageCellNode:self didLoadImageWithSize:image.size];
    }
}

@end
