//
//  TextMessageCellNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/18/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "TextMessageCellNode.h"
#import "LayoutHelper.h"
#import "ContactAvatarNode.h"

#import "MessageCellConfigure.h"

#import "ImageCache.h"
#import "StringHelper.h"

static const int kIngroupVerticalPadding = 1;
static const int kOutgroupVerticalPadding = 10;
static const int kHorizontalPadding = 15;

@interface TextMessageCellNode ()

@property (nonatomic, strong) TextMessage *message;

@property (nonatomic, strong) ASEditableTextNode *editTextNode;
@property (nonatomic, strong) ASImageNode *backgroundNode;

@property (nonatomic, assign) BOOL showTail;

@property (nonatomic, assign) int bottomPadding;

@property (nonatomic, assign) CGSize estimatedSize;

@property (nonatomic, assign) MessageCellConfigure *configure;

@end

@implementation TextMessageCellNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.automaticallyManagesSubnodes = YES;
        
        _estimatedSize = CGSizeMake(200, 100);
        
        _editTextNode = [[ASEditableTextNode alloc] init];
        _editTextNode.backgroundColor = [UIColor clearColor];
        _editTextNode.scrollEnabled = NO;
        _editTextNode.style.preferredSize = _estimatedSize;

        _backgroundNode = [[ASImageNode alloc] init];
        _backgroundNode.style.preferredSize = _estimatedSize;
        
        _showTail = NO;
        
        _bottomPadding = kIngroupVerticalPadding;
        
        _configure = [MessageCellConfigure globalConfigure];
    }
    return self;
}

- (ASLayoutSpec *)contentLayoutSpec:(ASSizeRange)constrainedSize {
    _backgroundNode.style.width = ASDimensionMakeWithPoints(_estimatedSize.width + 30);
    _backgroundNode.style.height = ASDimensionMakeWithPoints(_estimatedSize.height + 20);
    
    ASInsetLayoutSpec *textInsetSpec;
    if ([super messageCellStyle] == MessageCellStyleSend) {
        textInsetSpec = [ASInsetLayoutSpec insetLayoutSpecWithInsets:_configure.sendMessageTextInsets
                                                               child:_editTextNode];
    } else {
        textInsetSpec = [ASInsetLayoutSpec insetLayoutSpecWithInsets:_configure.receiveMessageTextInsets
                                                               child:_editTextNode];
    }
    
    ASOverlayLayoutSpec *overlayTextSpec = [ASOverlayLayoutSpec
                                        overlayLayoutSpecWithChild:_backgroundNode
                                        overlay:[ASInsetLayoutSpec
                                                 insetLayoutSpecWithInsets:_configure.contentInsets
                                                 child:textInsetSpec]];
    
    return [ASInsetLayoutSpec
            insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 0, self.bottomPadding, 0)
            child:overlayTextSpec];
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    return [super layoutSpecThatFits:constrainedSize];
}

- (void)didLoad {
    [super didLoad];
    _editTextNode.textView.editable = NO;
}

//#pragma mark - CellNode
//
//- (void)updateCellNodeWithObject:(id)object {
//    if ([object isKindOfClass:[TextMessage class]]) {
//        TextMessage *textMessage = (TextMessage *)object;
//        [self setMessage:textMessage];
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
//        self.showTail = textMessage.showTail;
//
//        Message *mess = (Message *)textMessage;
//        if (mess.showAvatar) {
//            UIImage *avatarImage = [[ImageCache instance] imageForKey:mess.fromContact.identifier];
//            if (avatarImage) {
//                [self showAvatarImage:avatarImage];
//            } else {
//                [self showAvatarImageWithGradientColor:mess.fromContact.gradientColorCode
//                                             shortName:[StringHelper getShortName:mess.fromContact.name]];
//            }
//        }
//
//        NSString *timeString = [StringHelper getTimeStringFromTimestamp:mess.timestamp];
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        paragraphStyle.alignment = NSTextAlignmentCenter;
//        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//
//        NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15],
//                                          NSParagraphStyleAttributeName : paragraphStyle,
//                                          NSForegroundColorAttributeName : [UIColor grayColor]
//        };
//
//        NSAttributedString *string = [[NSAttributedString alloc] initWithString:timeString
//                                                                     attributes:attributedText];
//        [_timeTextNode setAttributedText:string];
//
//        [self updateUI];
//    }
//}

- (void)updateUI {
    if ([self messageCellStyle] == MessageCellStyleSend) {
        UIImage *bubbleImage = nil;
        
        if (self.showTail) {
            bubbleImage = [_configure sendMessageBubbleTail];
            self.bottomPadding = kOutgroupVerticalPadding;
        } else {
            bubbleImage = [_configure sendMessageBubble];
            self.bottomPadding = kIngroupVerticalPadding;
        }
        
        if ([self choosing]) {
            [_backgroundNode setImage:ASImageNodeTintColorModificationBlock(_configure.highlightSendMessageColor)
            ( [bubbleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate])];
        } else {
            [_backgroundNode setImage:bubbleImage];
        }
        
    } else {
        UIImage *bubbleImage = nil;
        
        if (self.showTail) {
            bubbleImage = [_configure receiveMessageBubbleTail];
            self.bottomPadding = kOutgroupVerticalPadding;
        } else {
            bubbleImage = [_configure receiveMessageBubble];
            self.bottomPadding = kIngroupVerticalPadding;
        }
        
        if ([self choosing]) {
            [_backgroundNode setImage:ASImageNodeTintColorModificationBlock(_configure.highlightReceiveMessageColor)
            ( [bubbleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate])];
        } else {
            [_backgroundNode setImage:bubbleImage];
        }
    }
}

#pragma mark - Setter

- (void)setMessage:(TextMessage *)message {
    [super setMessage:message];
    _message = message;
    self.showTail = message.showTail;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
    UIColor *textColor = [super messageCellStyle] == MessageCellStyleSend ? [UIColor whiteColor] : [UIColor blackColor];
    NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:18],
                                      NSParagraphStyleAttributeName : paragraphStyle,
                                      NSForegroundColorAttributeName : textColor
    };
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:message.message
                                                                 attributes:attributedText];
    
    CGSize boundingSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.6, 500);
    CGRect estimatedFrame = [LayoutHelper estimatedFrameOfText:_message.message
                                                          font:[UIFont fontWithName:@"HelveticaNeue" size:18]
                                                   parrentSize:boundingSize];
    _estimatedSize = estimatedFrame.size;
    
    [_editTextNode setAttributedText:string];
}

#pragma mark - Action

- (void)touchUpInside {
    [super touchUpInside];
    
    [self updateUI];
    [self.backgroundNode setNeedsLayout];
    [self setNeedsLayout];
}

@end
