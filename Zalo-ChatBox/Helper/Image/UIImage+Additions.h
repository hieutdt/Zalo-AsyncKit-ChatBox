//
//  UIImage+Additions.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Additions)

- (UIImage *)makeCircularImageWithSize:(CGSize)size;

- (UIImage *)makeCornerRadius:(CGFloat)cornerRadius withSize:(CGSize)size;

+ (CGSize)sizeOfImageFromUrl:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
