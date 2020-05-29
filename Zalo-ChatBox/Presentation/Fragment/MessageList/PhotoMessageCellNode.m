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
        _imageNode.contentMode = UIViewContentModeScaleToFill;
        _imageNode.delegate = self;
        _imageNode.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
        _imageNode.shouldCacheImage = YES;
        _imageNode.style.preferredSize = CGSizeMake(100, 100);
        self.style.preferredSize = _imageNode.style.preferredSize;
        
        _avatarNode = [[ContactAvatarNode alloc] init];
        _avatarNode.hidden = YES;
        _avatarNode.style.preferredSize = CGSizeMake(25, 25);
        
        _loadImageFinish = NO;
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    _avatarNode.style.width = ASDimensionMake(25);
    _avatarNode.style.height = ASDimensionMake(25);
    
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
                                        children:@[_avatarNode, _imageNode]];
        
        return [ASInsetLayoutSpec
                insetLayoutSpecWithInsets:UIEdgeInsetsMake(kVericalPadding, kHorizontalPadding, kVericalPadding, INFINITY)
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

- (void)imageNode:(ASNetworkImageNode *)imageNode didLoadImage:(UIImage *)image {
    CGSize imgSize = image.size;
    CGFloat ratio = imgSize.width / imgSize.height;
    
    _imageNode.style.preferredSize = CGSizeMake(100, 100.f / ratio);
    
    [self setNeedsLayout];
}

- (void)imageNodeDidLoadImageFromCache:(ASNetworkImageNode *)imageNode {
    NSLog(@"Load from cache!");
}

@end
