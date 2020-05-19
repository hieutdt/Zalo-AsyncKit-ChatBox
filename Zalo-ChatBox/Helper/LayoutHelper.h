//
//  LayoutHelper.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/19/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LayoutHelper : NSObject

+ (CGRect)estimatedFrameOfText:(NSString *)text
                          font:(UIFont *)font
                   parrentSize:(CGSize)parrentSize;

@end

NS_ASSUME_NONNULL_END
