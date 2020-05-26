//
//  SinglePhotoMessage.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/26/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "SinglePhotoMessage.h"

@interface SinglePhotoMessage ()

@end

@implementation SinglePhotoMessage

- (instancetype)init {
    return [self initWithPhotoURL:@"" ratio:0 fromOwnerPhoneNumber:@"" toPhoneNumber:@"" timestamp:0];
}

- (instancetype)initWithPhotoURL:(NSString *)url ratio:(CGFloat)ratio {
    return [self initWithPhotoURL:url
                            ratio:ratio
             fromOwnerPhoneNumber:@""
                    toPhoneNumber:@""
                        timestamp:0];
}

- (instancetype)initWithPhotoURL:(NSString *)url
                           ratio:(CGFloat)ratio
            fromOwnerPhoneNumber:(NSString *)fromPhoneNumber
                   toPhoneNumber:(NSString *)toPhoneNumber
                       timestamp:(NSTimeInterval)ts {
    self = [super initWithCellNodeClass:[PhotoMessageCellNode class]
                               userInfo:nil
                        fromPhoneNumber:fromPhoneNumber
                          toPhoneNumber:toPhoneNumber
                              timestamp:ts];
    if (self) {
        _imageURL = [NSURL URLWithString:url];
        _ratio = ratio;
    }
    return self;
}

@end
