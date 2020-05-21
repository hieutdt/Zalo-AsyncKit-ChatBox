//
//  ContactAvatarNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactAvatarNode : ASDisplayNode

- (void)setAvatar:(UIImage *)image;

- (void)setGradientAvatarWithColorCode:(int)colorCode
                          andShortName:(NSString *)shortName;

@end

NS_ASSUME_NONNULL_END
