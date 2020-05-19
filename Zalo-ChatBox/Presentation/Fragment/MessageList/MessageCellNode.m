//
//  MessageCellNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/18/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageCellNode.h"
#import "LayoutHelper.h"

static const int kFontSize = 18;
static const int kVericalPadding = 5;

@interface MessageCellNode ()

@property (nonatomic, strong) Message *message;
@property (nonatomic, assign) MessageCellStyle messageStyle;

@property (nonatomic, strong) ASEditableTextNode *editTextNode;
@property (nonatomic, strong) ASDisplayNode *backgroundNode;

@end

@implementation MessageCellNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _messageStyle = MessageCellStyleTextSend;
        
        _editTextNode = [[ASEditableTextNode alloc] init];
        _editTextNode.backgroundColor = [UIColor clearColor];
        _editTextNode.scrollEnabled = NO;
        
        _backgroundNode = [[ASDisplayNode alloc] init];
        _backgroundNode.cornerRadius = 15;
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxConstrainedSize = constrainedSize.max;
    
    // maxConstrainedSize.height is already wrap text
    CGSize boundingSize = CGSizeMake(maxConstrainedSize.width * 0.7, maxConstrainedSize.height);
    CGRect estimatedFrame = [LayoutHelper estimatedFrameOfText:_message.message
                                                          font:[UIFont fontWithName:@"HelveticaNeue" size:kFontSize]
                                                   parrentSize:boundingSize];
    
    _backgroundNode.style.preferredSize = CGSizeMake(estimatedFrame.size.width + 16, maxConstrainedSize.height);
    
    ASOverlayLayoutSpec *overlaySpec = [ASOverlayLayoutSpec
                                        overlayLayoutSpecWithChild:_backgroundNode
                                        overlay:[ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(5, 8, 5, 8)
                                                                                       child:_editTextNode]];
    
    if (_messageStyle == MessageCellStyleTextSend) {
        _backgroundNode.backgroundColor = [UIColor colorWithRed:21/255.f green:130/255.f blue:203/255.f alpha:1];
        return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(kVericalPadding, INFINITY, kVericalPadding, 5)
                                                      child:overlaySpec];
    } else if (_messageStyle == MessageCellStyleTextReceive) {
        _backgroundNode.backgroundColor = [UIColor colorWithRed:229/255.f green:231/255.f blue:233/255.f alpha:1];
        return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(kVericalPadding, 5, kVericalPadding, INFINITY)
                                                      child:overlaySpec];
    } else {
        return nil;
    }
}

- (void)didLoad {
    [super didLoad];
    _editTextNode.textView.editable = NO;
}

#pragma mark - Setter

- (void)setMessage:(Message *)message {
    _message = message;
    if ([_message.fromPhoneNumber isEqualToString:kCurrentUser]) {
        _messageStyle = MessageCellStyleTextSend;
    } else {
        _messageStyle = MessageCellStyleTextReceive;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    UIColor *textColor = _messageStyle == MessageCellStyleTextSend ? [UIColor whiteColor] : [UIColor blackColor];
    NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:kFontSize],
                                      NSParagraphStyleAttributeName : paragraphStyle,
                                      NSForegroundColorAttributeName : textColor
    };
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:message.message
                                                                 attributes:attributedText];
    
    [_editTextNode setAttributedText:string];
}

@end
