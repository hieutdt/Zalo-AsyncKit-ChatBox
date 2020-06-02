//
//  PhotoMessageCellNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PhotoMessageCellNode.h"
#import "PhotoMessageCellConfigure.h"
#import "ContactAvatarNode.h"
#import "ImageCache.h"
#import "UIImage+Additions.h"

static const PhotoMessageCellConfigure *configure;

@interface PhotoMessageCellNode () <ASNetworkImageNodeDelegate>

@property (nonatomic, strong) Message *message;
@property (nonatomic, assign) MessageCellStyle messageStyle;

@property (nonatomic, strong) ASNetworkImageNode *imageNode;
@property (nonatomic, strong) ContactAvatarNode *avatarNode;

@property (nonatomic, strong) NSString *imageUrl;

@property (nonatomic, assign) BOOL didLayoutImage;

@end

@implementation PhotoMessageCellNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _imageNode = [[ASNetworkImageNode alloc] init];
        _imageNode.contentMode = UIViewContentModeScaleAspectFit;
        _imageNode.delegate = self;
        _imageNode.layerBacked = YES;
        _imageNode.backgroundColor = [UIColor clearColor];
        _imageNode.shouldCacheImage = YES;
        
        _imageNode.style.width = ASDimensionMake(configure.initialWidth);
        _imageNode.style.height = ASDimensionMake(configure.initialHeight);
        
        _avatarNode = [[ContactAvatarNode alloc] init];
        _avatarNode.hidden = YES;
        _avatarNode.style.preferredSize = CGSizeMake(25, 25);
        
        _didLayoutImage = NO;
        
        configure = [[PhotoMessageCellConfigure alloc] init];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    if (_messageStyle == MessageCellStyleImageSend) {
        return [ASInsetLayoutSpec
                insetLayoutSpecWithInsets:UIEdgeInsetsMake(configure.verticalPadding, INFINITY, configure.verticalPadding, configure.horizontalPadding)
                child:_imageNode];
        
    } else if (_messageStyle == MessageCellStyleImageReceive) {
        ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec
                                        stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                        spacing:configure.horizontalSpace
                                        justifyContent:ASStackLayoutJustifyContentStart
                                        alignItems:ASStackLayoutAlignItemsEnd
                                        children:@[_avatarNode, _imageNode]];
        
        return [ASInsetLayoutSpec
                insetLayoutSpecWithInsets:UIEdgeInsetsMake(configure.verticalPadding, configure.horizontalPadding, configure.verticalPadding, INFINITY)
                child:stackSpec];
    }
    
    return nil;
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
    _imageNode.URL = [NSURL URLWithString:url];
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

- (void)imageNode:(ASNetworkImageNode *)imageNode didLoadImage:(UIImage *)image info:(ASNetworkImageLoadInfo *)info {
    if (info.sourceType == ASNetworkImageSourceDownload ||
        info.sourceType == ASNetworkImageSourceAsynchronousCache) {
        ASPerformBlockOnBackgroundThread(^{
            BOOL isInitialConfigValue = self.imageNode.style.width.value == 100 && self.imageNode.style.height.value == 100;
            
            if (!self.didLayoutImage || isInitialConfigValue) {
                self.didLayoutImage = YES;

                CGSize imgSize = image.size;
                CGFloat imageRatio = imgSize.height / imgSize.width;
                
                ASDimension width = ASDimensionMake(configure.maxWidthOfCell);
                ASDimension height = ASDimensionMake(configure.maxWidthOfCell * imageRatio);
                self.imageNode.style.preferredLayoutSize = ASLayoutSizeMake(width, height);

                NSLog(@"Relayout!");
                [self setNeedsLayout];
            }
      });
    }
}

@end
