//
//  PhotoMessageCellNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "Message.h"
#import "AppConsts.h"

#import "CellNodeObject.h"
#import "SinglePhotoMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoMessageCellNode : ASCellNode <CellNode>

@property (nonatomic, assign) CGFloat imageRatio;

- (void)setMessage:(Message *)message;

- (void)setImageUrl:(NSString *)url;

- (void)showAvatarImage:(UIImage *)image;

- (void)showAvatarImageWithGradientColor:(int)gradientColorCode
                               shortName:(NSString *)shortName;

- (BOOL)isFinishLoadImage;

- (Message *)getMessage;

@end

NS_ASSUME_NONNULL_END
