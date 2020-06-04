//
//  GroupPhotoMessageCellNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/28/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "GroupPhotoMessageCellNode.h"
#import "GroupPhotoMessageCellConfigure.h"
#import "GroupPhotoMessage.h"

static const GroupPhotoMessageCellConfigure *configure;

@interface GroupPhotoMessageCellNode () <ASNetworkImageNodeDelegate>

@property (nonatomic, strong) GroupPhotoMessage *message;

@property (nonatomic, strong) NSMutableArray<ASNetworkImageNode *> *imageNodes;
@property (nonatomic, strong) NSArray<NSString *> *imageUrls;

@end

@implementation GroupPhotoMessageCellNode


- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _imageNodes = [[NSMutableArray alloc] init];
        
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
    return [super layoutSpecThatFits:constrainedSize];
}

- (ASLayoutSpec *)contentLayoutSpec:(ASSizeRange)constrainedSize {
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
    
    if ([self messageCellStyle] == MessageCellStyleSend) {
        return [ASStackLayoutSpec
                stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                spacing:configure.verticalSpace
                justifyContent:ASStackLayoutJustifyContentStart
                alignItems:ASStackLayoutAlignItemsEnd
                children:verticalChilds];
        
    } else {
        return [ASStackLayoutSpec
                stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                spacing:configure.verticalSpace
                justifyContent:ASStackLayoutJustifyContentStart
                alignItems:ASStackLayoutAlignItemsStart
                children:verticalChilds];
    }
}

#pragma mark - Setter

- (void)setMessage:(GroupPhotoMessage *)message {
    [super setMessage:message];
    _message = message;
    
    [self initImageNodesWithCount:message.urls.count];
    [self setImageUrls:message.urls];
    
    for (int i = 0; i < _imageUrls.count; i++) {
        [_imageNodes[i] setURL:[NSURL URLWithString:_imageUrls[i]]];
    }
}

@end
