//
//  TextMessageCellNode.h
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

@class TextMessageCellNode;

@protocol TextMessageCellNodeDelegate <NSObject>

@required
- (void)didSelectTextMessageCellNode:(TextMessageCellNode *)cellNode;

- (void)didUnselectTextMessageCellNode:(TextMessageCellNode *)cellNode;

@end

@interface TextMessageCellNode : ASCellNode <CellNode>

@property (nonatomic, assign) id<TextMessageCellNodeDelegate> delegate;

- (void)setMessage:(TextMessage *)message;

- (void)showAvatarImage:(UIImage *)image;

- (void)showAvatarImageWithGradientColor:(int)gradientColorCode
                               shortName:(NSString *)shortName;

@end

NS_ASSUME_NONNULL_END
