//
//  MessageCellNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 6/4/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "Message.h"
#import "AppConsts.h"
#import "CellNodeObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageCellNode : ASCellNode <CellNode>

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize;

- (ASLayoutSpec *)contentLayoutSpec:(ASSizeRange)constrainedSize;

- (MessageCellStyle)messageCellStyle;

- (BOOL)choosing;

- (BOOL)holding;

- (void)setMessage:(Message *)message;

- (void)showAvatarImage:(UIImage *)image;

- (void)showAvatarImageWithGradientColor:(int)gradientColorCode
                               shortName:(NSString *)shortName;

- (void)reaction:(ReactionType)reactionType;

- (ReactionType)reactionType;

#pragma mark - Action

- (void)touchUpInside;

- (void)longPressHandle;

- (void)focusEndHandle;

@end

NS_ASSUME_NONNULL_END
