//
//  Message.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/18/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConsts.h"
#import "CellNodeObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message : CellNodeObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *fromPhoneNumber;
@property (nonatomic, strong) NSString *toPhoneNumber;
@property (nonatomic, assign) NSTimeInterval timestamp;

@property (nonatomic, assign) BOOL showAvatar;

- (instancetype)initWithCellNodeClass:(Class)cellNodeClass
                             userInfo:(_Nullable id)userInfo;

- (instancetype)initWithCellNodeClass:(Class)cellNodeClass
                             userInfo:(_Nullable id)userInfo
                      fromPhoneNumber:(NSString *)fromPhoneNumber
                        toPhoneNumber:(NSString *)toPhoneNumber
                            timestamp:(NSTimeInterval)ts;

@end

NS_ASSUME_NONNULL_END
