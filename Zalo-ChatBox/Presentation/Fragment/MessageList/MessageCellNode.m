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

static const int kFontSize = 18;
static const int kVericalPadding = 3;
static const int kHorizontalPadding = 10;

@interface MessageCellNode ()

@property (nonatomic, strong) TextMessage *message;
@property (nonatomic, assign) MessageCellStyle messageStyle;

@property (nonatomic, strong) ASEditableTextNode *editTextNode;
@property (nonatomic, strong) ASDisplayNode *backgroundNode;
@property (nonatomic, strong) ASControlNode *controlNode;
@property (nonatomic, strong) ContactAvatarNode *avatarNode;

@property (nonatomic, strong) UIColor *blueColor;
@property (nonatomic, strong) UIColor *darkBlueColor;
@property (nonatomic, strong) UIColor *grayColor;
@property (nonatomic, strong) UIColor *darkGrayColor;

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
        _backgroundNode.cornerRadius = 10;
        
        _avatarNode = [[ContactAvatarNode alloc] init];
        _avatarNode.hidden = YES;
        
        _choosing = NO;
        
        _controlNode = [[ASControlNode alloc] init];
        [_controlNode addTarget:self
                         action:@selector(touchUpInside)
               forControlEvents:ASControlNodeEventTouchUpInside];
        
        _blueColor = [UIColor colorWithRed:21/255.f green:130/255.f blue:203/255.f alpha:1];
        _darkBlueColor = [UIColor colorWithRed:31/255.f green:97/255.f blue:141/255.f alpha:1];
        _grayColor = [UIColor colorWithRed:229/255.f green:231/255.f blue:233/255.f alpha:1];
        _darkGrayColor = [UIColor colorWithRed:179/255.f green:182/255.f blue:183/255.f alpha:1];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxConstrainedSize = constrainedSize.max;
    
    CGSize boundingSize = CGSizeMake(maxConstrainedSize.width * 0.7, 400);
    CGRect estimatedFrame = [LayoutHelper estimatedFrameOfText:_message.message
                                                          font:[UIFont fontWithName:@"HelveticaNeue" size:kFontSize]
                                                   parrentSize:boundingSize];
    
    _backgroundNode.style.preferredSize = CGSizeMake(estimatedFrame.size.width + 16, estimatedFrame.size.height + 10);
    _controlNode.style.preferredSize = CGSizeMake(estimatedFrame.size.width + 16, estimatedFrame.size.height);
    
    ASOverlayLayoutSpec *overlayTextSpec = [ASOverlayLayoutSpec
                                        overlayLayoutSpecWithChild:_backgroundNode
                                        overlay:[ASInsetLayoutSpec
                                                 insetLayoutSpecWithInsets:UIEdgeInsetsMake(5, 8, 5, 8)
                                                 child:_editTextNode]];
    
    ASOverlayLayoutSpec *overlayControlSpec = [ASOverlayLayoutSpec
                                                overlayLayoutSpecWithChild:overlayTextSpec
                                                overlay:_controlNode];
    
    if (_messageStyle == MessageCellStyleTextSend) {
        _backgroundNode.backgroundColor = _blueColor;
        return [ASInsetLayoutSpec
                insetLayoutSpecWithInsets:UIEdgeInsetsMake(kVericalPadding, INFINITY, kVericalPadding, kHorizontalPadding)
                child:overlayControlSpec];
        
    } else if (_messageStyle == MessageCellStyleTextReceive) {
        _backgroundNode.backgroundColor = _grayColor;
        
        _avatarNode.style.preferredSize = CGSizeMake(25, 25);
        ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec
                                        stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                        spacing:10
                                        justifyContent:ASStackLayoutJustifyContentStart
                                        alignItems:ASStackLayoutAlignItemsEnd
                                        children:@[_avatarNode, overlayControlSpec]];
        
        return [ASInsetLayoutSpec
                insetLayoutSpecWithInsets:UIEdgeInsetsMake(kVericalPadding, kHorizontalPadding, kVericalPadding, INFINITY)
                child:stackSpec];
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
//        [self setNeedsLayout];
    }
}

#pragma mark - Setter

- (void)setMessage:(TextMessage *)message {
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

- (void)selectCell {
    _choosing = YES;
    __weak MessageCellNode *weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        if (weakSelf.messageStyle == MessageCellStyleTextSend) {
            [weakSelf.backgroundNode setBackgroundColor:weakSelf.darkBlueColor];
        } else {
            [weakSelf.backgroundNode setBackgroundColor:weakSelf.darkGrayColor];
        }
    }];
}

- (void)deselectCell {
    _choosing = NO;
    __weak MessageCellNode *weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        if (weakSelf.messageStyle == MessageCellStyleTextSend) {
            [weakSelf.backgroundNode setBackgroundColor:weakSelf.blueColor];
        } else {
            [weakSelf.backgroundNode setBackgroundColor:weakSelf.grayColor];
        }
    }];
}

#pragma mark - Action

- (void)touchUpInside {
    if (self.choosing) {
        if (self.delegate &&
            [self.delegate conformsToProtocol:@protocol(MessageCellNodeDelegate)]) {
            [self.delegate didUnselectMessageCellNode:self];
        }
    } else {
        if (self.delegate &&
            [self.delegate conformsToProtocol:@protocol(MessageCellNodeDelegate)]) {
            [self.delegate didSelectMessageCellNode:self];
        }
    }
}

@end
