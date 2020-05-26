//
//  ContactTableViewModel.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ContactTableViewModel.h"
#import "AppConsts.h"

@implementation ContactTableViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _identifier = [[NSString alloc] init];
        _name = [[NSString alloc] init];
        _gradientColorCode = RAND_FROM_TO(0, 3);
    }
    return self;
}

- (NSInteger)getSectionIndex {
    if (_name.length == 0)
        return -1;
    
    NSInteger sectionIndex =  [[_name lowercaseString] characterAtIndex:0] - FIRST_ALPHABET_ASCII_CODE;
    if (sectionIndex >= ALPHABET_SECTIONS_NUMBER) {
        sectionIndex = ALPHABET_SECTIONS_NUMBER - 1;
    }
    
    return sectionIndex;
}

@end
