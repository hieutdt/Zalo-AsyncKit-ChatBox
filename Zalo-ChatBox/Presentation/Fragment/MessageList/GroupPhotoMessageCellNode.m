//
//  GroupPhotoMessageCellNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/28/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "GroupPhotoMessageCellNode.h"
#import "GroupPhotoMessageCellConfigure.h"
#import "ContactAvatarNode.h"
#import "ImageCache.h"
#import "UIImage+Additions.h"

static const GroupPhotoMessageCellConfigure *configure;

@interface GroupPhotoMessageCellNode () <ASNetworkImageNodeDelegate>

@property (nonatomic, strong) Message *message;
@property (nonatomic, assign) MessageCellStyle messageStyle;

@property (nonatomic, strong) NSMutableArray<ASNetworkImageNode *> *imageNodes;
@property (nonatomic, strong) ASControlNode *controlNode;
@property (nonatomic, strong) ContactAvatarNode *avatarNode;

@property (nonatomic, strong) NSArray<NSString *> *imageUrls;

@end

@implementation GroupPhotoMessageCellNode


- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _imageNodes = [[NSMutableArray alloc] init];
        
        _controlNode = [[ASControlNode alloc] init];
        
        _avatarNode = [[ContactAvatarNode alloc] init];
        _avatarNode.style.preferredSize = CGSizeMake(25, 25);
        _avatarNode.hidden = YES;
        
        configure = [[GroupPhotoMessageCellConfigure alloc] init];
    }
    return self;
}

- (void)initImageNodesWithCount:(NSInteger)count {
    for (int i = 0; i < count; i++) {
        ASNetworkImageNode *imageNode = [[ASNetworkImageNode alloc] init];
        imageNode.contentMode = UIViewContentModeScaleAspectFit;
        imageNode.backgroundColor = configure.backgroundColor;
        imageNode.shouldCacheImage = YES;
        imageNode.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake(configure.imageWidth),
                                                               ASDimensionMake(configure.imageWidth));
        
        [_imageNodes addObject:imageNode];
    }
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
#if DEBUG
    assert(self.imageNodes.count == self.imageUrls.count);
#endif
    
    NSMutableArray *verticalChilds = [[NSMutableArray alloc] init];
    NSMutableArray *horizontalNodes = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.imageNodes.count; i++) {
        [horizontalNodes addObject:_imageNodes[i]];
        if (horizontalNodes.count == configure.maxImagesInCell || i == self.imageNodes.count - 1) {
            ASStackLayoutSpec *horizontalStack = [ASStackLayoutSpec
                                                  stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                                  spacing:configure.horizontalSpace
                                                  justifyContent:ASStackLayoutJustifyContentStart
                                                  alignItems:ASStackLayoutAlignItemsCenter
                                                  children:[NSArray arrayWithArray:horizontalNodes]];
            [verticalChilds addObject:horizontalStack];
            [horizontalNodes removeAllObjects];
        }
    }
    
    if (_messageStyle == MessageCellStyleSend) {
        ASStackLayoutSpec *verticalStack = [ASStackLayoutSpec
                                            stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                            spacing:configure.verticalSpace
                                            justifyContent:ASStackLayoutJustifyContentStart
                                            alignItems:ASStackLayoutAlignItemsEnd
                                            children:verticalChilds];
        return [ASInsetLayoutSpec
                insetLayoutSpecWithInsets:UIEdgeInsetsMake(configure.verticalPadding, INFINITY, configure.verticalPadding, configure.horizontalPadding)
                child:verticalStack];
        
    } else if (_messageStyle == MessageCellStyleReceive) {
        ASStackLayoutSpec *verticalStack = [ASStackLayoutSpec
                                            stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                            spacing:configure.verticalSpace
                                            justifyContent:ASStackLayoutJustifyContentStart
                                            alignItems:ASStackLayoutAlignItemsStart
                                            children:verticalChilds];
        
        ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec
                                        stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                        spacing:configure.horizontalPadding
                                        justifyContent:ASStackLayoutJustifyContentStart
                                        alignItems:ASStackLayoutAlignItemsEnd
                                        children:@[_avatarNode, verticalStack]];
        
        return [ASInsetLayoutSpec
                insetLayoutSpecWithInsets:UIEdgeInsetsMake(configure.verticalPadding, configure.horizontalPadding, configure.verticalPadding, INFINITY)
                child:stackSpec];
    }
    
    return nil;
}

- (void)didLoad {
    [super didLoad];
}

#pragma mark - CellNode

- (void)updateCellNodeWithObject:(id)object {
    if ([object isKindOfClass:[GroupPhotoMessage class]]) {
        GroupPhotoMessage *groupPhoto = (GroupPhotoMessage *)object;
#if DEBUG
        assert(groupPhoto.urls.count > 0);
#endif
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setMessage:groupPhoto];
        [self initImageNodesWithCount:groupPhoto.urls.count];
        self.imageUrls = groupPhoto.urls;
        
        for (int i = 0; i < _imageUrls.count; i++) {
            [_imageNodes[i] setURL:[NSURL URLWithString:_imageUrls[i]]];
        }
        
        Message *message = (Message *)groupPhoto;
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
        _messageStyle = MessageCellStyleSend;
    } else {
        _messageStyle = MessageCellStyleReceive;
    }
}

- (void)showAvatarImage:(UIImage *)image {
    if (!image || _messageStyle != MessageCellStyleReceive)
        return;
    
    [_avatarNode setAvatar:image];
    _avatarNode.hidden = NO;
}

- (void)showAvatarImageWithGradientColor:(int)gradientColorCode
                               shortName:(NSString *)shortName {
    if (!shortName || _messageStyle != MessageCellStyleReceive)
        return;
    
    [_avatarNode setGradientAvatarWithColorCode:gradientColorCode
                                   andShortName:shortName];
    _avatarNode.hidden = NO;
}

@end
