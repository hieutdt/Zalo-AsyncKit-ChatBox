//
//  MessageCellConfigure.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 6/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "TextMessage.h"
#import "AppConsts.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageCellConfigure : NSObject

@property (nonatomic, readonly) UIColor *sendMessageBackgroundColor;
@property (nonatomic, readonly) UIColor *receiveMessageBackgroundColor;
@property (nonatomic, readonly) UIColor *highlightSendMessageColor;
@property (nonatomic, readonly) UIColor *highlightReceiveMessageColor;

@property (nonatomic, readonly) NSUInteger  messageTextSize;
@property (nonatomic, readonly) NSUInteger  ingroupMessageVerticalSpace;
@property (nonatomic, readonly) NSUInteger  outgroupMessageVerticalSpace;
@property (nonatomic, readonly) NSUInteger  messageHorizontalPadding;
@property (nonatomic, readonly) CGFloat     maxWidthOfCell;

@property (nonatomic, readonly) UIEdgeInsets contentInsets;
@property (nonatomic, readonly) UIEdgeInsets receiveMessageTextInsets;
@property (nonatomic, readonly) UIEdgeInsets sendMessageTextInsets;

+ (MessageCellConfigure *)globalConfigure;

- (UIImage *)backgroundImageForTextMessageGroupType:(TextMessageGroupType)groupType
                                    andCellNodeType:(MessageCellStyle)cellStyle;

@end

NS_ASSUME_NONNULL_END
