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

@interface MessageCellNode : ASCellNode

- (void)setMessage:(Message *)message;

@end

NS_ASSUME_NONNULL_END
