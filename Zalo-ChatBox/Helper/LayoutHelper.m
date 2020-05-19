//
//  LayoutHelper.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/19/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "LayoutHelper.h"

@implementation LayoutHelper

+ (CGRect)estimatedFrameOfText:(NSString *)text
                          font:(UIFont *)font
                   parrentSize:(CGSize)parrentSize {
    int options = NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin;
    CGRect estimatedFrame = [text boundingRectWithSize:parrentSize
                                               options:options
                                            attributes:@{NSFontAttributeName : font}
                                               context:nil];
    
    return estimatedFrame;
}

@end
