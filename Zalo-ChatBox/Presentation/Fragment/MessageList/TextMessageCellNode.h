//
//  TextMessageCellNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/18/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "MessageCellNode.h"
#import "Message.h"
#import "AppConsts.h"
#import "CellNodeObject.h"
#import "TextMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class TextMessageCellNode;

@protocol TextMessageCellNodeDelegate <NSObject>

@required
- (void)didSelectTextMessageCellNode:(TextMessageCellNode *)cellNode;

- (void)didUnselectTextMessageCellNode:(TextMessageCellNode *)cellNode;

@end

@interface TextMessageCellNode : MessageCellNode

@property (nonatomic, assign) id<TextMessageCellNodeDelegate> delegate;

- (void)setMessage:(TextMessage *)message;

@end

NS_ASSUME_NONNULL_END
