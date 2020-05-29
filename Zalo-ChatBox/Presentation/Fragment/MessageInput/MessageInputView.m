//
//  MessageInputView.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/29/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageInputView.h"

@interface MessageInputView ()

@property (nonatomic, strong) UIView *textEditContainer;

@end

@implementation MessageInputView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    
}

@end
