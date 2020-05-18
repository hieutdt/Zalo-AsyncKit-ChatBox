//
//  StringHelper.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "StringHelper.h"

@implementation StringHelper

+ (NSString*)standardizeString:(NSString *)string {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (NSString *)getShortName:(NSString *)name {
    if (name.length == 0)
        return @"";
    
    NSMutableString *shortName = [[NSMutableString alloc] initWithFormat:@"%c", [name characterAtIndex:0]];
    
    for (int i = 0; i < name.length - 1; i++) {
        if ([[name substringWithRange:NSMakeRange(i, 1)] isEqualToString: @" "]) {
            [shortName appendString:[name substringWithRange:NSMakeRange(i + 1, 1)]];
            break;
        }
    }
    
    return shortName;
}

@end
