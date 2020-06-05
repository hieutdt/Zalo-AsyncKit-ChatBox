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

#import "AppConsts.h"
#import "ImageCache.h"
#import "StringHelper.h"

static const int kIngroupVerticalPadding = 1;
static const int kHorizontalPadding = 15;

@interface MessageCellNode ()

@property (nonatomic, assign) MessageCellStyle messageStyle;

@property (nonatomic, strong) ASControlNode *controlNode;
@property (nonatomic, strong) ContactAvatarNode *avatarNode;
@property (nonatomic, strong) ASTextNode *timeTextNode;
@property (nonatomic, strong) ASImageNode *reactionNode;

@property (nonatomic, assign) BOOL choosing;
@property (nonatomic, assign) ReactionType reactionType;

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
        
        _reactionType = ReactionTypeNull;
        
        _reactionNode = [[ASImageNode alloc] init];
        _reactionNode.contentMode = UIViewContentModeScaleAspectFit;
        _reactionNode.backgroundColor = [UIColor clearColor];
        _reactionNode.style.preferredSize = CGSizeMake(40, 40);
        _reactionNode.hidden = YES;
        
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
    _timeTextNode.style.height = ASDimensionMakeWithPoints(25);
    
    _controlNode.style.width = ASDimensionMakeWithPoints(contentLayoutSpec.style.width.value);
    _controlNode.style.height = ASDimensionMakeWithPoints(contentLayoutSpec.style.height.value);
    
    ASOverlayLayoutSpec *overlayControlSpec = [ASOverlayLayoutSpec
                                               overlayLayoutSpecWithChild:contentLayoutSpec
                                               overlay:_controlNode];
    
    ASLayoutSpec *insetContentSpec = nil;
    
    if (_reactionType != ReactionTypeNull) {
        ASCornerLayoutLocation location = ASCornerLayoutLocationBottomRight;
        if (_messageStyle == MessageCellStyleSend) {
            location = ASCornerLayoutLocationBottomLeft;
        }
        
        ASCornerLayoutSpec *cornerReactionSpec = [ASCornerLayoutSpec cornerLayoutSpecWithChild:overlayControlSpec
                                                                                        corner:_reactionNode
                                                                                      location:location];
        insetContentSpec = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 0, 23, 0) child:cornerReactionSpec];
    } else {
        insetContentSpec = overlayControlSpec;
    }
    
    ASStackLayoutAlignItems alignItems = ASStackLayoutAlignItemsStart;
    if (_messageStyle == MessageCellStyleSend) {
        alignItems = ASStackLayoutAlignItemsEnd;
    }
    
    if (_messageStyle == MessageCellStyleSend) {
        NSArray *childs = @[];
        if (_choosing) {
            childs = @[_timeTextNode, insetContentSpec];
        } else {
            childs = @[insetContentSpec];
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
                                               children:@[_avatarNode, insetContentSpec]];
               
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
    //TODO: Override this method or die :]
    return nil;
}

- (void)didLoad {
    [super didLoad];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(longPressHandle)];
    
    [self.controlNode.view addGestureRecognizer:longPressGesture];
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
    //TODO: Override this method if needed :]
}

#pragma mark - Setter

- (void)setMessage:(Message *)message {
    if ([message.fromContact.phoneNumber isEqualToString:kCurrentUser]) {
        _messageStyle = MessageCellStyleSend;
    } else {
        _messageStyle = MessageCellStyleReceive;
    }
    
    //TODO: Override this method, remember to call super :]
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

- (void)reaction:(ReactionType)reactionType {
    _reactionType = reactionType;
    if (reactionType == ReactionTypeNull) {
        _reactionNode.hidden = YES;
        [_reactionNode setImage:nil];
        [_reactionNode setNeedsLayout];
        [self setNeedsLayout];
    } else {
        NSString *imgName = [NSString stringWithFormat:@"react_%ld", reactionType];
        [_reactionNode setImage:[UIImage imageNamed:imgName]];
        _reactionNode.hidden = NO;
        [_reactionNode setNeedsLayout];
        [self setNeedsLayout];
    }
}

#pragma mark - Getter

- (MessageCellStyle)messageCellStyle {
    return self.messageStyle;
}

- (BOOL)choosing {
    return _choosing;
}

- (ReactionType)reactionType {
    return _reactionType;
}

#pragma mark - Action

- (void)touchUpInside {
    self.choosing = !self.choosing;
    [self setNeedsLayout];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageTappedNotification
                                                        object:self
                                                      userInfo:@{ @"cellNode" : self }];
}

- (void)longPressHandle {
    if (self.choosing)
        return;
    
    self.choosing = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageLongPressNotification
                                                        object:self
                                                      userInfo:@{ @"cellNode" : self }];
}

- (void)focusEndHandle {
    self.choosing = NO;
}

@end
