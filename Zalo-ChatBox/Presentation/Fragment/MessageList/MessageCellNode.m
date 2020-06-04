//
//  MessageCellNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/18/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageCellNode.h"
#import "LayoutHelper.h"
#import "ContactAvatarNode.h"

#import "MessageCellConfigure.h"

#import "ImageCache.h"
#import "StringHelper.h"

static const int kIngroupVerticalPadding = 1;
static const int kOutgroupVerticalPadding = 10;
static const int kHorizontalPadding = 15;

@interface MessageCellNode ()

@property (nonatomic, strong) TextMessage *message;
@property (nonatomic, assign) MessageCellStyle messageStyle;

@property (nonatomic, strong) ASEditableTextNode *editTextNode;
@property (nonatomic, strong) ASImageNode *backgroundNode;
@property (nonatomic, strong) ASControlNode *controlNode;
@property (nonatomic, strong) ContactAvatarNode *avatarNode;
@property (nonatomic, strong) ASTextNode *timeTextNode;

@property (nonatomic, assign) BOOL showTail;
@property (nonatomic, assign) BOOL choosing;

@property (nonatomic, assign) int bottomPadding;

@property (nonatomic, assign) CGSize estimatedSize;

@property (nonatomic, assign) MessageCellConfigure *configure;

@end

@implementation MessageCellNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.automaticallyManagesSubnodes = YES;
        
        _messageStyle = MessageCellStyleTextSend;
        
        _estimatedSize = CGSizeMake(200, 100);
        
        _editTextNode = [[ASEditableTextNode alloc] init];
        _editTextNode.backgroundColor = [UIColor clearColor];
        _editTextNode.scrollEnabled = NO;
        _editTextNode.style.preferredSize = _estimatedSize;

        _backgroundNode = [[ASImageNode alloc] init];
        _backgroundNode.style.preferredSize = _estimatedSize;
        
        _avatarNode = [[ContactAvatarNode alloc] init];
        _avatarNode.hidden = YES;
        
        _timeTextNode = [[ASTextNode alloc] init];
        
        _choosing = NO;
        _showTail = NO;
        
        _bottomPadding = kIngroupVerticalPadding;
        
        _controlNode = [[ASControlNode alloc] init];
        [_controlNode addTarget:self
                         action:@selector(touchUpInside)
               forControlEvents:ASControlNodeEventTouchUpInside];
        
        _configure = [MessageCellConfigure globalConfigure];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxConstrainedSize = constrainedSize.max;
    
    _timeTextNode.style.width = ASDimensionMakeWithPoints(maxConstrainedSize.width);
    _timeTextNode.style.height = ASDimensionMakeWithPoints(40);
    
    _backgroundNode.style.width = ASDimensionMakeWithPoints(_estimatedSize.width + 30);
    _backgroundNode.style.height = ASDimensionMakeWithPoints(_estimatedSize.height + 20);
    
    _controlNode.style.width = ASDimensionMakeWithPoints(_estimatedSize.width + 30);
    _controlNode.style.height = ASDimensionMakeWithPoints(_estimatedSize.height + 20);
    
    ASInsetLayoutSpec *textInsetSpec;
    if (_messageStyle == MessageCellStyleTextSend) {
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
    
    ASOverlayLayoutSpec *overlayControlSpec = [ASOverlayLayoutSpec
                                                overlayLayoutSpecWithChild:overlayTextSpec
                                                overlay:_controlNode];
    
    ASStackLayoutAlignItems alignItems = ASStackLayoutAlignItemsStart;
    if (_messageStyle == MessageCellStyleTextSend) {
        alignItems = ASStackLayoutAlignItemsEnd;
    }
    
    if (_messageStyle == MessageCellStyleTextSend) {
        NSArray *childs = @[];
        if (_choosing) {
            childs = @[_timeTextNode, overlayControlSpec];
        } else {
            childs = @[overlayControlSpec];
        }
        ASStackLayoutSpec *verticalStackSpec = [ASStackLayoutSpec
                                                stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                spacing:2
                                                justifyContent:ASStackLayoutJustifyContentCenter
                                                alignItems:alignItems
                                                children:childs];
        return [ASInsetLayoutSpec
                insetLayoutSpecWithInsets:UIEdgeInsetsMake(kIngroupVerticalPadding, INFINITY, self.bottomPadding, kHorizontalPadding)
                child:verticalStackSpec];
        
    } else if (_messageStyle == MessageCellStyleTextReceive) {
        _avatarNode.style.preferredSize = CGSizeMake(25, 25);
        ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec
                                        stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                        spacing:10
                                        justifyContent:ASStackLayoutJustifyContentStart
                                        alignItems:ASStackLayoutAlignItemsEnd
                                        children:@[_avatarNode, overlayControlSpec]];
        
        if (_choosing) {
            ASStackLayoutSpec *verticalStackSpec = [ASStackLayoutSpec
                                                    stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                    spacing:2
                                                    justifyContent:ASStackLayoutJustifyContentCenter
                                                    alignItems:alignItems
                                                    children:@[_timeTextNode, stackSpec]];
            return [ASInsetLayoutSpec
                    insetLayoutSpecWithInsets:UIEdgeInsetsMake(kIngroupVerticalPadding, kHorizontalPadding, self.bottomPadding, INFINITY)
                    child:verticalStackSpec];
            
        } else {
            return [ASInsetLayoutSpec
                    insetLayoutSpecWithInsets:UIEdgeInsetsMake(kIngroupVerticalPadding, kHorizontalPadding, self.bottomPadding, INFINITY)
                    child:stackSpec];
        }
        
    } else {
        return nil;
    }
}

