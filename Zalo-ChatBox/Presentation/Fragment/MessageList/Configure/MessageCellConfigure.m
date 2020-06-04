//
//  MessageCellConfigure.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 6/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageCellConfigure.h"

@interface MessageCellConfigure ()

@property (nonatomic, strong) UIColor *blueColor;
@property (nonatomic, strong) UIColor *darkBlueColor;
@property (nonatomic, strong) UIColor *grayColor;
@property (nonatomic, strong) UIColor *darkGrayColor;

@property (nonatomic, strong) UIImage *sendMessageBubble;
@property (nonatomic, strong) UIImage *receiveMessageBubble;

@property (nonatomic, assign) CGFloat maxWidthOfCell;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) UIEdgeInsets sendMessageTextInsets;
@property (nonatomic, assign) UIEdgeInsets receiveMessageTextInsets;

@end

@implementation MessageCellConfigure

- (instancetype)init {
    self = [super init];
    if (self) {
        _blueColor = [UIColor colorWithRed:21/255.f green:130/255.f blue:203/255.f alpha:1];
        _darkBlueColor = [UIColor colorWithRed:31/255.f green:97/255.f blue:141/255.f alpha:1];
        _grayColor = [UIColor colorWithRed:229/255.f green:231/255.f blue:233/255.f alpha:1];
        _darkGrayColor = [UIColor colorWithRed:179/255.f green:182/255.f blue:183/255.f alpha:1];
        
        _maxWidthOfCell = [UIScreen mainScreen].bounds.size.width * 0.7;
        _contentInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        _sendMessageTextInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        _receiveMessageTextInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        
        _sendMessageBubble = [[UIImage imageNamed:@"bubble_sent"]
                              resizableImageWithCapInsets:UIEdgeInsetsMake(17, 21, 17, 21)
                              resizingMode:UIImageResizingModeStretch];
        
        _receiveMessageBubble = [[UIImage imageNamed:@"bubble_received"]
                                 resizableImageWithCapInsets:UIEdgeInsetsMake(17, 21, 17, 21)
                                 resizingMode:UIImageResizingModeStretch];
    }
    return self;
}

+ (MessageCellConfigure *)globalConfigure {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MessageCellConfigure alloc] init];
    });
    return sharedInstance;
}

- (UIColor *)sendMessageBackgroundColor {
    return _blueColor;
}

- (UIColor *)receiveMessageBackgroundColor {
    return _grayColor;
}

- (UIColor *)highlightSendMessageColor {
    return _darkBlueColor;
}

- (UIColor *)highlightReceiveMessageColor {
    return _darkGrayColor;
}

- (NSUInteger)messageTextSize {
    return 18;
}

- (NSUInteger)ingroupMessageVerticalSpace {
    return 1;
}

- (NSUInteger)outgroupMessageVerticalSpace {
    return 8;
}

- (NSUInteger)messageHorizontalPadding {
    return 10;
}

- (CGFloat)maxWidthOfCell {
    return _maxWidthOfCell;
}

- (UIEdgeInsets)contentInsets {
    return _contentInsets;
}

- (UIEdgeInsets)sendMessageTextInsets {
    return _sendMessageTextInsets;
}

- (UIEdgeInsets)receiveMessageTextInsets {
    return _receiveMessageTextInsets;
}


- (UIImage *)sendMessageBubble {
    return [[UIImage imageNamed:@"bubble_sent"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(17, 21, 17, 21)
            resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)sendMessageBubbleTail {
    return [[UIImage imageNamed:@"bubble_sent_tail"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(17, 21, 17, 21)
            resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)receiveMessageBubble {
    return [[UIImage imageNamed:@"bubble_received"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(17, 21, 17, 21)
            resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)receiveMessageBubbleTail {
    return [[UIImage imageNamed:@"bubble_received_tail"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(17, 21, 17, 21)
            resizingMode:UIImageResizingModeStretch];
}

@end
