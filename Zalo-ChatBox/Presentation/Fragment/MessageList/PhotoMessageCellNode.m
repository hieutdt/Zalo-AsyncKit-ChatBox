//
//  PhotoMessageCellNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PhotoMessageCellNode.h"
#import "PhotoMessageCellConfigure.h"
#import "SinglePhotoMessage.h"

#import "ImageCache.h"
#import "UIImage+Additions.h"

static const int kVerticalPadding = 15;

@interface PhotoMessageCellNode () <ASNetworkImageNodeDelegate>

@property (nonatomic, strong) SinglePhotoMessage *message;

@property (nonatomic, strong) ASNetworkImageNode *imageNode;

@property (nonatomic, strong) NSString *imageUrl;

@property (nonatomic, strong) PhotoMessageCellConfigure *configure;

@property (nonatomic, assign) BOOL didLayoutImage;

@end

@implementation PhotoMessageCellNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _configure = [PhotoMessageCellConfigure globalConfigure];
        
        _imageNode = [[ASNetworkImageNode alloc] init];
        _imageNode.contentMode = UIViewContentModeScaleAspectFit;
        _imageNode.delegate = self;
        _imageNode.layerBacked = YES;
        _imageNode.backgroundColor = [UIColor clearColor];
        _imageNode.shouldCacheImage = YES;
        
        _imageNode.style.width = ASDimensionMake(_configure.initialWidth);
        _imageNode.style.height = ASDimensionMake(_configure.initialHeight);
        
        _didLayoutImage = NO;
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    return [super layoutSpecThatFits:constrainedSize];
}

- (ASLayoutSpec *)contentLayoutSpec:(ASSizeRange)constrainedSize {
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(kVerticalPadding, 0, kVerticalPadding, 0)
                                                  child:_imageNode];
}

#pragma mark - Setter

- (void)setMessage:(SinglePhotoMessage *)message {
    [super setMessage:message];
    [self setImageUrl:message.imageURL.absoluteString];
}

- (void)setImageUrl:(NSString *)url {
    _imageUrl = url;
    _imageNode.URL = [NSURL URLWithString:url];
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
                
                ASDimension width;
                if (image.size.width > self.configure.maxWidthOfCell) {
                    width = ASDimensionMakeWithPoints(self.configure.maxWidthOfCell);
                } else {
                    width = ASDimensionMakeWithPoints(image.size.width);
                }
                ASDimension height = ASDimensionMakeWithPoints(self.configure.maxWidthOfCell * imageRatio);
                self.imageNode.style.preferredLayoutSize = ASLayoutSizeMake(width, height);
                
                [self.imageNode setNeedsLayout];
            }
      });
    }
}

#pragma mark - Action

- (void)touchUpInside {
    [super touchUpInside];
}

@end
