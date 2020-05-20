//
//  TimeSectionCellNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/19/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "TimeSectionCellNode.h"

@interface TimeSectionCellNode ()

@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) ASTextNode *textNode;

@end

@implementation TimeSectionCellNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.automaticallyManagesSubnodes = YES;
        _timestamp = 0;
        _textNode = [[ASTextNode alloc] init];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(5, 0, 0, 0)
                                                  child:_textNode];
}

- (void)setTimestamp:(NSTimeInterval)ts {
    _timestamp = ts;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    UIColor *textColor = [UIColor grayColor];
    NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15],
                                      NSParagraphStyleAttributeName : paragraphStyle,
                                      NSForegroundColorAttributeName : textColor
    };
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_timestamp];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeZone = [NSTimeZone localTimeZone];

    if ([[NSCalendar currentCalendar] isDateInToday:date]) {
        formatter.dateFormat = @"HH:mm 'Hôm nay'";
    } else if ([[NSCalendar currentCalendar] isDateInYesterday:date]) {
        formatter.dateFormat = @"HH:mm 'Hôm qua'";
    } else {
        formatter.dateFormat = @"HH:mm dd/MM/YYYY";
    }
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:[formatter stringFromDate:date]
                                                                 attributes:attributedText];
    
    [_textNode setAttributedText:string];
}


@end
