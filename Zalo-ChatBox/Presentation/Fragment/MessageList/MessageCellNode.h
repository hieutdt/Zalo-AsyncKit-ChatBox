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
#import "CellNodeObject.h"
#import "TextMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class MessageCellNode;

@protocol MessageCellNodeDelegate <NSObject>

@required
- (void)didSelectMessageCellNode:(MessageCellNode *)cellNode;

- (void)didUnselectMessageCellNode:(MessageCellNode *)cellNode;

@end

@interface MessageCellNode : ASCellNode <CellNode>

@property (nonatomic, assign) id<MessageCellNodeDelegate> delegate;

- (void)setMessage:(TextMessage *)message;

- (void)showAvatarImage:(UIImage *)image;

- (void)showAvatarImageWithGradientColor:(int)gradientColorCode
                               shortName:(NSString *)shortName;

- (void)selectCell;

- (void)deselectCell;

@end

NS_ASSUME_NONNULL_END
