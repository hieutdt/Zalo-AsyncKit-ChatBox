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
    NSLog(@"TONHIEU: Section size = %f - %f", constrainedSize.max.width, constrainedSize.max.height);
    self.style.preferredSize = constrainedSize.max;
    self.style.maxSize = constrainedSize.max;
    ASCenterLayoutSpec *centerSpec = [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                                                                sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                                                                        child:_textNode];
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(5, 0, 0, 0)
                                                  child:centerSpec];
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
    
    NSString *dateString = [formatter stringFromDate:date];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:dateString
                                                                 attributes:attributedText];
    
    [_textNode setAttributedText:string];
}


@end
