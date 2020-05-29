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

#import "ImageCache.h"
#import "StringHelper.h"

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
@property (nonatomic, strong) ASTextNode *timeTextNode;

@property (nonatomic, strong) UIColor *blueColor;
@property (nonatomic, strong) UIColor *darkBlueColor;
@property (nonatomic, strong) UIColor *grayColor;
@property (nonatomic, strong) UIColor *darkGrayColor;

@property (nonatomic, assign) BOOL choosing;

@end

@implementation MessageCellNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.automaticallyManagesSubnodes = YES;
        
        _messageStyle = MessageCellStyleTextSend;
        
        _editTextNode = [[ASEditableTextNode alloc] init];
        _editTextNode.backgroundColor = [UIColor clearColor];
        _editTextNode.scrollEnabled = NO;

        _backgroundNode = [[ASImageNode alloc] init];
        _backgroundNode.contentMode = UIViewContentModeScaleToFill;
        _backgroundNode.cornerRadius = 10;
        
        _avatarNode = [[ContactAvatarNode alloc] init];
        _avatarNode.hidden = YES;
        
        _timeTextNode = [[ASTextNode alloc] init];
        
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
    _timeTextNode.style.preferredSize = CGSizeMake(maxConstrainedSize.width, 30);
    
    CGSize boundingSize = CGSizeMake(maxConstrainedSize.width * 0.7, 500);
    CGRect estimatedFrame = [LayoutHelper estimatedFrameOfText:_message.message
                                                          font:[UIFont fontWithName:@"HelveticaNeue" size:kFontSize]
                                                   parrentSize:boundingSize];
    
    _backgroundNode.style.preferredSize = CGSizeMake(estimatedFrame.size.width + 20, estimatedFrame.size.height + 20);
    _controlNode.style.preferredSize = CGSizeMake(estimatedFrame.size.width + 20, estimatedFrame.size.height + 20);
    
    ASOverlayLayoutSpec *overlayTextSpec = [ASOverlayLayoutSpec
                                        overlayLayoutSpecWithChild:_backgroundNode
                                        overlay:[ASInsetLayoutSpec
                                                 insetLayoutSpecWithInsets:UIEdgeInsetsMake(10, 10, 10, 10)
                                                 child:_editTextNode]];
    
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
            _backgroundNode.backgroundColor = _darkBlueColor;
        } else {
            childs = @[overlayControlSpec];
            _backgroundNode.backgroundColor = _blueColor;
        }
        ASStackLayoutSpec *verticalStackSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                                                       spacing:2
                                                                                justifyContent:ASStackLayoutJustifyContentCenter
                                                                                    alignItems:alignItems
                                                                                      children:childs];
        return [ASInsetLayoutSpec
                insetLayoutSpecWithInsets:UIEdgeInsetsMake(kVericalPadding, INFINITY, kVericalPadding, kHorizontalPadding)
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
            _backgroundNode.backgroundColor = _darkGrayColor;
            ASStackLayoutSpec *verticalStackSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                                                           spacing:2
                                                                                    justifyContent:ASStackLayoutJustifyContentCenter
                                                                                        alignItems:alignItems
                                                                                          children:@[_timeTextNode, stackSpec]];
            return [ASInsetLayoutSpec
                    insetLayoutSpecWithInsets:UIEdgeInsetsMake(kVericalPadding, kHorizontalPadding, kVericalPadding, INFINITY)
                    child:verticalStackSpec];
            
        } else {
            _backgroundNode.backgroundColor = _grayColor;
            return [ASInsetLayoutSpec
                    insetLayoutSpecWithInsets:UIEdgeInsetsMake(kVericalPadding, kHorizontalPadding, kVericalPadding, INFINITY)
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
        
        Message *mess = (Message *)textMessage;
        if (mess.showAvatar) {
            UIImage *avatarImage = [[ImageCache instance] imageForKey:mess.fromContact.identifier];
            if (avatarImage) {
                [self showAvatarImage:avatarImage];
            } else {
                [self showAvatarImageWithGradientColor:mess.fromContact.gradientColorCode
                                             shortName:mess.fromContact.name];
            }
        }
        
        NSString *timeString = [StringHelper getTimeStringFromTimestamp:mess.timestamp];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
            
        NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15],
                                          NSParagraphStyleAttributeName : paragraphStyle,
                                          NSForegroundColorAttributeName : [UIColor grayColor]
        };
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:timeString
                                                                     attributes:attributedText];
        [_timeTextNode setAttributedText:string];
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
    self.choosing = !self.choosing;
    [self setNeedsLayout];
}

@end
