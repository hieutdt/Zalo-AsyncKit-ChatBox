//
//  TimeSectionCellNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/19/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "TimeSectionCellNode.h"
#import "TimeSectionHeader.h"
#import "StringHelper.h"

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
    self.style.preferredSize = constrainedSize.max;
    self.style.maxSize = constrainedSize.max;
    ASCenterLayoutSpec *centerSpec = [ASCenterLayoutSpec
                                      centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                      sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                      child:_textNode];
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(15, 0, 10, 0)
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
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:[StringHelper getTimeStringFromTimestamp:_timestamp]
                                                                 attributes:attributedText];
    
    [_textNode setAttributedText:string];
}

#pragma mark - CellNode

- (void)updateCellNodeWithObject:(id)object {
    if ([object isKindOfClass:[TimeSectionHeader class]]) {
        TimeSectionHeader *timeObj = (TimeSectionHeader *)object;
        [self setTimestamp:timeObj.timestamp];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}


@end
