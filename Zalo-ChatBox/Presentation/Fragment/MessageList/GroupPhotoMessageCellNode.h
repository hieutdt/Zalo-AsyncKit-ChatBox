//
//  GroupPhotoMessageCellNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/28/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "MessageCellNode.h"
#import "Message.h"
#import "AppConsts.h"

#import "CellNodeObject.h"

NS_ASSUME_NONNULL_BEGIN

@class GroupPhotoMessage;

@interface GroupPhotoMessageCellNode : MessageCellNode

- (void)setMessage:(GroupPhotoMessage *)message;

- (void)setImageUrls:(NSArray<NSString *> *)urls;

@end

NS_ASSUME_NONNULL_END
