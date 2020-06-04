//
//  MessageCellNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 6/4/20.
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

@property (nonatomic, assign) MessageCellStyle messageStyle;

@property (nonatomic, strong) ASControlNode *controlNode;
@property (nonatomic, strong) ContactAvatarNode *avatarNode;
@property (nonatomic, strong) ASTextNode *timeTextNode;

@property (nonatomic, assign) BOOL choosing;

@end

@implementation MessageCellNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.automaticallyManagesSubnodes = YES;
        
        _messageStyle = MessageCellStyleSend;
        
        _avatarNode = [[ContactAvatarNode alloc] init];
        _avatarNode.hidden = YES;
        
        _timeTextNode = [[ASTextNode alloc] init];
        
        _choosing = NO;
        
        _controlNode = [[ASControlNode alloc] init];
        [_controlNode addTarget:self
                         action:@selector(touchUpInside)
               forControlEvents:ASControlNodeEventTouchUpInside];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxConstrainedSize = constrainedSize.max;
    
    ASLayoutSpec *contentLayoutSpec = [self contentLayoutSpec:constrainedSize];
    
    _timeTextNode.style.width = ASDimensionMakeWithPoints(maxConstrainedSize.width);
    _timeTextNode.style.height = ASDimensionMakeWithPoints(40);
    
    _controlNode.style.width = ASDimensionMakeWithPoints(contentLayoutSpec.style.width.value);
    _controlNode.style.height = ASDimensionMakeWithPoints(contentLayoutSpec.style.height.value);
    
    ASOverlayLayoutSpec *overlayControlSpec = [ASOverlayLayoutSpec
                                               overlayLayoutSpecWithChild:contentLayoutSpec
                                               overlay:_controlNode];
    
    ASStackLayoutAlignItems alignItems = ASStackLayoutAlignItemsStart;
    if (_messageStyle == MessageCellStyleSend) {
        alignItems = ASStackLayoutAlignItemsEnd;
    }
    
    if (_messageStyle == MessageCellStyleSend) {
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
                       insetLayoutSpecWithInsets:UIEdgeInsetsMake(kIngroupVerticalPadding, INFINITY,kIngroupVerticalPadding, kHorizontalPadding)
                       child:verticalStackSpec];
        
    } else {
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
                           insetLayoutSpecWithInsets:UIEdgeInsetsMake(kIngroupVerticalPadding, kHorizontalPadding, kIngroupVerticalPadding, INFINITY)
                           child:verticalStackSpec];
                   
               } else {
                   return [ASInsetLayoutSpec
                           insetLayoutSpecWithInsets:UIEdgeInsetsMake(kIngroupVerticalPadding, kHorizontalPadding, kIngroupVerticalPadding, INFINITY)
                           child:stackSpec];
               }
    }
    
    return nil;
}

- (ASLayoutSpec *)contentLayoutSpec:(ASSizeRange)constrainedSize {
    // Override this method
    return nil;
}

#pragma mark - CellNode

- (void)updateCellNodeWithObject:(id)object {
    if ([object isKindOfClass:[Message class]]) {
        Message *message = (Message *)object;
        [self setMessage:message];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (message.showAvatar) {
            UIImage *avatarImage = [[ImageCache instance] imageForKey:message.fromContact.identifier];
            if (avatarImage) {
                [self showAvatarImage:avatarImage];
            } else {
                [self showAvatarImageWithGradientColor:message.fromContact.gradientColorCode
                                             shortName:[StringHelper getShortName:message.fromContact.name]];
            }
        }
        
        NSString *timeString = [StringHelper getTimeStringFromTimestamp:message.timestamp];
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
    // Override this method if needed
}

#pragma mark - Setter

- (void)setMessage:(Message *)message {
    if ([message.fromContact.phoneNumber isEqualToString:kCurrentUser]) {
        _messageStyle = MessageCellStyleSend;
    } else {
        _messageStyle = MessageCellStyleReceive;
    }
    
    // Override this method
}

- (void)showAvatarImage:(UIImage *)image {
    if (!image || _messageStyle != MessageCellStyleReceive)
        return;
    
    [_avatarNode setAvatar:image];
    _avatarNode.hidden = NO;
}

- (void)showAvatarImageWithGradientColor:(int)gradientColorCode
                               shortName:(NSString *)shortName {
    if (!shortName || _messageStyle != MessageCellStyleReceive)
        return;
    
    [_avatarNode setGradientAvatarWithColorCode:gradientColorCode
                                   andShortName:shortName];
    _avatarNode.hidden = NO;
}

#pragma mark - Getter

- (MessageCellStyle)messageCellStyle {
    return self.messageStyle;
}

- (BOOL)choosing {
    return _choosing;
}

#pragma mark - Action

- (void)touchUpInside {
    self.choosing = !self.choosing;
    [self setNeedsLayout];
}

@end
