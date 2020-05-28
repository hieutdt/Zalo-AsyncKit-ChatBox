//
//  GroupPhotoMessageCellNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/28/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "Message.h"
#import "AppConsts.h"

#import "CellNodeObject.h"
#import "GroupPhotoMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupPhotoMessageCellNode : ASCellNode <CellNode>

- (void)setMessage:(Message *)message;

- (void)setImageUrls:(NSArray<NSString *> *)urls;

- (void)showAvatarImage:(UIImage *)image;

- (void)showAvatarImageWithGradientColor:(int)gradientColorCode
                               shortName:(NSString *)shortName;

@end

NS_ASSUME_NONNULL_END
