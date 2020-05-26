//
//  SinglePhotoMessage.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/26/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "Message.h"
#import "PhotoMessageCellNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SinglePhotoMessage : Message

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, assign) CGFloat ratio;


- (instancetype)initWithPhotoURL:(NSString *)url ratio:(CGFloat)ratio;

- (instancetype)initWithPhotoURL:(NSString *)url
                           ratio:(CGFloat)ratio
            fromOwnerPhoneNumber:(NSString *)fromPhoneNumber
                   toPhoneNumber:(NSString *)toPhoneNumber
                       timestamp:(NSTimeInterval)ts;

@end

NS_ASSUME_NONNULL_END