- (void)didLoad {
    [super didLoad];
    _editTextNode.textView.editable = NO;
}

#pragma mark - CellNode

- (void)updateCellNodeWithObject:(id)object {
    if ([object isKindOfClass:[TextMessage class]]) {
        TextMessage *textMessage = (TextMessage *)object;
        [self setMessage:textMessage];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.showTail = textMessage.showTail;
        
        Message *mess = (Message *)textMessage;
        if (mess.showAvatar) {
            UIImage *avatarImage = [[ImageCache instance] imageForKey:mess.fromContact.identifier];
            if (avatarImage) {
                [self showAvatarImage:avatarImage];
            } else {
                [self showAvatarImageWithGradientColor:mess.fromContact.gradientColorCode
                                             shortName:[StringHelper getShortName:mess.fromContact.name]];
            }
        }
        
        NSString *timeString = [StringHelper getTimeStringFromTimestamp:mess.timestamp];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            
        NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15],
                                          NSParagraphStyleAttributeName : paragraphStyle,
                                          NSForegroundColorAttributeName : [UIColor grayColor]
        };
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:timeString
                                                                     attributes:attributedText];
        [_timeTextNode setAttributedText:string];
        
        [self updateUI];
    }
}

- (void)updateUI {
    if (self.messageStyle == MessageCellStyleTextSend) {
        UIImage *bubbleImage = nil;
        
        if (self.showTail) {
            bubbleImage = [_configure sendMessageBubbleTail];
            self.bottomPadding = kOutgroupVerticalPadding;
        } else {
            bubbleImage = [_configure sendMessageBubble];
            self.bottomPadding = kIngroupVerticalPadding;
        }
        
        if (_choosing) {
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
        
        if (_choosing) {
            [_backgroundNode setImage:ASImageNodeTintColorModificationBlock(_configure.highlightReceiveMessageColor)
            ( [bubbleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate])];
        } else {
            [_backgroundNode setImage:bubbleImage];
        }
    }
}

#pragma mark - Setter

- (void)setMessage:(TextMessage *)message {
    _message = message;
    if ([_message.fromContact.phoneNumber isEqualToString:kCurrentUser]) {
        _messageStyle = MessageCellStyleTextSend;
    } else {
        _messageStyle = MessageCellStyleTextReceive;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
    UIColor *textColor = _messageStyle == MessageCellStyleTextSend ? [UIColor whiteColor] : [UIColor blackColor];
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

- (void)showAvatarImage:(UIImage *)image {
    if (!image || _messageStyle != MessageCellStyleTextReceive)
        return;
    
    [_avatarNode setAvatar:image];
    _avatarNode.hidden = NO;
}

- (void)showAvatarImageWithGradientColor:(int)gradientColorCode
                               shortName:(NSString *)shortName {
    if (!shortName || _messageStyle != MessageCellStyleTextReceive)
        return;
    
    [_avatarNode setGradientAvatarWithColorCode:gradientColorCode
                                   andShortName:shortName];
    _avatarNode.hidden = NO;
}

#pragma mark - Action

- (void)touchUpInside {
    self.choosing = !self.choosing;
    [self updateUI];
    [self.backgroundNode setNeedsLayout];
    [self setNeedsLayout];
}

@end
