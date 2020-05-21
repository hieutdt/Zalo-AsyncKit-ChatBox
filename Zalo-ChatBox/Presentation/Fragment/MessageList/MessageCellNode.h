//
//  MessageCellNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/18/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "Message.h"
#import "AppConsts.h"

NS_ASSUME_NONNULL_BEGIN

@class MessageCellNode;

@protocol MessageCellNodeDelegate <NSObject>

- (void)didSelectMessageCellNode:(MessageCellNode *)cellNode
                         atIndex:(NSInteger)index;

- (void)didUnselectMessageCellNode:(MessageCellNode *)cellNode
                           atIndex:(NSInteger)index;

@end

@interface MessageCellNode : ASCellNode

@property (nonatomic, assign) id<MessageCellNodeDelegate> delegate;

- (void)setMessage:(Message *)message;

- (void)showAvatarImage:(UIImage *)image;

- (void)showAvatarImageWithGradientColor:(int)gradientColorCode
                               shortName:(NSString *)shortName;

@end

NS_ASSUME_NONNULL_END
