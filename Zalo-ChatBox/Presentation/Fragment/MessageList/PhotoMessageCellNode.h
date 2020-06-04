//
//  PhotoMessageCellNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "MessageCellNode.h"
#import "Message.h"
#import "AppConsts.h"

#import "CellNodeObject.h"

NS_ASSUME_NONNULL_BEGIN

@class SinglePhotoMessage;

@interface PhotoMessageCellNode : MessageCellNode

- (void)setMessage:(SinglePhotoMessage *)message;

- (void)setImageUrl:(NSString *)url;

- (Message *)getMessage;

@end

NS_ASSUME_NONNULL_END
