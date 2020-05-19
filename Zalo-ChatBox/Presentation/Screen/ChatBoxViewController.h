//
//  ChatBoxViewController.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatBoxViewController : ASViewController

@property (nonatomic, strong) Contact *messageToContact;

@end

NS_ASSUME_NONNULL_END
